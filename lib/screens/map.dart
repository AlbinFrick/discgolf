import 'dart:async';
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
  final Set<Marker> _markers = {};
  final Set<Marker> distanceMarkers = {};
  final Set<Polyline> _polyline = {};

  //add your lat and lng where you wants to draw polyline

  List<LatLng> latlng = List();
  LatLng teePosition = LatLng(63.836436, 20.314299);
  LatLng goalPosition = LatLng(63.836826, 20.313357);
  BitmapDescriptor goalIcon;
  BitmapDescriptor teeIcon;
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

    latlng.add(teePosition);

    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(size: Size(2, 2)), 'assets/images/icon_goal.png')
        .then((onValue) {
      goalIcon = onValue;
      _loadGoalMarker();
    });
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(size: Size(2, 2)), 'assets/images/icon_tee.png')
        .then((onValue) {
      teeIcon = onValue;
      _loadTeeMarker();
    });
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
          zoom: 17.0,
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
          polylines: _polyline,
          markers: _markers,
          onMapCreated: _onMapCreated,
          myLocationEnabled: true,
          initialCameraPosition: CameraPosition(
            target: LatLng(_position.latitude, _position.longitude),
            zoom: 17.0,
          ),
          mapType: MapType.normal,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _onAddMarkerButtonPressed();
          },
          child: Icon(Icons.add, semanticLabel: 'Action'),
          backgroundColor: Colors.black87,
        ),
      ),
    );
  }

  void _onAddMarkerButtonPressed() {
    List<PatternItem> patterns = List();
    patterns.add(PatternItem.dash(20));
    patterns.add(PatternItem.gap(10));
    patterns.add(PatternItem.dot);
    latlng.add(LatLng(_position.latitude, _position.longitude));
    setState(() {
      _polyline.add(Polyline(
        polylineId: PolylineId(_position.toString()),
        visible: true,
        //latlng is List<LatLng>
        patterns: patterns,
        points: latlng,
        color: Colors.red,
        width: 2,
      ));
    });
  }

  void _loadTeeMarker() {
    setState(() {
      _markers.add(Marker(
          markerId: MarkerId("tee"),
          infoWindow: InfoWindow(title: "Utslagsplats", snippet: 'Hål 3'),
          icon: teeIcon,
          position: teePosition));
    });
  }

  void _loadGoalMarker() {
    setState(() {
      _markers.add(Marker(
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
}
