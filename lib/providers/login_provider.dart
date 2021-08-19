import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../router.dart' as R;
import '../controllers/user_controller.dart';

class LoginProider with ChangeNotifier, DiagnosticableTreeMixin {
  Widget _buttonChild = Text(
    "LOGIN",
    style: TextStyle(
        fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
  );
  Widget get buttonChild => _buttonChild;

  Color _buttonColor = Colors.blue;
  Color get buttonColor => _buttonColor;

  void login({
    @required context,
    @required scaffold,
    @required String email,
    @required String password,
  }) async {
    if (_buttonColor != Colors.white) {
      _buttonChild = CircularProgressIndicator();
      _buttonColor = Colors.white;
      notifyListeners();

      var loginStatus =
          await UserController.Login(email: email, password: password);

      _buttonChild = Text(
        "LOGIN",
        style: TextStyle(
            fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
      );
      _buttonColor = Colors.blue;
      notifyListeners();

      if (loginStatus != 1) {
        final snackBar = SnackBar(backgroundColor: Colors.red, content: Text(loginStatus, style: TextStyle(color: Colors.white),));
        scaffold.currentState.showSnackBar(snackBar);
      } else {
        Navigator.of(context).pushNamedAndRemoveUntil(
                R.Router.homeRoute, (Route<dynamic> route) => false);
        // Navigator.pushReplacementNamed(context, Router.homeRoute);
      }
    }
  }
}
