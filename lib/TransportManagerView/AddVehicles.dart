import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:vetaapp/Messages/Messages.dart';
import 'package:vetaapp/ServerData/ServerData.dart';
import 'package:vetaapp/Widgets/ButtonTextWithLoading.dart';
import 'package:vetaapp/Widgets/FormField.dart';
import 'package:http/http.dart' as http;

class AddVehicle extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AddVehicleState();
  }
}

class _AddVehicleState extends State<AddVehicle> {
  String vehicleType = "Car";
  String vehicleNumber = "";
  String vehicleColor = "";
  bool sending = false;
  final _formKey = GlobalKey<FormState>();
  final _numberController = TextEditingController();
  final _colorController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add New Vehicle"),
      ),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          
          image: DecorationImage(
            image: AssetImage('assets/background4.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.white.withOpacity(0.7), BlendMode.lighten)
          ),
        ),
        width: double.infinity,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                dropDown(),
                CustomFormField(
                  controller: _numberController,
                  label: "Vehicle Number",
                  onSave: (value) {
                    vehicleNumber = value;
                  },
                  onValidate: (value) {
                    if (value.toString().isEmpty) {
                      return "Please enter vehicle number";
                    }
                    return null;
                  },
                ),
                CustomFormField(
                  controller: _colorController,
                  label: "Vehicle Colour",
                  onSave: (value) {
                    vehicleColor = value;
                  },
                  onValidate: (value) {
                    if (value.toString().isEmpty) {
                      return "Please enter vehicle colour";
                    }
                    return null;
                  },
                ),
                Container(
                  margin: EdgeInsets.only(top: 20),
                  child: RaisedButton(
                    color: Colors.blue,
                    child: ButtonTextWithLoading(
                      text: "Submit",
                      isLoading: sending,
                    ),
                    onPressed: () {
                      _formKey.currentState.save();
                      if (vehicleType.isEmpty ||
                          vehicleNumber.isEmpty ||
                          vehicleColor.isEmpty) {
                        Messages.simpleMessage(
                            head: "Submission Failed!",
                            body: "Please fill all necessary fields",
                            context: context);
                        return;
                      }
                      setState(() {
                        sending = true;
                      });
                      http.post(ServerData.serverUrl + '/addVehicle', body: {
                        'vehicleType': vehicleType,
                        'vehicleNumber': vehicleNumber,
                        'vehicleColor': vehicleColor
                      }).then((http.Response response) {
                        setState(() {
                          sending = false;
                        });
                        String status = json.decode(response.body)['status'];
                        if (status == "success") {
                          Messages.simpleMessage(
                              context: context,
                              head: "Successful!",
                              body: "Successfully added a new vehicle!");
                          _colorController.text = "";
                          _numberController.text = "";
                        } else if (status == "exists") {
                          Messages.simpleMessage(
                              context: context,
                              head: "Submission Failed!",
                              body: "Vehicle Number is already exists!");
                        } else {
                          Messages.simpleMessage(
                              context: context,
                              head: "Submission Failed!",
                              body: "Something went wrong! Please try again.");
                        }
                      });
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget dropDown() {
    return Container(
      width: 300,
      margin: EdgeInsets.only(top: 20, bottom: 10),
      child: DropdownButton<String>(
        hint: Text('Vehicle Type'),
        value: vehicleType,
        onChanged: (String newValue) {
          setState(() {
            vehicleType = newValue;
          });
        },
        items: <String>['Car', 'Van', 'Cab']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: SizedBox(
              width: 260,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
