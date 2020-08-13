import 'package:flutter/material.dart';
import 'package:vetaapp/Models/User.dart';

import 'ProfilePictOnCircleAvatar.dart';

class UserItem extends StatelessWidget {
  final MinUser member;
  final int index;
  final Widget userItemActions;
  final searchValue;

  UserItem(
    this.member,
    this.index,
    this.userItemActions,
    this.searchValue
  );

  @override
  Widget build(BuildContext context) {
    return (member.firstName+' '+member.lastName).toLowerCase().contains(searchValue.toLowerCase()) ? Card(
      margin: EdgeInsets.only(left: 10, right: 10, top: 10),
      color: Colors.white,
      child: ListTile(
        leading: ProfilePictOnCircleAvatar(member.imageUrl, 25),
        title: Text(
          member.firstName + ' ' + member.lastName,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        trailing: userItemActions,
      ),
    ):Container();
  }
}
