import 'dart:async';
import 'package:connectivity_widget/connectivity_widget.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vetaapp/CommonViews/Drawer.dart';
import 'package:vetaapp/EmployeeView/AcceptedTripsPage.dart';
import 'package:vetaapp/EmployeeView/PastTripsPage.dart';
import 'package:vetaapp/EmployeeView/PendingTripsPage.dart';
import 'package:vetaapp/EmployeeView/RejectedTripsPage.dart';
import 'package:vetaapp/Messages/Messages.dart';
import 'package:vetaapp/Models/User.dart';
import 'package:vetaapp/ServerData/ServerData.dart';
import 'package:vetaapp/Widgets/AppBarTitle.dart';
import 'package:vetaapp/Widgets/PageTitle.dart';
import 'package:adhara_socket_io/adhara_socket_io.dart';

class EmpHomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _EmpHomePageState();
  }
}

class _EmpHomePageState extends State<EmpHomePage>{
  int selectedPage = 0;
  PageController pageController = PageController();

  bool isConnected = true;
  @override
  void initState() {
    checkForLocationService();
    manager = SocketIOManager();
    initSocket();
    super.initState();
  }

  SocketIOManager manager;
  SocketIO socket;
  initSocket() async {
    print("init socket");
    socket = await manager.createInstance(SocketOptions(ServerData.serverUrl,
        nameSpace: "/",
        enableLogging: false,
        transports: [Transports.WEB_SOCKET]));
    ServerData.socket = socket;
    autoUpdates();
    socket.connect();
  }

  disconnect() async {
    await manager.clearInstance(socket);
  }

  Future checkConnection() async {
    if (isConnected) {
      var connected = await ConnectivityUtils.instance.isPhoneConnected();
      setState(() {
        isConnected = connected;
      });
      if (!connected) {
        await Messages.showErrorMessageAndEnd(context, 'No Internet!',
            'There is no internet connection. Please check your connection and try again.');
      }
    }
  }

  checkForLocationService() async {
    GeolocationStatus geolocationStatus =
        await Geolocator().checkGeolocationPermissionStatus();
    if (geolocationStatus != GeolocationStatus.granted) {
      Messages.simpleMessageOpenLocation(
          context: context,
          head: "Location services disabled",
          body:
              'Enable location services for this App using the device settings.');
    }
  }

  updateMyLocation() async {
    await checkConnection();
    if (socket == null) {
      manager.clearInstance(socket);
      initSocket();
    } else {
      print("socket Connected");
      ServerData.socket = socket;
      socket.emitWithAck("updateLastLocation", [
        {'userName': User.currentUser.userName, 'location': "location"}
      ]).then((data) {
        print(data);
      });
    }
  }

  void autoUpdates() {
    socket.onConnectTimeout((data) {
      manager.clearInstance(socket);
      initSocket();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppBarTitle('Welcome'),
      ),
      drawer: VetaDrawer(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/createRequest');
        },
        child: Icon(Icons.directions_car),
        elevation: 10.0,
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            bottomBarWidget(
                icon: Icons.done,
                select: select,
                index: 0,
                title: 'Accept',
                color: Colors.green),
            bottomBarWidget(
                icon: Icons.update,
                select: select,
                index: 1,
                title: 'Pending',
                color: Colors.amber),
            SizedBox(width: 60),
            bottomBarWidget(
                icon: Icons.insert_drive_file,
                select: select,
                index: 2,
                title: 'Past',
                color: Colors.purple),
            bottomBarWidget(
                icon: Icons.delete_sweep,
                select: select,
                index: 3,
                title: 'Reject',
                color: Colors.red),
          ],
        ),
        color: Colors.white,
      ),
      body: PageView(
        onPageChanged: (page) {
          setState(() {
            selectedPage = page;
          });
        },
        controller: pageController,
        children: <Widget>[
          pages(AcceptedTripsPage(), 'Accepted Trips'),
          pages(PendingTripsPage(), 'Pending Trips'),
          pages(PastTripsPage(), 'Past Trips'),
          pages(RejectedTripsPage(), 'Rejected Trips'),
        ],
      ),
    );
  }

  Widget pages(Widget input, String title) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/background3.jpg"),
          fit: BoxFit.cover,
          colorFilter:
              ColorFilter.mode(Colors.black.withOpacity(0.1), BlendMode.darken),
        ),
      ),
      child: Column(
        children: <Widget>[
          PageTitle(
            text: title,
          ),
          Expanded(
            child: input,
          ) //input
        ],
      ),
    );
  }

  select(int a) {
    setState(() {
      selectedPage = a;
      pageController.animateToPage(a,
          duration: Duration(milliseconds: 500), curve: Curves.easeOut);
    });
  }

  Widget bottomBarWidget(
      {IconData icon, Function select, int index, String title, Color color}) {
    bool isSelected = selectedPage == index ? true : false;
    return Expanded(
      child: SizedBox(
        height: 60,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () {
              select(index);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  icon,
                  color: isSelected ? color : Colors.grey,
                  size: 30,
                ),
                AnimatedCrossFade(
                  crossFadeState: isSelected
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  duration: const Duration(milliseconds: 200),
                  firstChild: Text(
                    title,
                    style: TextStyle(color: color),
                  ),
                  secondChild: Container(),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
