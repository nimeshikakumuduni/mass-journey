import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vetaapp/Messages/Messages.dart';
import 'package:vetaapp/Models/User.dart';
import 'package:vetaapp/ServerData/ServerData.dart';
import 'package:vetaapp/Widgets/AppBarTitle.dart';
import 'package:vetaapp/Widgets/ButtonTextWithLoading.dart';
import 'package:vetaapp/Widgets/FormField.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginState();
  }
}

class _LoginState extends State<Login> {
  final String loginbackground = "assets/background2.jpg";
  @override
  void initState() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ]);
    super.dispose();
  }

  String userName, password;
  bool loginLoading = false;

  final _loginFormKey = GlobalKey<FormState>();

  final _uNameController = TextEditingController();
  final _passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppBarTitle('Login'),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(loginbackground),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.1), BlendMode.darken),
          ),
        ),
        child: ListView(
          children: <Widget>[
            loginForm(),
            SizedBox(
              height: 30,
            ),
            loginButton(),
            or(),
            signUpButton(),
          ],
        ),
      ),
    );
  }

  Widget loginForm() {
    return Form(
      key: _loginFormKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CustomFormField(
            label: 'Username',
            controller: _uNameController,
            onSave: uNameSave,
            onValidate: uNameValidation,
          ),
          CustomFormField(
            label: 'Password',
            controller: _passController,
            onSave: passSave,
            onValidate: passValidation,
            isObsecure: true,
          )
        ],
      ),
    );
  }

  Widget loginButton() {
    return Center(
      child: Container(
        width: 200,
        child: RaisedButton(
          color: Colors.blue,
          onPressed: () {
            loginButtonAction();
          },
          child: ButtonTextWithLoading(
            text: 'Login',
            isLoading: loginLoading,
          ),
        ),
      ),
    );
  }

  Widget signUpButton() {
    return Center(
      child: Container(
        width: 200,
        child: RaisedButton(
          color: Colors.lightGreen,
          onPressed: () {
            Navigator.pushNamed(context, '/signup');
          },
          child: ButtonTextWithLoading(
            text: 'Sign Up',
            isLoading: false,
          ),
        ),
      ),
    );
  }

  loginButtonAction() {
    if (!_loginFormKey.currentState.validate()) {
      return;
    }

    _loginFormKey.currentState.save();

    logUser(userName, password);
  }

  logUser(String userName, String password) {
    setState(() {
      loginLoading = true;
    });
    http.post(ServerData.serverUrl + '/logUser', body: {
      'userName': userName,
      'password': password,
    }).then((http.Response response) async {
      setState(() {
        loginLoading = false;
      });

      var statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400) {
        Messages.simpleMessage(
            head: 'Something went wrong!',
            body: 'There is a problem with server. Please try again later..',
            context: context);
      } else {
        String status = json.decode(response.body)['status'];
        var userData = json.decode(response.body)['userData'];
        print(status);
        if (status == 'unsuccess') {
          Messages.simpleMessage(
              head: 'Something went wrong!',
              body: 'There is a problem with server. Please try again later..',
              context: context);
        } else if (status == 'not matching') {
          Messages.simpleMessage(
              head: 'Can\'t Find Account',
              body: 'It looks like ' +
                  userName +
                  ' doesn\'t match an existing account. If you don\'t have an account, you can create one now.',
              context: context);
        } else if (status == 'success') {
          User.currentUser = User(userData);
          print(User.currentUser.isAdmin);
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLogin', true);
          await prefs.setString('usrnm', userName);
          await prefs.setString('pswrd', password);

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
        }
      }
    });
  }

  Widget or() {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            height: 1,
            color: Colors.grey,
            margin: EdgeInsets.only(left: 10, right: 10, top: 30, bottom: 30),
          ),
        ),
        Text(
          'OR',
          style: TextStyle(color: Colors.grey),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: Colors.grey,
            margin: EdgeInsets.only(left: 10, right: 10),
          ),
        ),
      ],
    );
  }

  String uNameValidation(value) {
    if (value.toString().isEmpty) {
      return "Username is required";
    }
    return null;
  }

  String passValidation(value) {
    if (value.toString().isEmpty) {
      return "Password is required";
    }
    return null;
  }

  uNameSave(value) {
    userName = value;
  }

  passSave(value) {
    password = value;
  }
}
