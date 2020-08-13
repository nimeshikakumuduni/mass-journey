import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:vetaapp/Messages/Messages.dart';
import 'package:vetaapp/Models/User.dart';
import 'package:vetaapp/ServerData/ServerData.dart';
import 'package:vetaapp/Widgets/AppBarTitle.dart';
import 'package:http/http.dart' as http;
import 'package:vetaapp/Widgets/UserItem.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class MakeAdmin extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MakeAdminState();
  }
}

class _MakeAdminState extends State<MakeAdmin> {
  bool loadingMembers = true;
  List<MinUser> allMembers = [];
  String searchValue = "";
  @override
  void initState() {
    loadMembers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppBarTitle('Make Admin'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/background3.jpg"),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.1), BlendMode.darken),
          ),
        ),
        child: loadingMembers
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    margin: EdgeInsets.only(left: 10, right: 10, top: 10),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10)),
                    child: TextField(
                      decoration: InputDecoration(
                          labelText: "Search here..",
                          labelStyle: TextStyle(color: Colors.white)),
                      style: TextStyle(color: Colors.white, fontSize: 20),
                      onChanged: (value) {
                        setState(() {
                          searchValue = value;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemBuilder: (context, index) => UserItem(
                          allMembers[index],
                          index,
                          userItemActions(allMembers[index], index),
                          searchValue),
                      itemCount: allMembers.length,
                    ),
                  )
                ],
              ),
      ),
    );
  }

  Widget userItemActions(MinUser member, int index) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        IconButton(
          color: member.isAdmin ? Colors.green : Colors.grey,
          icon: Icon(
            MdiIcons.shieldAccount,
            size: 30,
          ),
          onPressed: () => changeType(member, index),
        ),
      ],
    );
  }

  changeType(
    MinUser member,
    int index,
  ) {
    String body = member.isAdmin
        ? "This action will make " + member.fullName + " as a normal user"
        : "This action will make " + member.fullName + " as a Admin";
    Messages.showMessageMakeUserAdminConfirm(
        context, body, member.empId, index, !member.isAdmin, changeUserType);
  }

  changeUserType(String empId, bool newPosition, int index) {
    setState(() {
      allMembers[index].isAdmin = newPosition;
    });
    http.post(ServerData.serverUrl + "/changeUserType", body: {
      'empId': empId,
      'newPosition': newPosition.toString()
    }).then((http.Response response) {
      print(json.decode(response.body)['status']);
    });
  }

  loadMembers() {
    http
        .get(ServerData.serverUrl + '/loadAllActiceUsers')
        .then((http.Response response) {
      List<dynamic> data = json.decode(response.body);
      data.forEach((user) {
        this.allMembers.add(MinUser(user));
      });
      setState(() {
        loadingMembers = false;
      });
    });
  }
}
