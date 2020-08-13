import 'dart:convert';

import 'package:adhara_socket_io/manager.dart';
import 'package:adhara_socket_io/options.dart';
import 'package:adhara_socket_io/socket.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vetaapp/CommonViews/Drawer.dart';
import 'package:http/http.dart' as http;
import 'package:vetaapp/Messages/Messages.dart';
import 'package:vetaapp/Models/TripData.dart';
import 'package:vetaapp/Models/User.dart';
import 'package:vetaapp/ServerData/ServerData.dart';
import 'package:vetaapp/Widgets/TripItemForDriver.dart';

class DriverHomePage extends StatefulWidget {
  @override
  _DriverHomePageState createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  bool loadingTrips = true;
  List<TripData> availableTrips = [];
  @override
  void initState() {
    manager = SocketIOManager();
    initSocket();
    loadTrips();
    checkForLocationService();
    super.initState();
  }

  SocketIOManager manager;
  SocketIO socket;
  initSocket() async {
    print("init socket");
    socket = await manager.createInstance(SocketOptions(ServerData.serverUrl,
        nameSpace: "/",
        enableLogging: false,
        transports: [Transports.WEB_SOCKET]));
    ServerData.socket = socket;
    autoUpdates();
    socket.connect();
  }

  autoUpdates() {
    socket.on('confirmTripByTM', (data) {
      TripData newTrip = TripData(data);
      if (newTrip.dEmpId == User.currentUser.empId &&
          availableTrips.indexWhere((trip) => trip.tripId == newTrip.tripId) <
              0) {
        FlutterRingtonePlayer.playNotification();
        if (mounted) {
          setState(() {
            availableTrips.insert(0, newTrip);
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Veta - Driver'),
      ),
      drawer: VetaDrawer(),
      body: RefreshIndicator(
        onRefresh: () {
          return loadTrips();
        },
        child: Container(
          height: double.infinity,
          width: double.infinity,
          child: loadingTrips
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : availableTrips.length == 0
                  ? Center(
                      child: RaisedButton(
                        child: Text("No Available Trips"),
                        onPressed: () {
                          loadTrips();
                        },
                      ),
                    )
                  : Container(
                      child: Column(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.all(5),
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.green),
                                borderRadius: BorderRadius.circular(5)),
                            child: Text("Available Trips"),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemBuilder: (context, index) =>
                                  TripItemForDriver(
                                      availableTrips[index], index),
                              itemCount: availableTrips.length,
                            ),
                          ),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }

  Future loadTrips() async {
    setState(() {
      loadingTrips = true;
    });
    await http.post(ServerData.serverUrl + '/loadTripsForDriver', body: {
      'dEmpId': User.currentUser.empId
    }).then((http.Response response) {
      List<dynamic> trips = json.decode(response.body);
      availableTrips = [];
      trips.forEach((trip) {
        availableTrips.add(TripData(trip));
      });
      setState(() {
        loadingTrips = false;
      });
      return true;
    });
  }

  checkForLocationService() async {
    GeolocationStatus geolocationStatus =
        await Geolocator().checkGeolocationPermissionStatus();
    if (geolocationStatus != GeolocationStatus.granted) {
      Messages.simpleMessageOpenLocation(
          context: context,
          head: "Location services disabled",
          body:
              'Enable location services for this App using the device settings.');
    }
  }
}
