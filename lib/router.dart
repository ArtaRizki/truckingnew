import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/profil_screen.dart';
import 'screens/form_screen.dart';

class Router {
  static const String homeRoute = '/';
  static const String splashRoute = '/splash';
  static const String loginRoute = '/login';
  static const String profilRoute = '/profil';
  static const String formRoute = '/form';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case homeRoute:
        return LeftToRight(builder: (_) => DashboardScreen());
      case loginRoute:
        return Fade(builder: (_) => LoginScreen());
      case splashRoute:
        return Fade(builder: (_) => SplashScreen());
      case profilRoute:
        return RightToLeft(builder: (_) => ProfilScreen());
      case formRoute:
        return RightToLeft(builder: (_) => FormScreen(settings.arguments));
      default:
        return Fade(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}

class LeftToRight<T> extends MaterialPageRoute<T> {
  LeftToRight({WidgetBuilder builder, RouteSettings settings})
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    var begin = Offset(-1, 0.0);
    var end = Offset(0.0, 0.0);
    var tween = Tween(begin: begin, end: end);
    var offsetAnimation = animation.drive(tween);
    return SlideTransition(
      position: offsetAnimation,
      child: child,
    );
  }
}

class Fade<T> extends MaterialPageRoute<T> {
  Fade({WidgetBuilder builder, RouteSettings settings})
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return new FadeTransition(opacity: animation, child: child);
  }
}

class RightToLeft<T> extends MaterialPageRoute<T> {
  RightToLeft({WidgetBuilder builder, RouteSettings settings})
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    // if (settings.isInitialRoute)
    //   return child;
    // Fades between routes. (If you don't want any animation,
    // just return child.)
    var begin = Offset(1, 0.0);
    var end = Offset(0.0, 0.0);
    var tween = Tween(begin: begin, end: end);
    var offsetAnimation = animation.drive(tween);
    return SlideTransition(
      position: offsetAnimation,
      child: child,
    );

    // return new FadeTransition(opacity: animation, child: child);
  }
}
