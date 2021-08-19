import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../controllers/user_controller.dart';
import '../models/driver_model.dart';
import '../router.dart' as R;

class ProfilProvider with ChangeNotifier, DiagnosticableTreeMixin {
  bool _inProgress = true;
  bool get inProgress => _inProgress;

  void getData(
      {@required TextEditingController nameCon,
      @required TextEditingController emailCon}) async {
    _inProgress = true;
    notifyListeners();
    DriverModel dataDriver = await UserController.DriverData();
    _inProgress = false;
    notifyListeners();
    nameCon.text = dataDriver.name;
    emailCon.text = dataDriver.email;
  }

  void logOut(context) async {
    await UserController.LogOut();
    Navigator.of(context).pushNamedAndRemoveUntil(
        R.Router.loginRoute, (Route<dynamic> route) => false);
  }

  // ProfilProvider() {
  //   getData(nameCon);
  // }
}
