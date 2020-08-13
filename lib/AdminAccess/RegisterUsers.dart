import 'package:flutter/material.dart';
import 'package:vetaapp/Messages/Messages.dart';
import 'package:vetaapp/ServerData/ServerData.dart';
import 'package:vetaapp/Widgets/AppBarTitle.dart';
import 'package:vetaapp/Widgets/ButtonTextWithLoading.dart';
import 'package:vetaapp/Widgets/FormField.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RegisterUsers extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RegisterUsersState();
  }
}

class _RegisterUsersState extends State<RegisterUsers> {
  bool sendingData = false;
  String empId = '';
  String nic = '';
  String position;

  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _nicController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppBarTitle('User Registration'),
      ),
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/background1.gif'),
                fit: BoxFit.cover)),
        height: double.infinity,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.only(top: 50),
                child: SingleChildScrollView(
                  child: formFields(),
                ),
              ),
            ),
            Container(
              width: 150,
              child: RaisedButton(
                color: Colors.blue,
                onPressed: sendButtonAction,
                child: ButtonTextWithLoading(
                  text: 'Register',
                  isLoading: sendingData,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  sendButtonAction() async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    if (position == null) {
      Messages.simpleMessage(
          head: 'Please select position!',
          body: 'Position is required to register employee',
          context: context);
      return;
    }

    setState(() {
      sendingData = true;
    });
    _formKey.currentState.save();

    registerUser(empId, nic, position);
  }

  registerUser(String empId, String nic, String position) {
    http.post(ServerData.serverUrl + '/registerUser', body: {
      'empId': empId,
      'nic': nic,
      'position': position
    }).then((http.Response response) {
      setState(() {
        sendingData = false;
      });
      var statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400) {
        Messages.simpleMessage(
            head: 'Something went wrong!',
            body: 'There is a problem with server. Please try again later..',
            context: context);
      } else {
        String status = json.decode(response.body)['status'];
        print(status);
        if (status == 'unsuccess') {
          Messages.simpleMessage(
              head: 'Something went wrong!',
              body: 'There is a problem with server. Please try again later..',
              context: context);
        } else if (status == 'empId exists') {
          Messages.simpleMessage(
              head: 'Employee id already exists!',
              body:
                  'Employee id you entered is already exists. Please check it..',
              context: context);
        } else if (status == 'nic exists') {
          Messages.simpleMessage(
              head: 'NIC Number already exists!',
              body:
                  'NIC Number you entered is already exists. Please check it..',
              context: context);
        } else if (status == 'success') {
          _idController.text = '';
          _nicController.text = '';
          position = null;
          Messages.simpleMessage(
              head: 'Success!',
              body: 'Succesfully registered new employee..',
              context: context);
        }
      }
    });
  }

  Widget formFields() {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          CustomFormField(
              label: 'Employee Id',
              onValidate: idValidation,
              onSave: empIdSave,
              controller: _idController),
          CustomFormField(
              label: 'NIC Number',
              onValidate: nicValidation,
              onSave: nicSave,
              controller: _nicController),
          dropDown()
        ],
      ),
    );
  }

  String idValidation(value) {
    if (value.toString().isEmpty) {
      return "Employee id is required";
    }
    return null;
  }

  String nicValidation(value) {
    if (value.toString().isEmpty) {
      return "NIC Number is required";
    }
    return null;
  }

  empIdSave(value) {
    empId = value;
  }

  nicSave(value) {
    nic = value;
  }

  Widget dropDown() {
    return Container(
      width: 300,
      margin: EdgeInsets.only(top: 20, bottom: 10),
      child: DropdownButton<String>(
        hint: Text('Please Select Position'),
        value: position,
        onChanged: (String newValue) {
          setState(() {
            position = newValue;
          });
        },
        items: <String>['Employee', 'Manager', 'Transport Manager', 'Driver']
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
