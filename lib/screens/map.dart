import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  Geolocator geolocator;
  Position position;

  final Set<Marker> markers = {};
  Marker playerMarker;
  final Set<Polyline> polylines = {};
  final List<Marker> discLandingMarkers = List();
  final List<String> throwLengths = List();
  final List<PatternItem> dashedPattern = List();

  Polyline dashedPolyline;
  Polyline playerPolyline;
  int discLandingIndex = 0;
  List<LatLng> playerLatLng = List();
  List<LatLng> dashedLatLng = List();
  LatLng playerPosition = LatLng(63.836436, 20.314299);
  LatLng teePosition;
  LatLng goalPosition;
  LatLng northEast;
  LatLng southWest;
  BitmapDescriptor goalIcon;
  BitmapDescriptor teeIcon;
  BitmapDescriptor discLandingMarkerIcon;
  BitmapDescriptor playerIcon;
  List<BitmapDescriptor> landingMarkerIcons = List();
  StreamSubscription<Position> positionStream;
  Timer timer;
  String distanceToGoal = "";
  String playerName = "Spelarnamn";
  String holeNumber = "00";
  String par = "3";
  bool throwsVisible = false;

  @override
  void initState() {
    super.initState();
    initIcons();
    geolocator = Geolocator();
    checkPermission();
    position = Position(latitude: 63.836711, longitude: 20.313654);

    playerMarker = Marker(
        markerId: MarkerId("Player Location"),
        anchor: const Offset(0.5, 0.5),
        icon: playerIcon,
        position: playerPosition);
    markers.add(playerMarker);
    LocationOptions locationOptions =
        LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 0);
    positionStream = geolocator
        .getPositionStream(locationOptions)
        .listen((Position position) {
      playerPosition = LatLng(position.latitude, position.longitude);
      updatePlayerMarker(playerPosition);
    });

    dashedPattern.add(PatternItem.dash(20));
    dashedPattern.add(PatternItem.gap(20));

    // Adding tee to first player position.
  }

  void initIcons() {
    for (int i = 0; i < 2; i++) {
      print('assets/images/icon_landingmarker${i + 1}.png');
      BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(60, 60)),
              'assets/images/icon_landingmarker${i + 1}.png')
          .then((onValue) {
        landingMarkerIcons.add(onValue);
      });
    }

    BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(40, 40)),
            'assets/images/icon_playermarker.png')
        .then((onValue) {
      playerIcon = onValue;
    });

    BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(40, 40)),
            'assets/images/icon_goal.png')
        .then((onValue) {
      goalIcon = onValue;
      loadGoalMarker();
    });
    BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(40, 40)),
            'assets/images/icon_tee.png')
        .then((onValue) {
      teeIcon = onValue;
      loadTeeMarker();
    });
    BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(40, 40)),
            'assets/images/icon_disclandingmarker.png')
        .then((onValue) {
      discLandingMarkerIcon = onValue;
    });
  }

  @override
  void dispose() {
    positionStream.cancel();
    super.dispose();
  }

  void checkPermission() {
    geolocator.checkGeolocationPermissionStatus().then((status) {
      print('status: $status');
    });

    geolocator
        .checkGeolocationPermissionStatus(
            locationPermission: GeolocationPermission.locationAlways)
        .then((status) {
      print('always status: $status');
    });

    geolocator.checkGeolocationPermissionStatus(
        locationPermission: GeolocationPermission.locationWhenInUse)
      ..then((status) {
        print('whenInUse status: $status');
      });
  }

  void onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
    mapController = controller;
    loadDistanceLinesDashed();
    loadDistanceToGoal();
    loadCameraPosition();
  }

  void loadArgumentData(Map args) {
    holeNumber = args['hole']['number'];
    par = args['hole']['par'];
    GeoPoint tee = args['hole']['tee'];
    GeoPoint basket = args['hole']['basket'];
    teePosition = LatLng(tee.latitude, tee.longitude);
    goalPosition = LatLng(basket.latitude, basket.longitude);
    playerLatLng.add(teePosition);
    dashedLatLng.add(goalPosition);
    
  }

  @override
  Widget build(BuildContext context) {
    final Map args = ModalRoute.of(context).settings.arguments;
    if (holeNumber == "00") {
      loadArgumentData(args);
    }

    var width = MediaQuery.of(context).size.width;

    return new Scaffold(
      appBar: AppBar(
        title: Text(
          "$playerName, Hål $holeNumber, Par $par",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            (holeNumber != "00") ? GoogleMap(
              polylines: polylines,
              markers: markers,
              onMapCreated: onMapCreated,
              myLocationEnabled: false,
              mapType: MapType.satellite,
              initialCameraPosition: CameraPosition(
                target: LatLng(position.latitude, position.longitude),
                zoom: 18.0,
              ),
            ) : Container(),
            Positioned(
              bottom: 10,
              child: Container(
                width: width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    ButtonTheme(
                        minWidth: 80.0,
                        height: 50.0,
                        buttonColor: Colors.black,
                        child: RaisedButton(
                            onPressed: () {
                              toggleThrowsList();
                            },
                            child: getButtonText())),
                    IconButton(
                        iconSize: 40,
                        padding: const EdgeInsets.all(2),
                        icon: Image.asset(
                            "assets/images/button_removelanding.png",
                            height: 60,
                            width: 60),
                        onPressed: () {
                          removeDiscLanding();
                        }),
                    IconButton(
                        iconSize: 60,
                        padding: const EdgeInsets.all(2),
                        icon: Image.asset(
                            "assets/images/button_marklanding.png",
                            height: 80,
                            width: 80),
                        onPressed: () {
                          markDiscLanding();
                        }),
                    IconButton(
                        iconSize: 40,
                        padding: const EdgeInsets.all(2),
                        icon: Image.asset("assets/images/button_markgoal.png",
                            height: 60, width: 60),
                        onPressed: () {
                          // markGoal
                        }),
                    Container(
                      height: 50,
                      width: 80,
                      color: Colors.black,
                      child: Center(
                        child: Text(
                          distanceToGoal,
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
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
                          color: Colors.black,
                          child: Text(
                            '${index + 1}: ${throwLengths[index]}m',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: accentColor),
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
      ),
    );
  }

  Widget getButtonText() {
    return (discLandingIndex > 0)
        ? Text(
            "$discLandingIndex. ${throwLengths[discLandingIndex - 1]}m",
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: accentColor),
          )
        : Text(
            "Kast",
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: accentColor),
          );
  }

  void toggleThrowsList() {
    setState(() {
      throwsVisible = !throwsVisible;
    });
  }

  void markDiscLanding() {
    LatLng origin = playerLatLng.last;
    playerLatLng.add(LatLng(playerPosition.latitude, playerPosition.longitude));
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
        color: Colors.white,
        width: 2,
      ));
      polylines.add(dashedPolyline);
      discLandingMarkers.add(Marker(
          markerId: MarkerId(discLandingIndex.toString()),
          infoWindow: InfoWindow(title: "Kast ${discLandingIndex + 1}"),
          anchor: const Offset(0.5, 0.5),
          icon: landingMarkerIcons[discLandingIndex],
          position: playerLatLng.last));
      markers.add(discLandingMarkers.last);
    });
    loadThrowDistance(origin, playerLatLng.last);
    loadDistanceToGoal();
  }

  void loadThrowDistance(LatLng from, LatLng to) async {
    double distanceInMeters = await Geolocator()
        .distanceBetween(
            from.latitude, from.longitude, to.latitude, to.longitude)
        .then((onValue) {
      discLandingIndex++;
      return onValue;
    });
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
          color: Colors.white,
          width: 2,
        ));
        polylines.add(dashedPolyline);
        markers.remove(discLandingMarkers.last);
        discLandingMarkers.removeLast();
      });
      discLandingIndex--;
    }
    throwLengths.removeLast();
    loadDistanceToGoal();
  }

  void loadTeeMarker() {
    setState(() {
      markers.add(Marker(
          markerId: MarkerId("tee"),
          infoWindow:
              InfoWindow(title: "Utslagsplats", snippet: 'Hål $holeNumber'),
          icon: teeIcon,
          position: teePosition));
    });
  }

  void loadGoalMarker() {
    setState(() {
      markers.add(Marker(
          markerId: MarkerId("goal"),
          infoWindow: InfoWindow(title: "Mål", snippet: 'Hål $holeNumber'),
          icon: goalIcon,
          position: goalPosition));
    });
  }

  void loadDistanceToGoal() async {
    LatLng from = playerLatLng.last;
    LatLng to = goalPosition;
    double distanceInMeters = await Geolocator().distanceBetween(
        from.latitude, from.longitude, to.latitude, to.longitude);
    setState(() {
      distanceToGoal = distanceInMeters.toStringAsFixed(0) + "m";
    });
  }

  void loadDistanceLinesDashed() {
    dashedLatLng.add(playerLatLng[0]);
    dashedPolyline = (Polyline(
      polylineId: PolylineId("DistanceDashPoly".toString()),
      visible: true,
      //latlng is List<LatLng>
      points: dashedLatLng,
      patterns: dashedPattern,
      color: Colors.white,
      width: 2,
    ));
    polylines.add(dashedPolyline);
  }

  void loadCameraPosition() async {
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

    southWest = LatLng(southWest.latitude - (10 / 111111), southWest.longitude);
    await mapController.getVisibleRegion();
    mapController.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: southWest,
          northeast: northEast,
        ),
        64.0,
      ),
    );
  }

  void updatePlayerMarker(LatLng position) {
    setState(() {
      markers.remove(playerMarker);
      playerMarker = Marker(
          markerId: MarkerId("Player Location"),
          anchor: const Offset(0.5, 0.5),
          icon: playerIcon,
          position: position);

      markers.add(playerMarker);
    });
  }
}
