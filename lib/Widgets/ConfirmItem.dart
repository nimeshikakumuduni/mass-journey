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
import 'ProfilePictOnCircleAvatar.dart';

class Confirmation extends StatefulWidget {
  final TripData trip;
  final int index;
  Confirmation(this.trip, this.index);
  @override
  _ConfirmationState createState() => _ConfirmationState();
}

class _ConfirmationState extends State<Confirmation> {
  bool loading2 = false;
  @override
  Widget build(BuildContext context) {
    return !widget.trip.isMApprove && !widget.trip.isDeleted
        ? Stack(
            children: <Widget>[
              Card(
                margin: EdgeInsets.all(10),
                elevation: 10,
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
                            Text(DateFormat("yyyy-MM-dd")
                                .format(DateTime.parse(widget.trip.dateTime)))
                          ],
                        )),
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
                    Container(
                      width: 200,
                      child: RaisedButton(
                        color: Colors.lightBlue,
                        child: Text(
                          "View On Map",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViewMap(
                                LatLng(
                                    widget.trip.pickLati, widget.trip.pickLong),
                                LatLng(widget.trip.destiLati,
                                    widget.trip.destiLong),
                              ),
                            ),
                          );
                        },
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

  _confirm(TripData trip) {
    setState(() {
      loading2 = true;
    });
    ServerData.socket.emitWithAck('confirmTrip', [
      {
        'tripId': trip.tripId.toString(),
        'mEmpId': User.currentUser.empId,
        'mApproveDateTime': DateTime.now().toString()
      }
    ]).then((data) {
      setState(() {
        trip.isMApprove = true;
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
