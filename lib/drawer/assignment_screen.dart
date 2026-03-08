import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../screens/footer.dart';

class AssignmentScreen extends StatelessWidget {
  const AssignmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF141840),
                    Color(0xFF020617),
                    Color(0xFF1C1736),
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const SizedBox(width: 20),
                      const Text(
                        'Assignments',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 8,),

                Icon(
                  Icons.assignment_outlined,
                  size: 64,
                  color:  Colors.white,
                ),
                const SizedBox(height: 16),
                Text(
                  'No Assignments Yet!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enjoy the free time 🎉',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),

                const Spacer(flex: 10),
                const AppFooter(),
                const SizedBox(height: 100,)
              ],
            ),
          ),
        ],
      ),
    );
  }
}