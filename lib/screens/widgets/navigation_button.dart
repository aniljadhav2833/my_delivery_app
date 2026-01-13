import 'package:flutter/material.dart';

class NavigationButton extends StatelessWidget {
  final String title;
  final Widget screen;

  const NavigationButton({
    super.key,
    required this.title,
    required this.screen,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: Text(title),
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
      },
    );
  }
}
