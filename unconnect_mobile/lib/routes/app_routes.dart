import 'package:flutter/material.dart';
import 'package:unconnect_mobile/presentation/group_screen/group_screen.dart';
import '../presentation/get_started_screen/get_started_screen.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/register_screen/register_screen.dart';
import '../presentation/dataregister_screen/dataregister_screen.dart';
import '../presentation/posts_screen/posts_screen.dart';
import '../presentation/profile_screen/profile_screen.dart';
import '../presentation/myposts_screen/myposts_screen.dart';
import '../presentation/createpost_screen/createpost_screen.dart';
import '../presentation/creategroup_screen/creategroup_screen.dart';
import '../presentation/groupstart_screen/groupstart_screen.dart';
import '../presentation/datagroup_screen/datagroup_screen.dart';
// ignore_for_file: must_be_immutable
class AppRoutes {

  static const String registerScreen = '/register_screen';

  static const String loginScreen = '/login_screen';

  static const String dataScreen = '/dataregister_screen';

  static const String postsScreen = '/posts_screen';

  static const String profileScreen = '/profile_screen';

  static const String mypostsScreen = '/myposts_screen';

  static const String createpostScreen = '/createpost_screen';

  static const String createGroupScreen = '/creategroup_screen';

  static const String groupScreen = '/group_screen';

  static const String groupstartScreen = '/groupstart_screen';

  static const String dataGroupScreen = '/dataGroup_screen';

  static const String initialRoute = '/initialRoute';

  static Map<String, WidgetBuilder> routes = {
    initialRoute: (context) => GetStartedScreen(),
    registerScreen: (context) => RegisterScreen(),
    loginScreen: (context) => LoginScreen(),
    dataScreen: (context) => DataScreen(),
    postsScreen: (context) => PostsScreen(),
    profileScreen: (context) => ProfileScreen(),
    mypostsScreen: (context) => MypostsScreen(),
    createpostScreen: (context) => CreatepostScreen(),
    groupScreen: (context) => GroupScreen(),
    groupstartScreen: (context) => GroupsStartScreen(),
    createGroupScreen: (context) => CreateGroupScreen(),
    dataGroupScreen: (context) => DataGroupScreen(),
  };
}
