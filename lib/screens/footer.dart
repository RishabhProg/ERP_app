import 'package:flutter/material.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 8),
      child: Center(
        child: Text(
          'Designed & Developed by\nBig Data Centre of Excellence',
          style: TextStyle(
            fontSize: 11,
            color: const Color(0xFF1A1A2E).withOpacity(0.9),
            letterSpacing: 0.3,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}