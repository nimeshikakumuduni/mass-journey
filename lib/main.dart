import 'package:flutter/material.dart';
import 'package:vetaapp/AdminAccess/RegisterUsers.dart';
import 'package:vetaapp/AdminAccess/makeAdmin.dart';
import 'package:vetaapp/CheckConnection.dart';
import 'package:vetaapp/DriverViews/DriverHomePage.dart';
import 'package:vetaapp/EmployeeView/CreateRequest.dart';
import 'package:vetaapp/EmployeeView/EmpHomePage.dart';
import 'package:vetaapp/LoginSignUp/Login.dart';
import 'package:vetaapp/LoginSignUp/SignUp.dart';
import 'package:vetaapp/TransportManagerView/AddVehicles.dart';
import 'package:vetaapp/TransportManagerView/TransportManagerHomePage.dart';
import 'ManagerView/ManagerHomepage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mass Journey',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CheckConnection(),
      routes: {
        '/signup': (BuildContext context) => SignUp(),
        '/login': (BuildContext context) => Login(),
        '/register': (BuildContext context) => RegisterUsers(),
        '/createRequest': (BuildContext context) => CreateRequest(),
        '/empHome': (BuildContext context) => EmpHomePage(),
        '/makeAdmin': (BuildContext context) => MakeAdmin(),
        '/managerHome': (BuildContext context) => ManagerHomepage(),
        '/transportmanagerHome':(BuildContext context)=> TransportManagerHome(),
        '/addNewVehicle':(BuildContext context)=>AddVehicle(),
        '/driverHome':(BuildContext context)=>DriverHomePage(),
      },
    );
  }
}
