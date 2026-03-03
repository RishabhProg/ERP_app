import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AssignmentScreen extends StatelessWidget {
  const AssignmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.3,
              child: Lottie.asset(
                'assets/night.json',
                frameRate: FrameRate(30),
                fit: BoxFit.cover,
                repeat: true,
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
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new,
                            color: Color(0xFF1A1A2E), size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Assignments',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 7,),

                Icon(
                  Icons.assignment_outlined,
                  size: 64,
                  color: const Color(0xFF1A1A2E),
                ),
                const SizedBox(height: 16),
                Text(
                  'No Assignments Yet!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enjoy the free time 🎉',
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),

                const Spacer(flex: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}