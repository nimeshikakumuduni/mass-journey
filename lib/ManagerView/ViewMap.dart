import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

class ViewMap extends StatefulWidget {
  final LatLng pickup;
  final LatLng destination;
  ViewMap(this.pickup, this.destination);
  @override
  _ViewMapState createState() => _ViewMapState();
}

class _ViewMapState extends State<ViewMap> {
  CameraPosition _initialPosition;
  Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = Set();

  @override
  void initState() {
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

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trip Details..'),
      ),
      body: Column(
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
          )
        ],
      ),
    );
  }
}
