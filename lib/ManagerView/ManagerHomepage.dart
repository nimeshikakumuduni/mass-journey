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
import 'package:vetaapp/Widgets/ConfirmItem.dart';

class ManagerHomepage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ManagerHomepageState();
  }
}

class _ManagerHomepageState extends State<ManagerHomepage> {
  List<TripData> confirmations = [];
  bool loading = true;
  @override
  void initState() {
    manager = SocketIOManager();
    initSocket();
    loadConfirmations();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: VetaDrawer(),
      appBar: AppBar(
        title: Text("Veta - Manager"),
      ),
      body: RefreshIndicator(
        onRefresh: () {
          return loadConfirmations();
        },
        child: Container(
          child: loading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : confirmations.length == 0
                  ? Center(
                      child: RaisedButton(
                        child: Text("No Confirmations!"),
                        onPressed: () {
                          loadConfirmations();
                        },
                      ),
                    )
                  : ListView.builder(
                      itemBuilder: (context, index) =>
                          Confirmation(confirmations[index], index),
                      itemCount: confirmations.length,
                    ),
        ),
      ),
    );
  }

  Future loadConfirmations() async {
    setState(() {
      loading = true;
    });
    http
        .get(ServerData.serverUrl + '/loadNotApprovedTrips')
        .then((http.Response response) {
      List<dynamic> data = json.decode(response.body);
      List<TripData> temp = [];
      data.forEach((trip) {
        temp.add(TripData(trip));
      });
      if (mounted) {
        setState(() {
          confirmations = temp;
          loading = false;
        });
      }
      return true;
    });
  }

  autoUpdates() {
    socket.on('createRequest', (data) {
      TripData newTrip = TripData(data[0]);
      int index =
          confirmations.indexWhere((trip) => trip.tripId == newTrip.tripId);
      if (index < 0) {
        FlutterRingtonePlayer.playNotification();
        setState(() {
          confirmations.insert(0, newTrip);
        });
      }
    });
  }
}
