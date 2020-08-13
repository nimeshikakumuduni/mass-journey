import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vetaapp/Models/TripData.dart';
import 'package:vetaapp/ServerData/ServerData.dart';
import 'package:vetaapp/Widgets/LoadingDrivers.dart';
import 'package:http/http.dart' as http;

class LoadingVehicles extends StatefulWidget {
  final TripData trip;
  LoadingVehicles(this.trip);

  @override
  _LoadingVehiclesState createState() => _LoadingVehiclesState();
}

class _LoadingVehiclesState extends State<LoadingVehicles> {
  List<Vehicle> vehicles = [];
  bool loadingVehicles = true;
  @override
  void initState() {
    loadVehicles();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return loadingVehicles
        ? Container(
            color: Colors.black26,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : vehicles.length == 0
            ? Container(
                child: Center(
                  child: Text("No Available Vehicles"),
                ),
              )
            : Container(
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        "Available Vehicles",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemBuilder: (context, index) =>
                            vehicleItem(vehicles[index]),
                        itemCount: vehicles.length,
                      ),
                    )
                  ],
                ),
              );
  }

  vehicleItem(Vehicle vehicle) {
    return Card(
      elevation: 10,
      margin: EdgeInsets.only(left: 10, right: 10, top: 10),
      child: ListTile(
        leading: Icon(Icons.directions_car),
        title: Text(vehicle.vehicleNumber),
        subtitle: Text(vehicle.vehicleType),
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
                            Text(
                              vehicle.vehicleNumber,
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              vehicle.vehicleType,
                              style: TextStyle(
                                  fontSize: 15,),
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
                              child: vehicle.upcomingTrips.length == 0
                                  ? Center(
                                      child: Text("No Upcomming Trips"),
                                    )
                                  : ListView.builder(
                                      itemBuilder: (context, index) => Card(
                                        elevation: 10,
                                        margin: EdgeInsets.all(5),
                                        child: ListTile(
                                          title: Text(vehicle
                                                  .upcomingTrips[index]
                                                  .fullName +
                                              '\'s trip'),
                                          subtitle: Text(
                                            DateFormat("EEE, MMM d @ h:mm a")
                                                .format(vehicle
                                                    .upcomingTrips[index]
                                                    .dateTime),
                                          ),
                                        ),
                                      ),
                                      itemCount: vehicle.upcomingTrips.length,
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
                  widget.trip.vehicleId = vehicle.vehicleId;
                  widget.trip.vehicleNumber = vehicle.vehicleNumber;
                });
                Navigator.pop(context);
              },
            )
          ],
        ),
      ),
    );
  }

  loadVehicles() {
    http
        .get(ServerData.serverUrl + '/getFreeVehicles')
        .then((http.Response response) {
      List<dynamic> temp = json.decode(response.body);
      temp.forEach((vehicle) {
        vehicles.add(Vehicle(vehicle));
      });
      setState(() {
        loadingVehicles = false;
      });
    });
  }
}

class Vehicle {
  int vehicleId;
  String vehicleNumber;
  String vehicleType;
  List<Trip> upcomingTrips = [];
  Vehicle(data) {
    this.vehicleId = int.parse(data['vehicleId'].toString());
    this.vehicleNumber = data['vehicleNumber'];
    this.vehicleType = data["vehicleType"];
    List<dynamic> temp = data['upcomingTrips'];
    temp.forEach((trip) {
      this.upcomingTrips.add(Trip(trip));
    });
  }
}
