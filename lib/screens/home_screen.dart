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

import 'package:erp_app/bloc/auth_bloc/auth_bloc.dart';
import 'package:erp_app/bloc/auth_bloc/auth_event.dart';
import 'package:erp_app/bloc/auth_bloc/auth_state.dart';
import 'package:erp_app/bloc/profile_bloc/profile_bloc.dart';
import 'package:erp_app/bloc/profile_bloc/profile_event.dart';
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
        const SnackBar(
          content: Text("Please enter both username and password"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Lottie background
            Positioned.fill(
              child: Lottie.asset(
                'assets/loginback.json', // Your Lottie file
                fit: BoxFit.cover,
                repeat: true,
              ),
            ),

            // Main content
            Center(
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

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Login Successful")),
                      );

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider(
                            create: (_) => ProfileBloc(
                              profileRepository: ProfileRepository(),
                              loginResponse: loginResponse,
                            )..add(FetchProfile()),
                            child: const Test(),
                          ),
                        ),
                      );
                    } else if (state is AuthFailure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.errorMessage)),
                      );
                    }
                  },
                  builder: (context, state) {
                    return Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 40.0, bottom: 20),
                          child: Text(
                            "ERP Login",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5), // Transparent white
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white30,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _usernameController,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.person, color: Colors.white),
                                  labelText: 'Username',
                                  labelStyle: const TextStyle(color: Colors.white70),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Colors.white24),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Colors.white),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.lock, color: Colors.white),
                                  labelText: 'Password',
                                  labelStyle: const TextStyle(color: Colors.white70),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Colors.white24),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: Colors.white),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: state is AuthLoading ? null : _handleLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green[700],
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: state is AuthLoading
                                      ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                      : const Text(
                                          'SIGN IN',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ForgotPasswordScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(color: Colors.green, fontSize: 16),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

