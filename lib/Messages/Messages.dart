import 'dart:io';

import 'package:flutter/material.dart';
import 'package:vetaapp/CheckConnection.dart';
import 'package:vetaapp/Models/TripData.dart';
import 'package:app_settings/app_settings.dart';

class Messages {
  static simpleMessage({String head, String body, BuildContext context}) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(head),
            content: Text(body),
            actions: <Widget>[
              FlatButton(
                child: Text('ok'),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  static simpleMessageOpenLocation(
      {String head, String body, BuildContext context}) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(head),
            content: Text(body),
            actions: <Widget>[
              FlatButton(
                child: Text('ok'),
                onPressed: () {
                  Navigator.pop(context);
                  AppSettings.openLocationSettings();
                },
              )
            ],
          );
        });
  }

  static showErrorMessageAndEnd(
      BuildContext context, String topic, String body) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(topic),
          content: Text(body),
          actions: <Widget>[
            FlatButton(
              child: Text('try again'),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => CheckConnection(),
                  ),
                );
              },
            ),
            FlatButton(
              child: Text(
                'ok',
                style: TextStyle(color: Colors.blue),
              ),
              onPressed: () {
                exit(0);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  static showMessageMakeUserAdminConfirm(BuildContext context, String body,
      String empId, int index, bool newPosition, Function _action) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Are you sure?'),
            content: Text(body),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text(
                  'Confirm',
                  style: TextStyle(color: Colors.green),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _action(empId, newPosition, index);
                },
              ),
            ],
          );
        });
  }

  static showMessageSure(
      BuildContext context, TripData trip, String body, Function _action) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Are you sure?'),
            content: Text(body),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text(
                  'Confirm',
                  style: TextStyle(color: Colors.green),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _action(trip);
                },
              ),
            ],
          );
        });
  }
}
