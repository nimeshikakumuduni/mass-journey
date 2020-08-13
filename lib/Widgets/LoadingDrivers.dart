import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vetaapp/Models/TripData.dart';
import 'package:http/http.dart' as http;
import 'package:vetaapp/ServerData/ServerData.dart';
import 'package:vetaapp/Widgets/ProfilePictOnCircleAvatar.dart';

class LoadingDrivers extends StatefulWidget {
  final TripData trip;
  LoadingDrivers(this.trip);
  @override
  _LoadingDriversState createState() => _LoadingDriversState();
}

class _LoadingDriversState extends State<LoadingDrivers> {
  bool driversLoading = true;
  List<Driver> drivers = [];
  @override
  void initState() {
    loadDrivers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return driversLoading
        ? Container(
            color: Colors.black26,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : drivers.length == 0
            ? Container(
                child: Center(
                  child: Text("No Available Drivers"),
                ),
              )
            : Container(
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        "Available Drivers",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemBuilder: (context, index) =>
                            driverItem(drivers[index]),
                        itemCount: drivers.length,
                      ),
                    )
                  ],
                ),
              );
  }

  loadDrivers() {
    setState(() {
      driversLoading = true;
    });
    http
        .get(ServerData.serverUrl + '/loadFreeDrivers')
        .then((http.Response response) {
      List<dynamic> tempDrivers = json.decode(response.body);
      tempDrivers.forEach((driver) {
        drivers.add(Driver(driver));
      });
      setState(() {
        driversLoading = false;
      });
    });
  }

  driverItem(Driver driver) {
    return Card(
      elevation: 10,
      margin: EdgeInsets.only(left: 10, right: 10, top: 5),
      child: ListTile(
        leading: ProfilePictOnCircleAvatar(driver.imageUrl, 20),
        title: Text(driver.fullName),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(
              icon: Icon(
                Icons.list,
                color: Colors.pink,
              ),
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return Container(
                        padding: EdgeInsets.all(5),
                        child: Column(
                          children: <Widget>[
                            ProfilePictOnCircleAvatar(driver.imageUrl, 50),
                            Text(
                              driver.fullName,
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    margin:
                                        EdgeInsets.only(left: 10, right: 10),
                                    height: 1,
                                    color: Colors.black,
                                  ),
                                ),
                                Text("Upcomming Trips"),
                                Expanded(
                                  child: Container(
                                    margin:
                                        EdgeInsets.only(left: 10, right: 10),
                                    height: 1,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            Expanded(
                              child: driver.upcomingTrips.length == 0
                                  ? Center(
                                      child: Text("No Upcomming Trips"),
                                    )
                                  : ListView.builder(
                                      itemBuilder: (context, index) => Card(
                                        elevation: 10,
                                        margin: EdgeInsets.all(5),
                                        child: ListTile(
                                          title: Text(driver
                                                  .upcomingTrips[index]
                                                  .fullName +
                                              '\'s trip'),
                                          subtitle: Text(
                                            DateFormat("EEE, MMM d @ h:mm a")
                                                .format(driver
                                                    .upcomingTrips[index]
                                                    .dateTime),
                                          ),
                                        ),
                                      ),
                                      itemCount: driver.upcomingTrips.length,
                                    ),
                            )
                          ],
                        ),
                      );
                    });
              },
            ),
            IconButton(
              icon: Icon(
                Icons.check_circle,
                color: Colors.green,
              ),
              onPressed: () {
                setState(() {
                  widget.trip.dEmpId = driver.empId;
                  widget.trip.dFullName = driver.fullName;
                });
                Navigator.pop(context);
              },
            )
          ],
        ),
      ),
    );
  }
}

class Driver {
  String fullName, imageUrl, empId;
  List<Trip> upcomingTrips = [];
  Driver(data) {
    this.fullName = data['firstName'] + ' ' + data['lastName'];
    this.imageUrl = data['imageUrl'];
    this.empId = data['empId'];
    List<dynamic> trips = data['upcomingTrips'];
    trips.forEach((trip) {
      this.upcomingTrips.add(Trip(trip));
    });
  }
}

class Trip {
  DateTime dateTime;
  String fullName;
  Trip(data) {
    this.dateTime = DateTime.parse(data['dateTime']);
    this.fullName = data['firstName'] + ' ' + data['lastName'];
  }
}
