import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:vetaapp/Models/TripData.dart';
import 'package:vetaapp/Models/User.dart';
import 'package:vetaapp/ServerData/ServerData.dart';
import 'package:vetaapp/Widgets/TripShortView.dart';
import 'package:http/http.dart' as http;

class PastTripsPage extends StatefulWidget {
  _PastTripsPageState createState() => _PastTripsPageState();
}

class _PastTripsPageState extends State<PastTripsPage> {
  bool loading = true;
  List<TripData> pastTrips = [];
  @override
  void initState() {
    loadPastTrips();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: loading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : pastTrips.length == 0 ? Center(
            child: RaisedButton(
              child: Text('No Past Trips'),
              onPressed: (){
                loadPastTrips();
              },
            ),
          ): ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                return TripShortView(pastTrips[index],"past");
              },
              itemCount: pastTrips.length,
            ),
    );
  }

  loadPastTrips() {
    setState(() {
     loading = true; 
    });
    http.post(ServerData.serverUrl + '/getPastTrips',
        body: {'empId': User.currentUser.empId}).then((http.Response response) {
      List<dynamic> data = json.decode(response.body);
      List<TripData> tempTrips = [];
      data.forEach((trip) {
        tempTrips.add(TripData(trip));
      });
      pastTrips = [];

      if (mounted) {
        setState(() {
          loading = false;
          pastTrips = tempTrips;
        });
      }
    });
  }
}
