import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vetaapp/Models/TripData.dart';
import 'package:vetaapp/ServerData/ServerData.dart';
import 'package:vetaapp/Widgets/AppBarTitle.dart';

class MapOnEmployee extends StatefulWidget {
  final TripData trip;
  MapOnEmployee(this.trip);
  @override
  State<MapOnEmployee> createState() => MapOnEmployeeState();
}

class MapOnEmployeeState extends State<MapOnEmployee> {
  LatLng pickup;
  LatLng destination;
  CameraPosition _initialPosition;
  Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = Set();
  GoogleMapController controller;
  Uint8List markerIcon;
  @override
  void initState() {
    autoUpdates();
    loadImage();
    pickup = LatLng(widget.trip.pickLati, widget.trip.pickLong);
    destination = LatLng(widget.trip.destiLati, widget.trip.destiLong);
    _initialPosition = CameraPosition(target: pickup, zoom: 9);
    _markers.add(
      Marker(
          position: pickup,
          markerId: MarkerId("1"),
          infoWindow: InfoWindow(title: "Pickup Location"),
          icon: BitmapDescriptor.defaultMarkerWithHue(220)),
    );
    _markers.add(
      Marker(
          position: destination,
          markerId: MarkerId("2"),
          infoWindow: InfoWindow(title: "Destination Location")),
    );
    super.initState();
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  autoUpdates() async {
    controller = await _controller.future;
    ServerData.socket.on('updateDriverLocation', (data) {
      DriverLocation newLocation = DriverLocation(data);
      if (widget.trip.tripId == newLocation.tripId &&
          widget.trip.dEmpId == newLocation.dEmpId) {
        controller.animateCamera(CameraUpdate.newLatLngZoom(
            LatLng(newLocation.latitude, newLocation.longitude), 12));
        Marker newMarker = Marker(
          markerId: MarkerId('My Location'),
          position: LatLng(newLocation.latitude, newLocation.longitude),
          draggable: true,
          icon: BitmapDescriptor.fromBytes(markerIcon),
          infoWindow: InfoWindow(title: widget.trip.firstName+' '+widget.trip.lastName,snippet: widget.trip.vehicleNumber)
        );
        if (mounted) {
          setState(() {
            _markers.removeWhere((test) => test.markerId == newMarker.markerId);
            _markers.add(newMarker);
          });
        }
      }
    });
  }

  loadImage() async {
    markerIcon = await getBytesFromAsset('assets/car.png', 70);
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        .buffer
        .asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              ServerData.socket.off('updateDriverLocation');
              Navigator.pushReplacementNamed(context, '/empHome');
            }),
        title: AppBarTitle('Track Vehicle'),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Card(
              child: Container(
                padding: EdgeInsets.all(10),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.radio_button_checked,
                      color: Colors.blue,
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Text("Pickup"),
                    Expanded(
                      child: SizedBox(),
                    ),
                    Icon(
                      Icons.radio_button_checked,
                      color: Colors.red,
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Text("Destination")
                  ],
                ),
              ),
            ),
            Expanded(
              child: GoogleMap(
                initialCameraPosition: _initialPosition,
                onMapCreated: _onMapCreated,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                markers: _markers,
                zoomGesturesEnabled: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DriverLocation {
  String dEmpId;
  int tripId;
  double latitude, longitude;
  DriverLocation(data) {
    this.dEmpId = data['dEmpId'];
    this.tripId = int.parse(data['tripId'].toString());
    this.latitude = double.parse(data['latitude'].toString());
    this.longitude = double.parse(data['longitude'].toString());
  }
}
