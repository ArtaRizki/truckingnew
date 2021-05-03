import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import '../models/user_model.dart';
import '../models/driver_model.dart';
import '../global_config.dart';

class UserController {
  static Login({@required String email, @required String password}) async {
    FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
    print("tes");
    // _firebaseMessaging.getToken().then((String token) {
    //   assert(token != null);
    //   print("Token : "+token);
    // });
    // _firebaseMessaging.configure(
    //   onMessage: (Map<String, dynamic> message) async {
    //     print("onMessage: $message");
    //     // onStart();
    //     // String title = message['data']['title'] != null ? message['data']['title'] : "Empty Title";
    //     // String body = message['data']['body'] != null ? message['data']['body'] : "Empty Body";

    //     // platform.invokeMethod('ShowNotification');
    //   },
    //   onBackgroundMessage: myBackgroundMessageHandler,
    //   onLaunch: (Map<String, dynamic> message) async {
    //     print("onLaunch: $message");
    //   },
    //   onResume: (Map<String, dynamic> message) async {
    //     print("onResume: $message");
    //   },
    // );
    try {
      FirebaseMessaging messaging = FirebaseMessaging();
      String token = "";
      await messaging.getToken().then((value) => token = value);
      print(token);
      FormData formData = new FormData.fromMap(
          {"Email": email, "Password": password, "Token": token});
      print("url = "  + GlobalConfig().LoginURL());
      Response response =
          await Dio().post(GlobalConfig().LoginURL(), data: formData);
      Map<String, dynamic> json = jsonDecode(response.toString());

      print(json);

      if (json['status'] == -1) {
        return "Username atau password salah";
      }

      UserModel userData = userModelFromJson(jsonEncode(json['data']));

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString(GlobalConfig.SPUserKey, userModelToJson(userData));
      print(userData.id);
      prefs.setString('UserID', userData.id.toString());
      return 1;
    }on DioError catch(error){
      print(error.response);
      return "Terjadi masalah dengan server";
    }
  }

  static LogOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(GlobalConfig.SPUserKey);
    prefs.remove('UserID');
  }

  static Future<UserModel> UserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var tes = prefs.getString(GlobalConfig.SPUserKey);
    if (tes != null) {
      UserModel data = userModelFromJson(tes);
      return data;
    }
    return null;
  }

  static Future<DriverModel> DriverData() async {
    try {
      UserModel userData = await UserData();
      int id = userData.id;
      print(userData.id);
      FormData formData = new FormData.fromMap({"ID": id});

      Response response =
          await Dio().post(GlobalConfig().DriverDataURL(), data: formData);
      Map<String, dynamic> json = jsonDecode(response.toString());


      DriverModel driverData = driverModelFromJson(jsonEncode(json['Data']));

      SharedPreferences prefs = await SharedPreferences.getInstance();
      // prefs.setString(GlobalConfig.SPUserKey, driverModelToJson(driverData));
      return driverData;
    } catch (_) {
      print(_);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      DriverModel driverData = driverModelFromJson(prefs.getString(GlobalConfig.SPUserKey));
      return driverData;
    }
  }
}
