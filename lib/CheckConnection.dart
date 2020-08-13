import 'dart:convert';
import 'package:connectivity_widget/connectivity_widget.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vetaapp/Messages/Messages.dart';
import 'package:vetaapp/Models/User.dart';
import 'package:http/http.dart' as http;
import 'package:vetaapp/ServerData/ServerData.dart';

class CheckConnection extends StatefulWidget {
  CheckConnection({Key key}) : super(key: key);

  _CheckConnectionState createState() => _CheckConnectionState();
}

class _CheckConnectionState extends State<CheckConnection> {
  @override
  Widget build(BuildContext context) {
    checkConnection();
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
        image: AssetImage('assets/background2.jpg'),
        fit: BoxFit.cover,
      )),
      child: Stack(
        children: <Widget>[
          Container(
            color: Colors.black.withOpacity(0.8),
          ),
          Positioned.fill(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        ],
      ),
    );
  }

  void checkConnection() async {
    var connected;
    try {
      connected = await ConnectivityUtils.instance.isPhoneConnected();
    } catch (e) {
      Messages.simpleMessage(
          head: 'No Internet!',
          body:
              'There is no internet connection. Please check your connection and try again.',
          context: context);
    }

    if (connected) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool isLogin =
          prefs.getBool('isLogin') == null ? false : prefs.getBool('isLogin');
      String userName = prefs.getString('usrnm');
      String password = prefs.getString('pswrd');

      if (!isLogin || isLogin == null) {
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        http.post(ServerData.serverUrl + '/logUser', body: {
          'userName': userName,
          'password': password,
        }).then((http.Response response) async {
          String status = json.decode(response.body)['status'];
          var userData = json.decode(response.body)['userData'];
          if (status == 'success') {
            User.currentUser = User(userData);
            await prefs.setBool('isLogin', true);
            if (User.currentUser.position == 'Employee') {
              Navigator.pushReplacementNamed(context, '/empHome');
            } else if (User.currentUser.position == 'Manager') {
              Navigator.pushReplacementNamed(context, '/managerHome');
            } else if (User.currentUser.position == 'Transport Manager') {
              Navigator.pushReplacementNamed(context, '/transportmanagerHome');
            } else if (User.currentUser.position == 'Driver') {
              Navigator.pushReplacementNamed(context, '/driverHome');
            } else {
              Navigator.pushReplacementNamed(context, 'login');
            }
          } else {
            Navigator.pushReplacementNamed(context, '/login');
          }
        });
      }
    } else {
      Messages.simpleMessage(
          head: 'No Internet!',
          body:
              'There is no internet connection. Please check your connection and try again.',
          context: context);
    }
  }
}
