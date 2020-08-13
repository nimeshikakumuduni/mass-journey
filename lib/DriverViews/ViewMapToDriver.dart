import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:slider_button/slider_button.dart';
import 'package:vetaapp/Models/TripData.dart';
import 'package:vetaapp/ServerData/ServerData.dart';

class ViewMapToDriver extends StatefulWidget {
  final TripData trip;
  final LatLng pickup;
  final LatLng destination;
  ViewMapToDriver(this.pickup, this.destination, this.trip);
  @override
  _ViewMapToDriverState createState() => _ViewMapToDriverState();
}

class _ViewMapToDriverState extends State<ViewMapToDriver> {
  CameraPosition _initialPosition;
  Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = Set();

  var geolocator = Geolocator();
  var locationOptions =
      LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);
  Timer timer;
  Uint8List markerIcon;
  bool endLoading = false;

  @override
  void initState() {
    loadImage();
    locationStream();
    timer = Timer.periodic(Duration(seconds: 5),
        (Timer t) => !endLoading ? locationStream() : () {});
    _initialPosition = CameraPosition(target: widget.pickup, zoom: 9);
    _markers.add(
      Marker(
          position: widget.pickup,
          markerId: MarkerId("1"),
          infoWindow: InfoWindow(title: "Pickup Location"),
          icon: BitmapDescriptor.defaultMarkerWithHue(220)),
    );
    _markers.add(
      Marker(
          position: widget.destination,
          markerId: MarkerId("2"),
          infoWindow: InfoWindow(title: "Destination Location")),
    );

    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  locationStream() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    double lat = position.latitude, long = position.longitude;
    print("latitude = " + lat.toString() + " Longitude = " + long.toString());

    ServerData.socket.emit("updateDriverLocation", [
      {
        'tripId': widget.trip.tripId.toString(),
        'dEmpId': widget.trip.dEmpId.toString(),
        'latitude': lat.toString(),
        'longitude': long.toString()
      }
    ]);
    GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, long), 10));
    Marker newMarker = Marker(
      markerId: MarkerId('My Location'),
      position: LatLng(lat, long),
      draggable: true,
      icon: BitmapDescriptor.fromBytes(markerIcon),
    );
    if (mounted) {
      setState(() {
        _markers.removeWhere((test) => test.markerId == newMarker.markerId);
        _markers.add(newMarker);
      });
    }
  }

  loadImage() async {
    markerIcon = await getBytesFromAsset('assets/car.png', 50);
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

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trip Started'),
      ),
      body: Stack(
        children: <Widget>[
          Column(
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
              Container(
                margin: EdgeInsets.all(10),
                child: SliderButton(
                  buttonColor: Colors.red,
                  
                  label: Text(
                    "Slide to end trip",
                    style: TextStyle(
                        color: Color(0xff4a4a4a),
                        fontWeight: FontWeight.w500,
                        fontSize: 17),
                  ),
                  icon: Center(
                    child: Icon(
                      Icons.directions_car,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                  action: () {
                    endTrip(widget.trip);
                  },
                ),
              )
            ],
          ),
          endLoading
              ? Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : Container()
        ],
      ),
    );
  }

  endTrip(TripData trip) {
    setState(() {
      endLoading = true;
    });
    ServerData.socket.emitWithAck('endTrip', [
      {
        'tripId': trip.tripId.toString(),
        'vehicleId': trip.vehicleId.toString(),
        'dEmpId': trip.dEmpId
      }
    ]).then((onValue) {
      print(onValue);
      if (onValue[0]['status'] == "success") {
        setState(() {
          endLoading = false;
        });
        Navigator.pushReplacementNamed(context, '/driverHome');
      }
    });
  }
}
