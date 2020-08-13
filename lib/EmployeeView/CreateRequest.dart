import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:vetaapp/Maps/Maps.dart';
import 'package:vetaapp/Messages/Messages.dart';
import 'package:vetaapp/Models/User.dart';
import 'package:vetaapp/ServerData/ServerData.dart';
import 'package:vetaapp/Widgets/AppBarTitle.dart';
import 'package:vetaapp/Widgets/ButtonTextWithLoading.dart';
import 'package:vetaapp/Widgets/FormField.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class CreateRequest extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CreateRequestState();
  }
}

class _CreateRequestState extends State<CreateRequest> {
  CreateTripData tripData = CreateTripData();
  final String loginbackground = "assets/background1.gif";
  final _requestFormKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _pickupController = TextEditingController();
  final _destinationController = TextEditingController();
  String onlyDate = DateFormat("yyyy-MM-dd").format(DateTime.now()),
      onlyTime = DateFormat("HH:mm:ss.sss").format(DateTime.now());

  bool submitting = false;
  @override
  void initState() {
    _dateController.text = DateFormat("yyyy-MM-dd").format(DateTime.now());
    _timeController.text = DateFormat("hh:mm a").format(DateTime.now());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppBarTitle('Request for vehicle'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(loginbackground),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.1), BlendMode.darken),
          ),
        ),
        height: double.infinity,
        width: double.infinity,
        child: SingleChildScrollView(
          child: Form(
            key: _requestFormKey,
            child: Column(
              children: <Widget>[
                CustomFormField(
                  label: 'Purpose for request',
                  onValidate: _purposeValidate,
                  onSave: _purposeSave,
                ),
                CustomFormField(
                  readOnly: true,
                  label: 'Select date',
                  controller: _dateController,
                  onValidate: _dateValidate,
                  suffixIcon: Icons.calendar_today,
                  suffixFunc: () {
                    DatePicker.showDatePicker(context,
                        minTime: DateTime.now(),
                        currentTime: DateTime.now(), onChanged: (value) {
                      setState(() {
                        onlyDate = DateFormat("yyyy-MM-dd")
                            .format(DateTime.parse(value.toString()));
                        _dateController.text = onlyDate;
                      });
                    });
                  },
                ),
                CustomFormField(
                  readOnly: true,
                  label: 'Select time',
                  controller: _timeController,
                  onValidate: _timeValidate,
                  suffixIcon: Icons.access_time,
                  suffixFunc: () {
                    DatePicker.showTimePicker(context,
                        showTitleActions: true,
                        currentTime: DateTime.now(), onChanged: (value) {
                      setState(() {
                        onlyTime = DateFormat("HH:mm:ss.sss")
                            .format(DateTime.parse(value.toString()));
                        _timeController.text = DateFormat("hh:mm a")
                            .format(DateTime.parse(value.toString()));
                      });
                    });
                  },
                ),
                CustomFormField(
                  readOnly: true,
                  label: 'Pickup location',
                  onValidate: _pickupValidate,
                  suffixIcon: Icons.map,
                  controller: _pickupController,
                  suffixFunc: () {
                    selectLocation("Pickup");
                  },
                ),
                CustomFormField(
                  controller: _destinationController,
                  readOnly: true,
                  label: 'Destination',
                  onValidate: _destinationValidate,
                  suffixIcon: Icons.map,
                  suffixFunc: () {
                    selectLocation("Destination");
                  },
                ),
                Container(
                  child: RaisedButton(
                    color: Colors.blueAccent,
                    child: ButtonTextWithLoading(
                      text: "submit",
                      isLoading: submitting,
                    ),
                    onPressed: submitting ? null : submitButtonAction,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  selectLocation(String type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => MapSample(type),
      ),
    ).then((pickupLocation) {
      LatLng location = pickupLocation;
      if (pickupLocation != null) {
        if (type == "Pickup") {
          tripData.pickLong = location.longitude;
          tripData.pickLati = location.latitude;
          _pickupController.text = pickupLocation.toString();
        } else {
          tripData.destiLong = location.longitude;
          tripData.destiLati = location.latitude;
          _destinationController.text = pickupLocation.toString();
        }
      }
    });
  }

  submitButtonAction() {
    if (!_requestFormKey.currentState.validate()) {
      return;
    }
    _requestFormKey.currentState.save();
    setState(() {
      submitting = true;
    });
    tripData.dateTime = onlyDate + " " + onlyTime;
    tripData.empId = User.currentUser.empId;
    print(tripData.toJson());
    ServerData.socket
        .emitWithAck('createRequest', [tripData.toJson()]).then((data) {
      print(data);
      setState(() {
        submitting = false;
      });
      if (data != null && data[0]['status'] == 'success') {
        Navigator.pop(context);
      } else {
        Messages.simpleMessage(
            head: "Something went wrong!",
            body: "Please try again later",
            context: context);
      }
    });
  }

  String _purposeValidate(value) {
    if (value.toString().isEmpty) {
      return "Purpose is required";
    }
    return null;
  }

  String _dateValidate(value) {
    if (value.toString().isEmpty) {
      return "Date is required";
    }
    return null;
  }

  String _timeValidate(value) {
    if (value.toString().isEmpty) {
      return "Time is required";
    }
    return null;
  }

  String _pickupValidate(value) {
    if (value.toString().isEmpty) {
      return "Pick-up location is required";
    }
    return null;
  }

  String _destinationValidate(value) {
    if (value.toString().isEmpty) {
      return "Destination is required";
    }
    return null;
  }

  _purposeSave(value) {
    tripData.purpose = value;
  }

}

class CreateTripData {
  String purpose;
  String dateTime;
  double pickLong, pickLati, destiLong, destiLati;
  String empId;

  Map<String, dynamic> toJson() => {
        'purpose': purpose,
        'dateTime': dateTime,
        'pickLong': pickLong.toString(),
        'pickLati': pickLati.toString(),
        'destiLong': destiLong.toString(),
        'destiLati': destiLati.toString(),
        'empId': empId
      };
}
