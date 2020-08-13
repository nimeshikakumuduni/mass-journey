import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vetaapp/EmployeeView/MapOnEmployee.dart';
import 'package:vetaapp/Messages/Messages.dart';
import 'package:vetaapp/Models/TripData.dart';
import 'package:vetaapp/ServerData/ServerData.dart';

class TripShortView extends StatefulWidget {
  final TripData trip;
  final String type;
  TripShortView(this.trip, this.type);
  @override
  State<StatefulWidget> createState() {
    return _TripShortViewState();
  }
}

class _TripShortViewState extends State<TripShortView> {
  @override
  Widget build(BuildContext context) {
    return ((widget.type == 'rejected' && widget.trip.isDeleted) ||
            (widget.type != 'rejected' && !widget.trip.isDeleted))
        ? Container(
            margin: EdgeInsets.only(bottom: 10, left: 20, right: 20),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(6)),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        widget.trip.purpose,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    widget.type == 'pending'
                        ? GestureDetector(
                            onTap: () {
                              Messages.showMessageSure(
                                  context,
                                  widget.trip,
                                  "This action will reject the trip!",
                                  deleteTrip);
                            },
                            child: Container(
                              height: 35,
                              width: 35,
                              decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(100)),
                              child: Center(
                                child: Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                        : Container()
                  ],
                ),
                _detail(
                    Icons.calendar_today,
                    DateFormat("yyyy-MM-dd").format(
                      DateTime.parse(widget.trip.dateTime),
                    ),
                    Colors.green),
                _detail(
                    Icons.access_time,
                    DateFormat("hh:mm a").format(
                      DateTime.parse(widget.trip.dateTime),
                    ),
                    Colors.blue),
                widget.type == 'accept' || widget.type == 'past'
                    ? Column(
                        children: <Widget>[
                          _detail(
                              Icons.person,
                              widget.trip.firstName +
                                  " " +
                                  widget.trip.lastName,
                              Colors.pink),
                          _detail(Icons.directions_car,
                              widget.trip.vehicleNumber, Colors.orange),
                          GestureDetector(
                            onTap: (){
                              launch('tel:' + widget.trip.tel);
                            },
                            child: _detail(
                                Icons.phone, widget.trip.tel, Colors.orange),
                          ),
                        ],
                      )
                    : Container(),
                widget.type == 'accept' &&
                        widget.trip.isStarted &&
                        !widget.trip.isDone
                    ? Container(
                        child: RaisedButton(
                          child: Text(
                            "Vehicle is on the way",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          color: Colors.blue,
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    MapOnEmployee(widget.trip),
                              ),
                            );
                          },
                        ),
                      )
                    : Container()
              ],
            ),
          )
        : Container();
  }

  Widget _detail(IconData icon, String text, Color iconColor) {
    return Container(
      margin: EdgeInsets.all(5),
      child: Row(
        children: <Widget>[
          Icon(
            icon,
            size: 17,
            color: iconColor,
          ),
          SizedBox(
            width: 20,
          ),
          Text(text)
        ],
      ),
    );
  }

  deleteTrip(TripData trip) {
    http.post(ServerData.serverUrl + '/rejectTrip', body: {
      'tripId': trip.tripId.toString()
    }).then((http.Response response) {
      setState(() {
        trip.isDeleted = true;
      });
    });
  }
}
