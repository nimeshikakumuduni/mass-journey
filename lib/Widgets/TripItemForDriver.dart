import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vetaapp/DriverViews/ViewMapToDriver.dart';
import 'package:vetaapp/Models/TripData.dart';
import 'package:vetaapp/ServerData/ServerData.dart';
import 'ProfilePictOnCircleAvatar.dart';
import 'package:slider_button/slider_button.dart';

class TripItemForDriver extends StatefulWidget {
  final TripData trip;
  final int index;
  TripItemForDriver(this.trip, this.index);
  @override
  _TripItemForDriverState createState() => _TripItemForDriverState();
}

class _TripItemForDriverState extends State<TripItemForDriver> {
  bool loading2 = false;

  @override
  Widget build(BuildContext context) {
    return widget.trip.isMApprove &&
            !widget.trip.isDeleted &&
            widget.trip.isConfirm && !widget.trip.isDone
        ? Stack(
            children: <Widget>[
              Card(
                color:
                    widget.trip.isStarted ? Colors.yellowAccent : Colors.white,
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
                      margin: EdgeInsets.only(left: 40, bottom: 10),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.directions_car,
                            size: 17,
                            color: Colors.orange,
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Text(widget.trip.vehicleNumber),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 10, bottom: 20),
                      child: SliderButton(
                        buttonColor: Colors.green,
                        label: Text(
                          widget.trip.isStarted
                              ? "re-enter to trip"
                              : "Slide to start trip",
                          style: TextStyle(
                              color: Color(0xff4a4a4a),
                              fontWeight: FontWeight.w500,
                              fontSize: 17),
                        ),
                        icon: Center(
                          child: Icon(
                            Icons.directions_car,
                            size: 30,
                            color: Colors.white,
                          ),
                        ),
                        action: () async {
                          if (!widget.trip.isStarted) {
                            startTrip(widget.trip);
                          }

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViewMapToDriver(
                                  LatLng(widget.trip.pickLati,
                                      widget.trip.pickLong),
                                  LatLng(widget.trip.destiLati,
                                      widget.trip.destiLong),
                                  widget.trip),
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

  startTrip(TripData trip) {
    ServerData.socket.emitWithAck('startTrip', [
      {
        'tripId': trip.tripId.toString(),
        'vehicleId': trip.vehicleId.toString(),
        'dEmpId': trip.dEmpId
      }
    ]).then((data) {
      setState(() {
        loading2 = true;
        trip.isStarted = true;
      });
    });
  }
}
