import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vetaapp/Widgets/AppBarTitle.dart';


class MapSample extends StatefulWidget {
  final String type;
  MapSample(this.type);
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  CameraPosition _initialPosition =
      CameraPosition(target: LatLng(6.9270, 79.8612),zoom: 9);
  Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = Set();
  LatLng selected;

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  // Future<void> gotoPosition() async {
  //   double lat = 40.7128;
  //   double long = -74.0060;
  //   GoogleMapController controller = await _controller.future;
  //   controller
  //       .animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, long), _zoom));
  //   setState(() {
  //     _markers.add(
  //       Marker(
  //           markerId: MarkerId('newyork'),
  //           position: LatLng(lat, long),
  //           infoWindow:
  //               InfoWindow(title: 'New York', snippet: 'Welcome to New York'),
  //           draggable: true),
  //     );
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppBarTitle('Select '+widget.type+' Location'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.done),
            onPressed: (){
              if(_markers.length == 1){
                Navigator.pop(context,selected);
              }
            },
          )
        ],
      ),
      
      body: Container(
        child: Stack(
          children: <Widget>[
            GoogleMap(
              initialCameraPosition: _initialPosition,
              onMapCreated: _onMapCreated,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              markers: _markers,
              zoomGesturesEnabled: true,

              onTap: (latlang) {
                if (_markers.length >= 1) {
                  _markers.clear();
                }
                _onAddMarkerButtonPressed(latlang);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _onAddMarkerButtonPressed(LatLng latlang) {
    setState(() {
      selected = latlang;
      _markers.add(Marker(
        markerId: MarkerId(DateTime.now().millisecondsSinceEpoch.toString()),
        position: latlang,
        infoWindow: InfoWindow(
          title: widget.type +" Location",
        ),
        icon: BitmapDescriptor.defaultMarker,
      ));
    });
  }
}
