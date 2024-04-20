import 'package:flutter/material.dart';
import '../../core/app_export.dart';
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
          Icons.search,
          Icons.person,
        ],
        routes: [
          AppRoutes.postsScreen,
          AppRoutes.postsScreen,
          AppRoutes.profileScreen,
        ],
      ),
    );
  }
}
