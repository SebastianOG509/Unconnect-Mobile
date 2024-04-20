import 'package:flutter/material.dart';

class CustomBottomAppBar extends StatelessWidget {
  final List<IconData> icons;
  final List<String> routes;

  const CustomBottomAppBar({
    required this.icons,
    required this.routes,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      elevation: 0,
      color: Colors.white,
      child: SizedBox(
        height: 60.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(
            icons.length,
                (index) => IconButton(
              icon: Icon(icons[index]),
              color: Color(0xFF08163B),
              onPressed: () {
                Navigator.pushNamed(context, routes[index]);
              },
            ),
          ),
        ),
      ),
    );
  }
}
