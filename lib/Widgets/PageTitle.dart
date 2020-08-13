import 'package:flutter/material.dart';

class PageTitle extends StatelessWidget {
  const PageTitle({this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10, bottom: 10),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 25,
          color: Colors.white,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(blurRadius: 3, offset: Offset(-2, -2), color: Colors.grey),
            Shadow(blurRadius: 3, offset: Offset(2, -2), color: Colors.grey),
            Shadow(blurRadius: 3, offset: Offset(2, 2), color: Colors.grey),
            Shadow(blurRadius: 3, offset: Offset(-2, 2), color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
