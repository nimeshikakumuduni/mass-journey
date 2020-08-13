import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vetaapp/Messages/Messages.dart';
import 'package:vetaapp/ServerData/ServerData.dart';
import 'package:vetaapp/Widgets/AppBarTitle.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:vetaapp/Widgets/ButtonTextWithLoading.dart';
import 'package:vetaapp/Widgets/FormField.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SignUp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SignUpState();
  }
}

class _SignUpState extends State<SignUp> {
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

  
  String empId, nic, firstName, lastName, tel, userName, password;
  int currentPage = 0;
  bool loading = false;

  final _firstFormKey = GlobalKey<FormState>();
  final _secondFormKey = GlobalKey<FormState>();
  final _thirdFormKey = GlobalKey<FormState>();

  final _idController = TextEditingController();
  final _nicController = TextEditingController();

  final _fNameController = TextEditingController();
  final _lNameController = TextEditingController();
  final _telController = TextEditingController();

  final _uNameController = TextEditingController();
  final _passController = TextEditingController();
  final _passConfController = TextEditingController();

  final pageViewController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppBarTitle('Sign Up'),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: PageView(
                physics: new NeverScrollableScrollPhysics(),
                scrollDirection: Axis.horizontal,
                controller: pageViewController,
                children: <Widget>[firstPage(), secondPage(), thirdPage()],
              ),
            ),
            Container(
              margin: EdgeInsets.only(right: 30, bottom: 20, left: 30),
              alignment: Alignment.bottomRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  currentPage == 0
                      ? RaisedButton(
                          onPressed: () {},
                          child: Text(
                            'Previous',
                            style: TextStyle(color: Colors.white),
                          ),
                          color: Colors.blue.withOpacity(0.2),
                        )
                      : RaisedButton(
                          onPressed: () {
                            setState(() {
                              currentPage--;
                              pageViewController.previousPage(
                                  curve: Curves.easeInOutCirc,
                                  duration: Duration(milliseconds: 800));
                            });
                          },
                          child: Text(
                            'Previous',
                            style: TextStyle(color: Colors.white),
                          ),
                          color: Colors.blue,
                        ),
                  Expanded(
                    child: SizedBox(),
                  ),
                  RaisedButton(
                    onPressed: () async{
                      
                      nextButtonAction();
                    
                    },
                    child: ButtonTextWithLoading(
                      text: currentPage == 2 ? 'Finish' : 'Next',
                      isLoading: loading,
                    ),
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 10),
              child: DotsIndicator(
                dotsCount: 3,
                position: double.parse(currentPage.toString()),
                decorator: DotsDecorator(
                  size: const Size.square(9.0),
                  activeSize: const Size(18.0, 9.0),
                  activeShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  nextButtonAction() async {
    if (currentPage == 0) {
      if (!_firstFormKey.currentState.validate()) {
        return;
      }
      _firstFormKey.currentState.save();
      checkUser(empId,nic);  
    } 
    
    
    else if (currentPage == 1) {
      if (!_secondFormKey.currentState.validate()) {
        return;
      }
      _secondFormKey.currentState.save();
      pageViewController.nextPage(
          curve: Curves.easeInOutCirc, duration: Duration(milliseconds: 800));
      setState(() {
        currentPage++;
      });
    } 
    
    else if (currentPage == 2) {
      if (!_thirdFormKey.currentState.validate()) {
        return;
      }
      _thirdFormKey.currentState.save();
      signupUser();

      }
  }

  checkUser(String empId, String nic){
    setState(() {
      loading = true; 
    });
    http.post(ServerData.serverUrl + '/checkUser',body: {
      'empId':empId,
      'nic':nic,
      }).then((http.Response response){
        
      setState(() {
       loading = false; 
      });
      var statusCode = response.statusCode;
      if(statusCode < 200 || statusCode>400){
        Messages.simpleMessage(
          head: 'Something went wrong!',
          body: 'There is a problem with server. Please try again later..',
          context: context);
      } else {
        String status = json.decode(response.body)['status'];
        print(status);
        print(status);
        if(status == 'unsuccess'){
          Messages.simpleMessage(
          head: 'Something went wrong!',
          body: 'There is a problem with server. Please try again later..',
          context: context);
        } else if (status == 'not registered'){
          Messages.simpleMessage(
            head: 'Failed to Sign Up!',
            body: 'Please check your NIC Number and Employee Id and try again!',
            context: context);
        }else if (status == 'already signed up'){
          Messages.simpleMessage(
            head: 'You have already registered!',
            body:
                'NIC Number and Employee Id you have entered is already registered in the system. Please check details and try again!',
            context: context);
        }
        else if(status == 'success'){
          pageViewController.nextPage(
          curve: Curves.easeInOutCirc, duration: Duration(milliseconds: 800));
          setState(() {
            currentPage++;
          });
        }
      }
    });
  }

  signupUser(){
    setState(() {
     loading = true; 
    });
     http.post(ServerData.serverUrl+'/signupUser',body: {
        'empId':empId,
        'nic':nic,
        'firstName': '${firstName[0].toUpperCase()}${firstName.substring(1)}',
        'lastName': '${lastName[0].toUpperCase()}${lastName.substring(1)}',
        'tel': tel,
        'userName': userName,
        'password': password,
        'isRegistered': true.toString(),
        'isAdmin':false.toString(),
        'isOnline':false.toString(),
        'isDeleted':false.toString()
      }).then((http.Response response){
        setState(() {
          loading = false; 
          });
      var statusCode = response.statusCode;
      if(statusCode < 200 || statusCode>400){
        Messages.simpleMessage(
          head: 'Something went wrong!',
          body: 'There is a problem with server. Please try again later..',
          context: context);
      } else {
        String status = json.decode(response.body)['status'];
        if(status == 'unsuccess'){
          Messages.simpleMessage(
          head: 'Something went wrong!',
          body: 'There is a problem with server. Please try again later..',
          context: context);
        } else if (status == 'userName exists'){
          Messages.simpleMessage(
          head: 'User Name already exists!',
          body: 'User Name you entered is already exists. Please use another one..',
          context: context);
        }
         else if(status == 'success'){
            Navigator.pop(context);

            Messages.simpleMessage(
                head: 'Succesfully Signed Up!',
                body:
                    'You are succesfully signed up to the system and you can loging to system using your Username and Password',
                context: context);
        }
      }
    });

  }

  Widget select() {
    if (currentPage == 0) {
      return firstPage();
    } else if (currentPage == 1) {
      return secondPage();
    } else if (currentPage == 2) {
      return thirdPage();
    } else {
      return Container();
    }
  }

  Widget firstPage() {
    return Form(
      key: _firstFormKey,
      child: ListView(
        children: <Widget>[
          Center(
            child: Container(
              margin: EdgeInsets.only(top: 30),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(10)),
              child: Text(
                'Step 1',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Center(
            child: CustomFormField(
              label: 'Employee Id Number',
              controller: _idController,
              onSave: empIdSave,
              onValidate: idValidation,
            ),
          ),
          Center(
            child: CustomFormField(
              label: 'NIC Number',
              controller: _nicController,
              onSave: nicSave,
              onValidate: nicValidation,
            ),
          ),
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

  Widget secondPage() {
    return Form(
      key: _secondFormKey,
      child: ListView(
        children: <Widget>[
          Center(
            child: Container(
              margin: EdgeInsets.only(top: 30),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(10)),
              child: Text(
                'Step 2',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Center(
            child: CustomFormField(
              label: 'First Name',
              controller: _fNameController,
              onSave: fNameSave,
              onValidate: fNameValidation,
            ),
          ),
          Center(
            child: CustomFormField(
              label: 'Last Name',
              controller: _lNameController,
              onSave: lNameSave,
              onValidate: lNameValidation,
            ),
          ),
          Center(
            child: CustomFormField(
              label: 'Telephone No.',
              controller: _telController,
              onSave: telSave,
              onValidate: telValidation,
            ),
          ),
        ],
      ),
    );
  }

  String fNameValidation(value) {
    if (value.toString().isEmpty) {
      return "First Name is required";
    }
    return null;
  }

  String lNameValidation(value) {
    if (value.toString().isEmpty) {
      return "Last Name is required";
    }
    return null;
  }

  String telValidation(value) {
    Pattern pattern = r'(^(?:[+0]9)?[0-9]{10}$)';
    RegExp regex = new RegExp(pattern);
    if (value.toString().isEmpty) {
      return "Telephone Number is required";
    } else if (!regex.hasMatch(value)) {
      return 'Enter Valid Phone Number';
    }
    return null;
  }

  fNameSave(value) {
    firstName = value;
  }

  lNameSave(value) {
    lastName = value;
  }

  telSave(value) {
    tel = value;
  }

  Widget thirdPage() {
    return Form(
      key: _thirdFormKey,
      child: ListView(
        children: <Widget>[
          Center(
            child: Container(
              margin: EdgeInsets.only(top: 30),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(10)),
              child: Text(
                'Step 3',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Center(
            child: CustomFormField(
              label: 'Create User Name',
              controller: _uNameController,
              onSave: uNameSave,
              onValidate: uNameValidation,
            ),
          ),
          Center(
            child: CustomFormField(
              label: 'Create Password',
              controller: _passController,
              onSave: passSave,
              onValidate: passValidation,
              isObsecure: true,
            ),
          ),
          Center(
            child: CustomFormField(
              label: 'Confirm Password',
              controller: _passConfController,
              onSave: passConfSave,
              onValidate: passConfValidation,
              isObsecure: true,
            ),
          ),
        ],
      ),
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
    } else if (value.toString().length < 8) {
      return "Password should have at-least 8 characters";
    }
    return null;
  }

  String passConfValidation(value) {
    if (value.toString().isEmpty) {
      return 'Enter password again';
    } else if (_passController.text != value) {
      return 'Password not matching';
    }
    return null;
  }

  uNameSave(value) {
    userName = value;
  }
  passSave(value) {}

  passConfSave(value) {
    password = value;
  }
}
