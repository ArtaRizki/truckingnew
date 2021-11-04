import 'dart:io';

import 'package:anugerah_truck/controllers/user_controller.dart';
import 'package:background_location/background_location.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart' as P;
import 'package:shared_preferences/shared_preferences.dart';

import '../global_config.dart';
import '../main.dart';
import '../router.dart' as R;

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const platform =
      const MethodChannel('com.example.dev/tracking_offline');

  Future<void> _getTracking() async {
    // String track;
    // String url = GlobalConfig.MainURL + "liveTrack";

    // try {
    //   final String result =
    //       await platform.invokeMethod('getTracking', {'URL': url});
    //   track = 'Tracking is running';
    // } on PlatformException catch (e) {
    //   track = 'Failed to track: ${e.message}';
    // }
  }

  Location location = new Location();

  bool _serviceEnabled;
  LocationData _locationData;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getTracking();
    onStart();
  }

  void onStart() async {
    String url = GlobalConfig().mainURL() + "liveTrack";
    // _serviceEnabled = await location.serviceEnabled();
    // if (!_serviceEnabled) {
    //   _serviceEnabled = await location.requestService();
    //   if (!_serviceEnabled) {
    //     exit(0);
    //   }
    // }

    FirebaseMessaging messaging = FirebaseMessaging.instance;
    messaging.getToken().then((value) => print(value.toString()));
    // FirebaseMessaging.onBackgroundMessage((message) => firebaseMessagingBackgroundHandler(message));
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("on launch");
    });
    FirebaseMessaging.onMessage.listen((message) async {
      if (message.data['title'] == "1") {
            print("seharussnya mati");
            platform.invokeMethod('stopTrack');
          } else {
            print("seharussnya nyala");
            platform.invokeMethod('getTracking', {'URL': url});
          }
    });

    Map<P.Permission, P.PermissionStatus> statuses = await [
      P.Permission.locationAlways,
      P.Permission.location,
      P.Permission.storage,
    ].request();

     // ignore: unrelated_type_equality_checks
    if (statuses[P.Permission.location.isGranted] == false) {
      exit(0);
    }

    // ignore: unrelated_type_equality_checks
    if (statuses[P.Permission.storage.isGranted] == false) {
      exit(0);
    }
    // await UserController.LogOut();
    // await Permission.location.request();
    // await BackgroundLocation.LiveTracking("http://mgbix.id:82/trucking-aba/API/liveTrack");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.get(GlobalConfig.SPUserKey) != null) {
      Navigator.of(context).pushNamedAndRemoveUntil(
          R.Router.homeRoute, (Route<dynamic> route) => false);
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil(
          R.Router.loginRoute, (Route<dynamic> route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: FlutterLogo()),
    );
  }
}
