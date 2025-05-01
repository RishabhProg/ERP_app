import 'package:erp_app/bloc/Attendance_bloc/attendance_bloc.dart';
import 'package:erp_app/bloc/auth_bloc/auth_bloc.dart';
import 'package:erp_app/bloc/final_attendance_Bloc/final_attendance_bloc.dart';
import 'package:erp_app/bloc/profile_bloc/profile_bloc.dart';
import 'package:erp_app/bloc/auth_bloc/auth_event.dart';
import 'package:erp_app/models/login_response.dart';
import 'package:erp_app/repository/attendance_repo.dart';
import 'package:erp_app/repository/final_attendance_repo.dart';
import 'package:erp_app/screens/attendance_info.dart';
import 'package:erp_app/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erp_app/repository/auth_repository.dart';
import 'package:erp_app/repository/profile_repository.dart';
import 'package:erp_app/bloc/profile_bloc/profile_bloc.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository = AuthRepository();
  final ProfileRepository profileRepository = ProfileRepository();
  //final AttendanceRepo attendanceRepository = AttendanceRepo();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(authRepository)..add(CheckAuthStatus()),
        ),
       
        BlocProvider(create: (_) => AttendanceBloc(AttendanceRepository())),
        // Add more BLoCs here if needed
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      ),
    );
  }
}
