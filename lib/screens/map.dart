import 'dart:async';
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

  static const LatLng _center = const LatLng(63.836711, 20.313654);
  final Set<Marker> markers = {};
  final Set<Polyline> polylines = {};
  final List<Marker> discLandingMarkers = List();

  final List<PatternItem> dashedPattern = List();
  //add your lat and lng where you wants to draw polyline
<<<<<<< HEAD
  
  Polyline dashedPolyline;
  int discLandingIndex = 0;
  List<LatLng> playerLatLng = List();
  List<LatLng> dashedLatLng = List();
=======

  List<LatLng> latlng = List();
>>>>>>> dcaa971160b47373ab330b4381d426cf28aecce0
  LatLng teePosition = LatLng(63.836436, 20.314299);
  LatLng goalPosition = LatLng(63.836826, 20.313357);
  BitmapDescriptor goalIcon;
  BitmapDescriptor teeIcon;
  BitmapDescriptor discLandingMarkerIcon;
  Timer timer;

  @override
  void initState() {
    super.initState();
    _geolocator = Geolocator();
    _position = Position(latitude: 63.836711, longitude: 20.313654);
    LocationOptions locationOptions =
        LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 0);

    checkPermission();
    StreamSubscription positionStream = _geolocator
        .getPositionStream(locationOptions)
        .listen((Position position) {});
    timer =
        Timer.periodic(Duration(seconds: 2), (Timer t) => updateMapLocation());
    
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(size: Size(40, 40)), 'assets/images/icon_goal.png')
        .then((onValue) {
      goalIcon = onValue;
      _loadGoalMarker();
    });
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(size: Size(40, 40)), 'assets/images/icon_tee.png')
        .then((onValue) {
      teeIcon = onValue;
      _loadTeeMarker();
    });
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(size: Size(40, 40)), 'assets/images/icon_disclandingmarker.png')
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
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(_position.latitude, _position.longitude),
          zoom: 18.0,
        ),
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
    
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Maps Sample App'),
          backgroundColor: Colors.green[700],
        ),
        body: GoogleMap(
          polylines: polylines,
          markers: markers,
          onMapCreated: _onMapCreated,
          myLocationEnabled: true,
          initialCameraPosition: CameraPosition(
            target: LatLng(_position.latitude, _position.longitude),
            zoom: 18.0,
          ),
          mapType: MapType.normal,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            markDiscLanding();
          },
          child: Icon(Icons.add, semanticLabel: 'Action'),
          backgroundColor: Colors.black87,
        ),
      ),
    );
  }

  void markDiscLanding() {
    playerLatLng.add(LatLng(_position.latitude,_position.longitude));
    setState(() {
      polylines.add(Polyline(
        polylineId: PolylineId("PolyID"),
        visible: true,
        points: playerLatLng,
        color: accentColor,
        width: 4,
      ));
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
    discLandingIndex++;
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

  void updateLocation() async {
    try {
      Position newPosition = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
          .timeout(new Duration(seconds: 5));

      setState(() {
        _position = newPosition;
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

}
