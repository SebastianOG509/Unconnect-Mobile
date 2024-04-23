import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../widgets/custom_bottom_app_bar.dart';

class PostsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'UNConnect',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF08163B),
      ),
      body: Center(
        child: Text(
          'PostsScreens',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomAppBar(
        icons: [
          Icons.home,
          Icons.groups,
          Icons.post_add,
          Icons.person,
        ],
        routes: [
          AppRoutes.postsScreen,
          AppRoutes.groupstartScreen,
          AppRoutes.mypostsScreen,
          AppRoutes.profileScreen,
        ],
      ),
    );
  }
}
