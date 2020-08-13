import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:vetaapp/Models/TripData.dart';
import 'package:vetaapp/Models/User.dart';
import 'package:vetaapp/ServerData/ServerData.dart';
import 'package:vetaapp/Widgets/TripShortView.dart';
import 'package:http/http.dart' as http;

class AcceptedTripsPage extends StatefulWidget {
  _AcceptedTripsPageState createState() => _AcceptedTripsPageState();
}

class _AcceptedTripsPageState extends State<AcceptedTripsPage> {
  @override
  void initState() {
    loadAcceptedTrips();
    super.initState();
  }

  List<TripData> acceptedTrips = [];
  bool loading = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : acceptedTrips.length == 0 ? Center(
            child: RaisedButton(
              child: Text('No Accepted Trips'),
              onPressed: (){
                loadAcceptedTrips();
              },
            ),
          ): ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                return TripShortView(acceptedTrips[index],"accept");
              },
              itemCount: acceptedTrips.length,
            ),
    );
  }

  loadAcceptedTrips() {
    setState(() {
     loading = true; 
    });
    http.post(ServerData.serverUrl + '/getAcceptedTrips',
        body: {'empId': User.currentUser.empId}).then((http.Response response) {
      List<dynamic> data = json.decode(response.body);
      List<TripData> tempTrips = [];
      data.forEach((trip) {
        tempTrips.add(TripData(trip));
      });
      acceptedTrips = [];
      if (mounted) {
        setState(() {
          loading = false;
          acceptedTrips = tempTrips;
        });
      }
    });
  }
}
