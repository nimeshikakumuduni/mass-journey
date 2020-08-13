import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:vetaapp/Models/TripData.dart';
import 'package:vetaapp/Models/User.dart';
import 'package:vetaapp/ServerData/ServerData.dart';
import 'package:vetaapp/Widgets/TripShortView.dart';
import 'package:http/http.dart' as http;

class RejectedTripsPage extends StatefulWidget {
  _RejectedTripsPageState createState() => _RejectedTripsPageState();
}

class _RejectedTripsPageState extends State<RejectedTripsPage> {
  List<TripData> rejectedTrips = [];
  bool loading = true;
  @override
  void initState() {
    loadRejectedTrips();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : rejectedTrips.length == 0 ? Center(
            child: RaisedButton(
              child: Text('No Rejected Trips'),
              onPressed: (){
                loadRejectedTrips();
              },
            ),
          ) : ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                return TripShortView(rejectedTrips[index],"rejected");
              },
              itemCount: rejectedTrips.length,
            ),
    );
  }

  loadRejectedTrips() {
    setState(() {
     loading = true; 
    });
    http.post(ServerData.serverUrl + '/getRejectedTrips',
        body: {'empId': User.currentUser.empId}).then((http.Response response) {
      List<dynamic> data = json.decode(response.body);
      List<TripData> tempTrips = [];
      data.forEach((trip) {
        tempTrips.add(TripData(trip));
      });
      rejectedTrips = [];
      if (mounted) {
        setState(() {
          loading = false;
          rejectedTrips = tempTrips;
        });
      }
    });
  }
}
