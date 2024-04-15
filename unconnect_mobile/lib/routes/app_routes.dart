import 'package:flutter/material.dart';
import '../core/app_export.dart';
import '../presentation/get_started_screen/get_started_screen.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/register_screen/register_screen.dart';
import '../presentation/data_screen/data_screen.dart';

// ignore_for_file: must_be_immutable
class AppRoutes {

  static const String registerScreen = '/register_screen';

  static const String loginScreen = '/login_screen';

  static const String dataScreen = '/data_screen';


  static const String initialRoute = '/initialRoute';

  static Map<String, WidgetBuilder> routes = {
    initialRoute: (context) => GetStartedScreen(),
    registerScreen: (context) => RegisterScreen(),
    loginScreen: (context) => LoginScreen(),
    dataScreen: (context) => DataScreen(),
  };
}
