// screens/splash_screen.dart
import 'package:erp_app/screens/splashwrapper.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () async {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SplashWrapper()),
        );
    });
  }

  Widget _buildGlowCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withOpacity(0),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617), // Deep dark slate background
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Smooth dark gradient background for better blending with dark theme
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF020617),
                  Color(0xFF0F172A),
                  Color(0xFF020617),
                ],
              ),
            ),
          ),
          
          // Refined glow circles with updated colors for premium dark theme integration
          Positioned(
            top: -100,
            right: -50,
            child: _buildGlowCircle(400, const Color(0xFF6366F1).withOpacity(0.12)),
          ),
          
          Positioned(
            top: 150,
            left: -80,
            child: _buildGlowCircle(300, const Color(0xFF4F46E5).withOpacity(0.08)),
          ),

          Positioned(
            bottom: -150,
            left: -100,
            child: _buildGlowCircle(500, const Color(0xFF1E1B4B).withOpacity(0.15)),
          ),

          Positioned(
            bottom: 200,
            right: -40,
            child: _buildGlowCircle(250, const Color(0xFF312E81).withOpacity(0.1)),
          ),

          // Main content
          Column(
            children: [
              const Spacer(flex: 4),
              const Text(
                'Welcome to\nUpMark !',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 42,
                  height: 1.3,
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  shadows: [
                    Shadow(
                      color: Colors.black45,
                      offset: Offset(0, 4),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 2),
              // Icon container with soft glow to blend with the background
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.15),
                      blurRadius: 60,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: Image.asset(
                    'assets/icon.png',
                    width: 280,
                    height: 280,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const Spacer(flex: 1),
              Lottie.asset(
                'assets/line loader.json',
                width: 300,
                height: 150,
                fit: BoxFit.contain,
              ),
              const Spacer(flex: 2),
            ],
          ),
        ],
      ),
    );
  }
}
