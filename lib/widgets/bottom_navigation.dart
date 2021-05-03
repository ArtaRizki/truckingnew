import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../router.dart' as R;

BottomNavigation(context, index) {
  var _router = [R.Router.homeRoute, R.Router.profilRoute];

  return BottomNavigationBar(
    items: const <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        title: Text('Home'),
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person),
        title: Text('Profil'),
      ),
    ],
    currentIndex: index,
    // selectedItemColor: Colors.amber[800],
    onTap: (int i) {
      if (i != index) {
        // Navigator.pushNamed(context, _router[i]);
        // SchedulerBinding.instance.addPostFrameCallback(
        //   (_) {
            Navigator.of(context).pushNamedAndRemoveUntil(
                _router[i], (Route<dynamic> route) => false);
          // },
        // );
      }
    },
  );
}
