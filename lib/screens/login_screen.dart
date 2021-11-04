import 'package:anugerah_truck/providers/dashboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../providers/login_provider.dart';
import '../widgets/input_decoration.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _emailCon = new TextEditingController();
  TextEditingController _passwordCon = new TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FlutterLogo(size: 100),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: _emailCon,
                style: TextStyle(fontSize: 20),
                decoration: loginTextDecoration("Username", Icon(Icons.person)),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Username is required';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: _passwordCon,
                style: TextStyle(fontSize: 20),
                obscureText: true,
                decoration: loginTextDecoration("Password", Icon(Icons.lock)),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Password is required';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                width: double.infinity,
                child: FlatButton(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  color: context.watch<LoginProider>().buttonColor,
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      context.read<DashboardProvider>().setWaktu(1);
                      context.read<LoginProider>().login(
                            context: context,
                            scaffold: _scaffoldKey,
                            email: _emailCon.text,
                            password: _passwordCon.text,
                          );
                    }
                  },
                  child: context.watch<LoginProider>().buttonChild,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
