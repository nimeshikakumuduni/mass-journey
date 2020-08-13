import 'dart:convert';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:vetaapp/Models/User.dart';
import 'package:vetaapp/ServerData/ServerData.dart';
import 'package:vetaapp/Widgets/AppBarTitle.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vetaapp/Widgets/ProfilePictOnCircleAvatar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:http/http.dart' as http;

class VetaDrawer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _VetaDrawerState();
  }
}

class _VetaDrawerState extends State<VetaDrawer> {
  bool imageUploading = false;
  double imageUploadProgress = 0;
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            automaticallyImplyLeading: false,
            title: AppBarTitle('Veta'),
          ),
          profile(),
          SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.only(left: 3, right: 3),
              child: Column(
                children: <Widget>[
                  User.currentUser.isAdmin
                      ? Container(
                          margin: EdgeInsets.only(bottom: 3),
                          child: Ink(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.pinkAccent,
                            ),
                            child: ListTile(
                              title: Text(
                                'User Registration',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              onTap: () {
                                Navigator.pushNamed(context, '/register');
                              },
                            ),
                          ),
                        )
                      : Container(),
                  User.currentUser.isAdmin
                      ? Container(
                          margin: EdgeInsets.only(bottom: 3),
                          child: Ink(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.pinkAccent,
                            ),
                            child: ListTile(
                              title: Text(
                                'Make Admin',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              onTap: () {
                                Navigator.pushNamed(context, '/makeAdmin');
                              },
                            ),
                          ),
                        )
                      : Container(),
                  User.currentUser.position == "Transport Manager"
                      ? Container(
                          margin: EdgeInsets.only(bottom: 3),
                          child: Ink(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.pinkAccent,
                            ),
                            child: ListTile(
                              title: Text(
                                'Add New Vehicle',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              onTap: () async {
                                Navigator.pushNamed(context, '/addNewVehicle');
                              },
                            ),
                          ),
                        )
                      : Container(),
                  Container(
                    margin: EdgeInsets.only(bottom: 3),
                    child: Ink(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.pinkAccent,
                      ),
                      child: ListTile(
                        title: Text(
                          'Logout',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        onTap: () async {
                          Navigator.pushReplacementNamed(context, '/login');
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          await prefs.clear();
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget profile() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(1),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: User.currentUser.imageUrl != null
              ? NetworkImage(User.currentUser.imageUrl)
              : AssetImage(User.defaultProfPict),
          fit: BoxFit.cover,
          colorFilter:
              ColorFilter.mode(Colors.black.withOpacity(0.7), BlendMode.darken),
        ),
      ),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 20.0,
          ),
          Stack(
            children: <Widget>[
              !imageUploading
                  ? ProfilePictOnCircleAvatar(User.currentUser.imageUrl, 70.0)
                  : CircleAvatar(
                      child: SizedBox(
                        height: 140,
                        width: 140,
                        child: imageUploadProgress == 0
                            ? CircularProgressIndicator()
                            : imageUploadProgress == 1.0
                                ? Container()
                                : CircularProgressIndicator(
                                    value: imageUploadProgress,
                                  ),
                      ),
                      radius: 70,
                      backgroundImage: User.currentUser.imageUrl != null
                          ? NetworkImage(User.currentUser.imageUrl)
                          : AssetImage(User.defaultProfPict),
                    ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  height: 33,
                  width: 33,
                  decoration: BoxDecoration(
                      color: Colors.pink,
                      borderRadius: BorderRadius.circular(100)),
                  child: IconButton(
                    color: Colors.white,
                    icon: Icon(
                      Icons.add_a_photo,
                      size: 17,
                    ),
                    onPressed: () {
                      uploadPhoto();
                    },
                  ),
                ),
              )
            ],
          ),
          SizedBox(
            height: 20.0,
          ),
          Text(
            User.currentUser.firstName + ' ' + User.currentUser.lastName,
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                    blurRadius: 10,
                    offset: Offset(-2, -2),
                    color: Colors.black),
                Shadow(
                    blurRadius: 10, offset: Offset(2, -2), color: Colors.black),
                Shadow(
                    blurRadius: 10, offset: Offset(2, 2), color: Colors.black),
                Shadow(
                    blurRadius: 10, offset: Offset(-2, 2), color: Colors.black),
              ],
            ),
          ),
          SizedBox(
            height: 5.0,
          ),
        ],
      ),
    );
  }

  Future uploadPhoto() async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      File croppedImage = await cropImage(image);
      if (croppedImage != null) {
        uploadImage(croppedImage);
      }
    }
  }

  Future<File> cropImage(File imageFile) async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: imageFile.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        ));
    return croppedFile;
  }

  uploadImage(File imageToUpload) async {
    String filePath;
    if (User.currentUser.imageUrl != null) {
      filePath = User.currentUser.imageUrl.replaceAll(
          new RegExp(
              r'https://firebasestorage.googleapis.com/v0/b/dial-in-21c50.appspot.com/o/'),
          '');
      filePath = filePath.replaceAll(new RegExp(r'%2F'), '/');
      filePath = filePath.replaceAll(new RegExp(r'(\?alt).*'), '');
      List<String> splited = filePath.split('/');
      filePath =
          splited[splited.length - 2] + '/' + splited[splited.length - 1];
    }
    setState(() {
      imageUploading = true;
    });
    String time = DateTime.now().millisecondsSinceEpoch.toString();
    String extension = imageToUpload.path.split("/").last.split(".").last;
    final StorageReference storageRef = FirebaseStorage.instance.ref().child(
        "profilePictures/" +
            User.currentUser.userName +
            time +
            "." +
            extension);
    final StorageUploadTask uploadTask = storageRef.putFile(imageToUpload);
    if (filePath != null) {
      FirebaseStorage.instance.ref().child(filePath).delete();
    }
    uploadTask.events.listen((event) {
      setState(() {
        imageUploadProgress = event.snapshot.bytesTransferred.toDouble() /
            event.snapshot.totalByteCount.toDouble();
      });
    });
    final StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);
    final String url = (await downloadUrl.ref.getDownloadURL());
    setState(() {
      imageUploading = false;
      User.currentUser.imageUrl = url;
    });
    http.post(ServerData.serverUrl + '/updateImage', body: {
      'empId': User.currentUser.empId,
      'imageUrl': url,
    }).then((http.Response response) async {
      String status = json.decode(response.body)['status'];
      print(status);
    });
  }
}
