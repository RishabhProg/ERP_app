// screens/splash_screen.dart
import 'package:erp_app/bloc/auth_bloc/auth_bloc.dart';
import 'package:erp_app/bloc/auth_bloc/auth_event.dart';
import 'package:erp_app/screens/dashboard_screen.dart';
import 'package:erp_app/screens/splashwrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lottie/lottie.dart';
import 'home_screen.dart';

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
   
        // User is not logged in, navigate to LoginScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SplashWrapper()),
        );
      
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Decorative circles
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2E9E5B).withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            top: 80,
            right: 20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2E9E5B).withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE53935).withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            bottom: 120,
            left: 30,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2E9E5B).withOpacity(0.07),
              ),
            ),
          ),



          // Main content
          Column(
            children: [
              const Spacer(flex: 4), // more space at top
              const Text(
                'Welcome to\nEdumarshal !',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 40,
                  height: 1.5,
                  color: Color(0xFF1A1A2E),
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(flex: 2), // space between text and image
              Image.asset(
                'assets/app_loader1.png',
                width: 300,
                height: 300,
              ),
              const Spacer(flex: 1), // space between image and lottie
              Lottie.asset(
                'assets/line loader.json',
                width: 300,
                height: 150,
                fit: BoxFit.contain,
              ),
              const Spacer(flex: 2), // space at bottom
            ],
          ),
        ],
      ),
    );
  }
}
