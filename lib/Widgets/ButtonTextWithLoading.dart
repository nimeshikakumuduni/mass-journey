import 'package:flutter/material.dart';

class ButtonTextWithLoading extends StatelessWidget {
  final String text;
  final bool isLoading;
  ButtonTextWithLoading({this.text, this.isLoading});
  @override
  Widget build(BuildContext context) {
    return isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : Text(
            text,
            style: TextStyle(color: Colors.white),
          );
  }
}
