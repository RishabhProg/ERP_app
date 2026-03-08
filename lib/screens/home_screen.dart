// import 'package:erp_app/bloc/auth_bloc/auth_bloc.dart';
// import 'package:erp_app/bloc/auth_bloc/auth_event.dart';
// import 'package:erp_app/bloc/auth_bloc/auth_state.dart';
// import 'package:erp_app/bloc/profile_bloc/profile_bloc.dart';
// import 'package:erp_app/bloc/profile_bloc/profile_event.dart';
// import 'package:erp_app/models/login_response.dart';
// import 'package:erp_app/repository/profile_repository.dart';
// import 'package:erp_app/screens/test.dart';
// import 'package:erp_app/screens/forgot_password.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   final TextEditingController _usernameController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();

//   /// Handles login logic: Validates input, stores credentials, dispatches login event
//   void _handleLogin() {
//     final username = _usernameController.text.trim();
//     final password = _passwordController.text.trim();

//     if (username.isNotEmpty && password.isNotEmpty) {
//       const FlutterSecureStorage secureStorage = FlutterSecureStorage();
//       secureStorage.write(key: 'stored_username', value: username);
//       secureStorage.write(key: 'stored_password', value: password);

//       context.read<AuthBloc>().add(
//         LoginRequested(username: username, password: password),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Please enter both username and password"),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.symmetric(horizontal: 24.0),
//             child: BlocConsumer<AuthBloc, AuthState>(
//               listener: (context, state) {
//                 if (state is AuthSuccess) {
//                   // Create login response from auth state
//                   final loginResponse = LoginResponse(
//                     accessToken: state.accessToken,
//                     sessionId: state.sessionId,
//                     xUserId: state.xUserId,
//                     xToken: state.xToken,
//                   );

//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text("Login Successful")),
//                   );

//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(
//                       builder:
//                           (_) => BlocProvider(
//                             create:
//                                 (_) => ProfileBloc(
//                                   profileRepository: ProfileRepository(),
//                                   loginResponse: loginResponse,
//                                 )..add(FetchProfile()),
//                             child: const Test(),
//                           ),
//                     ),
//                   );
//                 } else if (state is AuthFailure) {
//                   ScaffoldMessenger.of(
//                     context,
//                   ).showSnackBar(SnackBar(content: Text(state.errorMessage)));
//                 }
//               },
//               builder: (context, state) {
//                 return Column(
//                   children: [
//                     const Padding(
//                       padding: EdgeInsets.only(top: 80.0),
//                       child: Text(
//                         "Let's Get Started...",
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 32,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 40),
//                     Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       child: Column(
//                         children: [
//                           TextFormField(
//                             controller: _usernameController,
//                             decoration: const InputDecoration(
//                               prefixIcon: Icon(Icons.person),
//                               labelText: 'Username',
//                               border: OutlineInputBorder(),
//                             ),
//                           ),
//                           const SizedBox(height: 10),
//                           TextFormField(
//                             controller: _passwordController,
//                             obscureText: true,
//                             decoration: const InputDecoration(
//                               prefixIcon: Icon(Icons.lock),
//                               labelText: 'Password',
//                               border: OutlineInputBorder(),
//                             ),
//                           ),
//                           const SizedBox(height: 10),
//                           SizedBox(
//                             width: double.infinity,
//                             child: ElevatedButton(
//                               onPressed:
//                                   state is AuthLoading ? null : _handleLogin,
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.green[700],
//                                 padding: const EdgeInsets.symmetric(
//                                   vertical: 16,
//                                 ),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                               ),
//                               child:
//                                   state is AuthLoading
//                                       ? const CircularProgressIndicator(
//                                         color: Colors.white,
//                                       )
//                                       : const Text(
//                                         'SIGN IN',
//                                         style: TextStyle(
//                                           color: Colors.white,
//                                           fontSize: 18,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//                     TextButton(
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) => const ForgotPasswordScreen(),
//                           ),
//                         );
//                       },
//                       child: const Text(
//                         'Forgot Password?',
//                         style: TextStyle(color: Colors.green, fontSize: 16),
//                       ),
//                     ),
//                   ],
//                 );
//               },
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'dart:ui';

import 'package:erp_app/bloc/auth_bloc/auth_bloc.dart';
import 'package:erp_app/bloc/auth_bloc/auth_event.dart';
import 'package:erp_app/bloc/auth_bloc/auth_state.dart';
import 'package:erp_app/bloc/profile_bloc/profile_bloc.dart';
import 'package:erp_app/bloc/profile_bloc/profile_event.dart';
import 'package:erp_app/main_shell.dart';
import 'package:erp_app/models/login_response.dart';
import 'package:erp_app/repository/profile_repository.dart';
import 'package:erp_app/screens/test.dart';
import 'package:erp_app/screens/forgot_password.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lottie/lottie.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _handleLogin() {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isNotEmpty && password.isNotEmpty) {
      const FlutterSecureStorage secureStorage = FlutterSecureStorage();
      secureStorage.write(key: 'stored_username', value: username);
      secureStorage.write(key: 'stored_password', value: password);

      context.read<AuthBloc>().add(
        LoginRequested(username: username, password: password),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please enter both username and password"),
          backgroundColor: const Color(0xFFE53935),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: Stack(
        children: [

          // Positioned.fill(
          //   child: Container(
          //     color: const Color(0xFF020617).withOpacity(0.5),
          //   ),
          // ),

        Positioned.fill(
          child: Image.asset(
            'assets/lock_back.png',
            fit: BoxFit.cover,
          ),
        ),
          // Dark overlay


       SafeArea(
            // Main content
         child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: BlocConsumer<AuthBloc, AuthState>(
                  listener: (context, state) {
                    if (state is AuthSuccess) {
                      final loginResponse = LoginResponse(
                        accessToken: state.accessToken,
                        sessionId: state.sessionId,
                        xUserId: state.xUserId,
                        xToken: state.xToken,
                      );
                      print('login was done');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text("Login Successful"),
                          backgroundColor: const Color(0xFF2E9E5B),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider(
                            create: (_) => ProfileBloc(
                              profileRepository: ProfileRepository(),
                              loginResponse: loginResponse,
                            )..add(FetchProfile()),
                            child: const MainShell(),
                          ),
                        ),
                      );
                    } else if (state is AuthFailure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.errorMessage),
                          backgroundColor: const Color(0xFFE53935),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    return Column(
                      children: [
                        const SizedBox(height: 60),

                        // Title
                        const Text(
                          "Welcome Back",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Sign in to continue",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.45),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Glass card
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                color: const Color(0xFF1A1F2E).withOpacity(0.6),
                                border: Border.all(
                                  color: Colors.black.withOpacity(0.1),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 30,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // Username field
                                  TextFormField(
                                    controller: _usernameController,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(
                                        Icons.person_outline,
                                        color: Colors.white.withOpacity(0.5),
                                      ),
                                      hintText: 'Username',
                                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                                      filled: true,
                                      fillColor: const Color(0xFF252B3B),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 14),

                                  // Password field
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: true,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(
                                        Icons.lock_outline,
                                        color: Colors.white.withOpacity(0.5),
                                      ),
                                      hintText: 'Password',
                                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                                      filled: true,
                                      fillColor: const Color(0xFF252B3B),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Sign in button
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: state is AuthLoading ? null : _handleLogin,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF2E9E5B),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                      ),
                                      child: state is AuthLoading
                                          ? const CircularProgressIndicator(color: Color(0xFF2E9E5B))
                                          : const Text(
                                        'Sign In',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Forgot password
                        // TextButton(
                        //   onPressed: () {
                        //     Navigator.push(
                        //       context,
                        //       MaterialPageRoute(
                        //         builder: (_) => const ForgotPasswordScreen(),
                        //       ),
                        //     );
                        //   },
                        //   child: Text(
                        //     'Forgot Password?',
                        //     style: TextStyle(
                        //       color: const Color(0xFF1A1A2E).withOpacity(0.5),
                        //       fontSize: 14,
                        //       fontWeight: FontWeight.w500,
                        //     ),
                        //   ),
                        // ),
                      ],
                    );
                  },
                ),
              ),
            ),
      ),
      ]
    )
    );
  }
}

