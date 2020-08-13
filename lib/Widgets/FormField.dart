import 'package:flutter/material.dart';

class CustomFormField extends StatelessWidget {
  final Function onSave;
  final Function onValidate;
  final String label;
  final TextEditingController controller;
  final bool isObsecure;
  final IconData suffixIcon;
  final Function suffixFunc;
  final bool readOnly;

  CustomFormField({this.readOnly = false, this.onSave, this.onValidate, this.label, this.controller, this.isObsecure, this.suffixIcon, this.suffixFunc});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      margin: EdgeInsets.only(top: 10, bottom: 10),
      child: TextFormField(
        readOnly: readOnly,
        controller: controller,
        autovalidate: true,
        style: TextStyle(
          fontSize: 20,
        ),
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: suffixIcon == null ? SizedBox(): IconButton(
            icon: Icon(suffixIcon),
            onPressed: suffixFunc,
          )
        ),
        validator: onValidate,
        onSaved: onSave,
        obscureText: isObsecure == null ? false: true,
        
      ),
    );
  }
}
