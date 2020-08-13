import 'dart:convert';
import 'package:adhara_socket_io/manager.dart';
import 'package:adhara_socket_io/options.dart';
import 'package:adhara_socket_io/socket.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:vetaapp/CommonViews/Drawer.dart';
import 'package:vetaapp/Models/TripData.dart';
import 'package:http/http.dart' as http;
import 'package:vetaapp/ServerData/ServerData.dart';
import 'package:vetaapp/Widgets/TMConfirmItem.dart';

class TransportManagerHome extends StatefulWidget {
  @override
  _TransportManagerHomeState createState() => _TransportManagerHomeState();
}

class _TransportManagerHomeState extends State<TransportManagerHome> {
  List<TripData> notConfirmedTrips = [];
  bool loading = true;
  @override
  void initState() {
    loadNotConfirmedTrips();
    manager = SocketIOManager();
    initSocket();
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
    socket.on('confirmTrip', (data) {
      TripData newTrip = TripData(data[0]);
      if (notConfirmedTrips
              .indexWhere((trip) => trip.tripId == newTrip.tripId) <
          0) {
        setState(() {
          FlutterRingtonePlayer.playNotification();
          notConfirmedTrips.insert(0, newTrip);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Veta - Transport Manager"),
      ),
      drawer: VetaDrawer(),
      body: RefreshIndicator(
        onRefresh: () {
          return loadNotConfirmedTrips();
        },
        child: Container(
          child: loading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : notConfirmedTrips.length == 0
                  ? Center(
                      child: RaisedButton(
                        child: Text("No Confirmations!"),
                        onPressed: () {
                          loadNotConfirmedTrips();
                        },
                      ),
                    )
                  : ListView.builder(
                      itemBuilder: (context, index) =>
                          TMConfirmation(notConfirmedTrips[index], index),
                      itemCount: notConfirmedTrips.length,
                    ),
        ),
      ),
    );
  }

  Future loadNotConfirmedTrips() async {
    setState(() {
      loading = true;
    });
    http
        .get(ServerData.serverUrl + '/getNotConfirmedTrips')
        .then((http.Response response) {
      List<dynamic> data = json.decode(response.body);
      List<TripData> temp = [];
      data.forEach((trip) {
        temp.add(TripData(trip));
      });
      if (mounted) {
        setState(() {
          loading = false;
          notConfirmedTrips = temp;
        });
      }
      return true;
    });
  }
}
