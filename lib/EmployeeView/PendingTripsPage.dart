import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:vetaapp/Models/TripData.dart';
import 'package:vetaapp/Models/User.dart';
import 'package:vetaapp/ServerData/ServerData.dart';
import 'package:vetaapp/Widgets/TripShortView.dart';
import 'package:http/http.dart' as http;

class PendingTripsPage extends StatefulWidget {
  _PendingTripsPageState createState() => _PendingTripsPageState();
}

class _PendingTripsPageState extends State<PendingTripsPage> {
  List<TripData> pendingTrips = [];
  bool loading = true;
  @override
  void initState() {
    loadPendingTrips();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : pendingTrips.length == 0 ? Center(
            child: RaisedButton(
              child: Text('No Pending Trips'),
              onPressed: (){
                loadPendingTrips();
              },
            ),
          ) : ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                return TripShortView(pendingTrips[index],"pending");
              },
              itemCount: pendingTrips.length,
            ),
    );
  }

  loadPendingTrips() {
    setState(() {
     loading = true; 
    });
    http.post(ServerData.serverUrl + '/getPendingTrips',
        body: {'empId': User.currentUser.empId}).then((http.Response response) {
      List<dynamic> data = json.decode(response.body);
      List<TripData> tempTrips = [];
      data.forEach((trip) {
        tempTrips.add(TripData(trip));
      });
      pendingTrips = [];
      if (mounted) {
        setState(() {
          loading = false;
          pendingTrips = tempTrips;
        });
      }
    });
  }
}
