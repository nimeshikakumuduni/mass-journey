import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vetaapp/ManagerView/ViewMap.dart';
import 'package:vetaapp/Messages/Messages.dart';
import 'package:vetaapp/Models/TripData.dart';
import 'package:vetaapp/Models/User.dart';
import 'package:vetaapp/ServerData/ServerData.dart';
import 'package:http/http.dart' as http;
import 'package:vetaapp/Widgets/LoadingDrivers.dart';
import 'package:vetaapp/Widgets/LoadingVehicles.dart';
import 'ProfilePictOnCircleAvatar.dart';

class TMConfirmation extends StatefulWidget {
  final TripData trip;
  final int index;
  TMConfirmation(this.trip, this.index);
  @override
  _TMConfirmationState createState() => _TMConfirmationState();
}

class _TMConfirmationState extends State<TMConfirmation> {
  bool loading2 = false;
  bool driversLoading = false;
  List<Driver> drivers = [];
  @override
  Widget build(BuildContext context) {
    return !widget.trip.isConfirm && !widget.trip.isDeleted
        ? Stack(
            children: <Widget>[
              Card(
                margin: EdgeInsets.all(10),
                elevation: 20,
                child: Column(
                  children: <Widget>[
                    ListTile(
                      leading:
                          ProfilePictOnCircleAvatar(widget.trip.imageUrl, 25),
                      title: Text(
                        widget.trip.firstName + ' ' + widget.trip.lastName,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            ),
                            onPressed: () {
                              if (widget.trip.dEmpId == null ||
                                  widget.trip.vehicleId == null) {
                                Messages.simpleMessage(
                                    head: "Failed to confirm trip!",
                                    body:
                                        "Please assign a driver and a vehicle to the trip and try again!",
                                    context: context);
                                return;
                              }
                              Messages.showMessageSure(
                                  context,
                                  widget.trip,
                                  "This action will confirm " +
                                      widget.trip.firstName +
                                      "'s trip!",
                                  _confirm);
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.remove_circle,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              Messages.showMessageSure(
                                  context,
                                  widget.trip,
                                  "This action will reject " +
                                      widget.trip.firstName +
                                      "'s trip!",
                                  _reject);
                            },
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        widget.trip.purpose,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 40, bottom: 10),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.calendar_today,
                            size: 17,
                            color: Colors.blue,
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            DateFormat("yyyy-MM-dd").format(
                              DateTime.parse(widget.trip.dateTime),
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 40, bottom: 10),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.access_time,
                            size: 17,
                            color: Colors.green,
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            DateFormat("hh:mm a").format(
                              DateTime.parse(widget.trip.dateTime),
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 40, bottom: 10),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.phone,
                            size: 17,
                            color: Colors.orange,
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          GestureDetector(
                            onTap: () {
                              launch('tel:' + widget.trip.tel);
                            },
                            child: Text(widget.trip.tel),
                          )
                        ],
                      ),
                    ),
                    widget.trip.dFullName == null
                        ? Container()
                        : Container(
                            margin: EdgeInsets.only(left: 40, bottom: 10),
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.person,
                                  size: 17,
                                  color: Colors.green,
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Text(widget.trip.dFullName)
                              ],
                            ),
                          ),
                    widget.trip.vehicleNumber == null
                        ? Container()
                        : Container(
                            margin: EdgeInsets.only(left: 40, bottom: 10),
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.directions_car,
                                  size: 17,
                                  color: Colors.pink,
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Text(widget.trip.vehicleNumber)
                              ],
                            ),
                          ),
                    Container(
                      margin: EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: SizedBox(),
                          ),
                          roundedButton(Icons.map, () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ViewMap(
                                  LatLng(widget.trip.pickLati,
                                      widget.trip.pickLong),
                                  LatLng(widget.trip.destiLati,
                                      widget.trip.destiLong),
                                ),
                              ),
                            );
                          }),
                          Expanded(
                            child: SizedBox(),
                          ),
                          roundedButton(
                            Icons.person_add,
                            () {
                              showModalBottomSheet(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return LoadingDrivers(widget.trip);
                                  }).then((onValue) {
                                setState(() {});
                              });
                            },
                          ),
                          Expanded(
                            child: SizedBox(),
                          ),
                          roundedButton(
                            Icons.directions_car,
                            () {
                              showModalBottomSheet(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return LoadingVehicles(widget.trip);
                                  }).then((onValue) {
                                setState(() {});
                              });
                            },
                          ),
                          Expanded(
                            child: SizedBox(),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              loading2
                  ? Positioned.fill(
                      child: Container(
                        color: Colors.black54,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    )
                  : Container(),
            ],
          )
        : Container();
  }

  Widget roundedButton(
    IconData icon,
    Function action,
  ) {
    return GestureDetector(
      onTap: () {
        action();
      },
      child: Container(
        height: 45,
        width: 45,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Center(
          child: Icon(
            icon,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  _confirm(TripData trip) {
    setState(() {
      loading2 = true;
    });
    ServerData.socket.emitWithAck('confirmTripByTM', [
      {
        'tripId': trip.tripId.toString(),
        'tMEmpId': User.currentUser.empId,
        'dEmpId': trip.dEmpId,
        'vehicleId': trip.vehicleId
      }
    ]).then((data) {
      setState(() {
        loading2 = false;
        trip.isConfirm = true;
      });
    });
  }

  _reject(TripData trip) {
    setState(() {
      loading2 = true;
    });
    http.post(ServerData.serverUrl + '/rejectTrip', body: {
      'tripId': trip.tripId.toString(),
    }).then((http.Response response) {
      setState(() {
        trip.isDeleted = true;
      });
    });
  }
}
