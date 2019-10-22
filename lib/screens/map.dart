import 'dart:async';
import 'dart:convert';
import 'package:discgolf/utils/colors.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapTest extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MapTest> {
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapController;
  Geolocator _geolocator;
  Position _position;

  //Temp
  final margin = const EdgeInsets.only(bottom: 10.0, right: 10.0, left: 10.0);
  final backColor = Colors.lightGreen;
  final text = new Text(
    'Text here',
    style: new TextStyle(fontSize: 50.0),
  );

  static const LatLng _center = const LatLng(63.836711, 20.313654);
  final Set<Marker> markers = {};
  Marker playerMarker;
  final Set<Polyline> polylines = {};
  final List<Marker> discLandingMarkers = List();
  final List<String> throwLengths = List();
  final List<PatternItem> dashedPattern = List();
  //add your lat and lng where you wants to draw polyline

  Polyline dashedPolyline;
  Polyline playerPolyline;
  int discLandingIndex = 0;
  List<LatLng> playerLatLng = List();
  List<LatLng> dashedLatLng = List();
  LatLng playerPosition = LatLng(63.836436, 20.314299);
  LatLng teePosition = LatLng(63.836436, 20.314299);
  LatLng goalPosition = LatLng(63.836826, 20.314299);
  LatLng northEast;
  LatLng southWest;
  BitmapDescriptor goalIcon;
  BitmapDescriptor teeIcon;
  BitmapDescriptor discLandingMarkerIcon;
  Timer timer;
  String distanceToGoal = "";
  bool throwsVisible = false;

  @override
  void initState() {
    super.initState();
    _geolocator = Geolocator();
    _position = Position(latitude: 63.836711, longitude: 20.313654);

    playerMarker = Marker(
        markerId: MarkerId("Player Location"),
        anchor: const Offset(0.5, 0.5),
        icon: discLandingMarkerIcon,
        position: playerPosition);
    markers.add(playerMarker);
    LocationOptions locationOptions =
        LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 0);

    checkPermission();
    calculateCameraPosition();

    BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(40, 40)),
            'assets/images/icon_goal.png')
        .then((onValue) {
      goalIcon = onValue;
      _loadGoalMarker();
    });
    BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(40, 40)),
            'assets/images/icon_tee.png')
        .then((onValue) {
      teeIcon = onValue;
      _loadTeeMarker();
    });
    BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(40, 40)),
            'assets/images/icon_disclandingmarker.png')
        .then((onValue) {
      discLandingMarkerIcon = onValue;
    });

    dashedPattern.add(PatternItem.dash(20));
    dashedPattern.add(PatternItem.gap(20));

    // Adding tee to first player position.
    playerLatLng.add(teePosition);
    dashedLatLng.add(goalPosition);
    _loadDistanceLinesDashed();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void updateMapLocation() {
    updateLocation();
    mapController.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: southWest,
          northeast: northEast,
        ),
        32.0,
      ),
    );
  }

  void checkPermission() {
    _geolocator.checkGeolocationPermissionStatus().then((status) {
      print('status: $status');
    });

    _geolocator
        .checkGeolocationPermissionStatus(
            locationPermission: GeolocationPermission.locationAlways)
        .then((status) {
      print('always status: $status');
    });

    _geolocator.checkGeolocationPermissionStatus(
        locationPermission: GeolocationPermission.locationWhenInUse)
      ..then((status) {
        print('whenInUse status: $status');
      });
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
    mapController = controller;
    //timer =
    //    Timer.periodic(Duration(seconds: 2), (Timer t) => updateMapLocation());
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return new Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            polylines: polylines,
            markers: markers,
            onMapCreated: _onMapCreated,
            myLocationEnabled: false,
            initialCameraPosition: CameraPosition(
              target: LatLng(_position.latitude, _position.longitude),
              zoom: 18.0,
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              width: width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ButtonTheme(
                    minWidth: 60.0,
                    height: 40.0,
                    buttonColor: accentColor,
                    child: RaisedButton(
                      onPressed: () { toggleThrowsList(); },
                      child: Text("Kast"),
                    ),
                  ),
                  IconButton(
                      iconSize: 60,
                      padding: const EdgeInsets.all(2),
                      icon: Image.asset(
                          "assets/images/button_removelanding.png",
                          height: 80,
                          width: 80),
                      onPressed: () {
                        removeDiscLanding();
                      }),
                  IconButton(
                      iconSize: 80,
                      padding: const EdgeInsets.all(2),
                      icon: Image.asset("assets/images/button_marklanding.png",
                          height: 100, width: 100),
                      onPressed: () {
                        markDiscLanding();
                      }),
                  IconButton(
                      iconSize: 60,
                      padding: const EdgeInsets.all(2),
                      icon: Image.asset("assets/images/button_markgoal.png",
                          height: 80, width: 80),
                      onPressed: () {
                        // markGoal
                      }),
                  Container(
                    height: 40,
                    width: 60,
                    color: accentColor,
                    child: Center(
                      child: Text(
                        "190m",
                        style:
                            TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            bottom: 100,
            child: Visibility(
              visible: throwsVisible,
              child: Container(
                width: 100,
                height: 4000,
                child: ListView.separated(
                    reverse: true,
                    padding: const EdgeInsets.all(8),
                    itemCount: throwLengths.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        height: 30,
                        padding: const EdgeInsets.all(4),
                        color: accentColor,
                        child: Text(
                          '${index + 1}: ${throwLengths[index]}m',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) =>
                        const Divider(
                          height: 5,
                          thickness: 2,
                        )),
              ),
            ),
          )
        ],
      ),
    );
  }

  void toggleThrowsList() {
    setState(() {
      throwsVisible = !throwsVisible;
    });
  }

  void markDiscLanding() {
    LatLng origin = playerLatLng.last;
    playerLatLng.add(LatLng(_position.latitude, _position.longitude));
    setState(() {
      playerPolyline = Polyline(
        polylineId: PolylineId("Player Polyline"),
        visible: true,
        points: playerLatLng,
        color: accentColor,
        width: 4,
      );
      polylines.add(playerPolyline);
      dashedLatLng.removeLast();
      dashedLatLng.add(playerLatLng.last);
      polylines.remove(dashedPolyline);
      dashedPolyline = (Polyline(
        polylineId: PolylineId("DistanceDashPoly".toString()),
        visible: true,
        points: dashedLatLng,
        patterns: dashedPattern,
        color: accentColor,
        width: 2,
      ));
      polylines.add(dashedPolyline);
      discLandingMarkers.add(Marker(
          markerId: MarkerId(discLandingIndex.toString()),
          infoWindow: InfoWindow(title: "Kast"),
          anchor: const Offset(0.5, 0.5),
          icon: discLandingMarkerIcon,
          position: playerLatLng.last));
      markers.add(discLandingMarkers.last);
    });
    loadThrowDistance(origin, playerLatLng.last);
    discLandingIndex++;
  }

  void loadThrowDistance(LatLng from, LatLng to) async {
    double distanceInMeters = await Geolocator().distanceBetween(
        from.latitude, from.longitude, to.latitude, to.longitude);
    throwLengths.add(distanceInMeters.toStringAsFixed(0));
  }

  void removeDiscLanding() {
    if (discLandingIndex > 0) {
      playerLatLng.removeLast();
      setState(() {
        polylines.remove(playerPolyline);
        dashedLatLng.removeLast();
        dashedLatLng.add(playerLatLng.last);
        polylines.remove(dashedPolyline);
        playerPolyline = Polyline(
          polylineId: PolylineId("Player Polyline"),
          visible: true,
          points: playerLatLng,
          color: accentColor,
          width: 4,
        );
        polylines.add(playerPolyline);
        dashedPolyline = (Polyline(
          polylineId: PolylineId("DistanceDashPoly".toString()),
          visible: true,
          points: dashedLatLng,
          patterns: dashedPattern,
          color: accentColor,
          width: 2,
        ));
        polylines.add(dashedPolyline);
        markers.remove(discLandingMarkers.last);
        discLandingMarkers.removeLast();
      });
      discLandingIndex--;
    }
    throwLengths.removeLast();
  }

  void _loadTeeMarker() {
    setState(() {
      markers.add(Marker(
          markerId: MarkerId("tee"),
          infoWindow: InfoWindow(title: "Utslagsplats", snippet: 'Hål 3'),
          icon: teeIcon,
          position: teePosition));
    });
  }

  void _loadGoalMarker() {
    setState(() {
      markers.add(Marker(
          markerId: MarkerId("goal"),
          infoWindow: InfoWindow(title: "Mål", snippet: 'Hål 3'),
          icon: goalIcon,
          position: goalPosition));
    });
  }

  void updateDistanceToGoal() async {
    LatLng from = playerLatLng.last;
    LatLng to = goalPosition;
    double distanceInMeters = await Geolocator().distanceBetween(
        from.latitude, from.longitude, to.latitude, to.longitude);
    setState(() {
      distanceToGoal = distanceInMeters.toStringAsFixed(0) + "m";
    });
  }

  void updateLocation() async {
    try {
      Position newPosition = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
          .timeout(new Duration(seconds: 5));

      setState(() {
        _position = newPosition;
        playerPosition = LatLng(newPosition.latitude, newPosition.longitude);
        updatePlayerMarker(playerPosition);
      });
    } catch (e) {
      print('Error: ${e.toString()}');
    }
  }

  void _loadDistanceLinesDashed() {
    dashedLatLng.add(playerLatLng[0]);
    dashedPolyline = (Polyline(
      polylineId: PolylineId("DistanceDashPoly".toString()),
      visible: true,
      //latlng is List<LatLng>
      points: dashedLatLng,
      patterns: dashedPattern,
      color: Colors.orange,
      width: 2,
    ));
    polylines.add(dashedPolyline);
  }

  void calculateCameraPosition() {
    // Latitud > 0 är uppåt
    // Longitud > 0 är höger
    double deltaLat = teePosition.latitude - goalPosition.latitude;
    double deltaLon = teePosition.longitude - goalPosition.longitude;

    // Mål är norr om tee
    if (deltaLat <= 0) {
      // Mål är höger om tee
      if (deltaLon <= 0) {
        southWest = teePosition;
        northEast = goalPosition;
        // Mål är vänster om tee
      } else {
        southWest = LatLng(teePosition.latitude, goalPosition.longitude);
        northEast = LatLng(goalPosition.latitude, teePosition.longitude);
      }

      // Mål är söder om tee
    } else {
      // Mål är höger om tee
      if (deltaLon <= 0) {
        southWest = LatLng(goalPosition.latitude, teePosition.longitude);
        northEast = LatLng(teePosition.latitude, goalPosition.longitude);
        // Mål är vänster om tee
      } else {
        southWest = goalPosition;
        northEast = teePosition;
      }
    }
  }

  void updatePlayerMarker(LatLng position) {
    markers.remove(playerMarker);
    playerMarker = Marker(
        markerId: MarkerId("Player Location"),
        anchor: const Offset(0.5, 0.5),
        icon: discLandingMarkerIcon,
        position: position);
    markers.add(playerMarker);
  }
}
