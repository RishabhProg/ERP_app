import 'dart:io';

import 'package:erp_app/bloc/auth_bloc/auth_bloc.dart';
import 'package:erp_app/bloc/auth_bloc/auth_event.dart';
import 'package:erp_app/bloc/auth_bloc/auth_state.dart';
import 'package:erp_app/bloc/profile_bloc/profile_bloc.dart';
import 'package:erp_app/bloc/profile_bloc/profile_event.dart';
import 'package:erp_app/models/login_response.dart';
import 'package:erp_app/repository/profile_repository.dart';
import 'package:erp_app/screens/dashboard_screen.dart';
import 'package:erp_app/screens/home_screen.dart';
import 'package:erp_app/screens/splash_screen.dart';
import 'package:erp_app/screens/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erp_app/bloc/final_attendance_Bloc/final_attendance_bloc.dart';
import 'package:erp_app/bloc/final_attendance_Bloc/final_attendance_event.dart';
import 'package:erp_app/repository/final_attendance_repo.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SplashWrapper extends StatefulWidget {
  const SplashWrapper({super.key});

  @override
  State<SplashWrapper> createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<SplashWrapper> {

  @override
  void initState() {
    super.initState();
    _checkSession();
  }
  //check if the session is stale
  Future<void> _checkSession() async{
    const storage = FlutterSecureStorage();
    final expiry = await storage.read(key: 'tokenExpiry');

    if(expiry != null){
      final expiryDate = DateTime.fromMillisecondsSinceEpoch(int.parse(expiry));
      if (DateTime.now().isBefore(expiryDate)) {
        await _goToDashBoard(storage);
        return;
      }
    }

    //session expired
    final username = await storage.read(key: 'stored_username');
    final password = await storage.read(key: 'stored_password');

    if(username != null && password != null){
      context.read<AuthBloc>().add(LoginRequested(username: username, password: password));
    }
    else{
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    }
  }


  //session active
  Future<void> _goToDashBoard(FlutterSecureStorage storage) async{
    final accessToken = await storage.read(key: 'accessToken');
    final sessionId = await storage.read(key: 'sessionId');
    final xUserId = await storage.read(key: 'xUserId');
    final xToken = await storage.read(key: 'xToken');
    final expiresIn = await storage.read(key: 'tokenExpiry');

    if (accessToken == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
      return;
    }
    final loginResponse = LoginResponse(
      accessToken: accessToken,
      sessionId: sessionId!,
      xUserId: xUserId!,
      xToken: xToken!,
    );
    final profileBloc = ProfileBloc(
      profileRepository: ProfileRepository(),
      loginResponse: loginResponse,
    )..add(FetchProfile());

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider<ProfileBloc>.value(value: profileBloc),
            BlocProvider<AttendanceBloc>(
              create: (_) => AttendanceBloc(AttendanceRepository())
                ..add(LoadSemestersAndAttendance()),
            ),
          ],
          child: const Test(),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthSuccess) {
          // Save new expiry
          const storage = FlutterSecureStorage();
          await storage.write(key: 'accessToken', value: state.accessToken);
          await storage.write(key: 'sessionId', value: state.sessionId);
          await storage.write(key: 'xUserId', value: state.xUserId);
          await storage.write(key: 'xToken', value: state.xToken);

          final expiryMs = DateTime.now()
              .add(Duration(seconds: state.expiresIn))
              .millisecondsSinceEpoch
              .toString();
          await storage.write(key: 'tokenExpiry', value: expiryMs);
          await _goToDashBoard(storage);

        } else if (state is AuthFailure) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      },
      builder: (context, state) {
        return const SplashScreen();
      },
    );
  }
}
