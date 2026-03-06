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
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erp_app/repository/auth_repository.dart';
import 'package:erp_app/repository/profile_repository.dart';
import 'package:erp_app/bloc/profile_bloc/profile_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';

Future<void> clearOnUpdate() async {
  final prefs = await SharedPreferences.getInstance();
  final packageInfo = await PackageInfo.fromPlatform();
  final currentVersion = packageInfo.version; // e.g. "1.0.1"

  final storedVersion = prefs.getString('appVersion');

  if (storedVersion != currentVersion) {
    const storage = FlutterSecureStorage();
    await storage.deleteAll();
    await prefs.setString('appVersion', currentVersion);
    debugPrint('Version changed $storedVersion → $currentVersion, storage cleared');
  }
}

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
          create: (context) => AuthBloc(authRepository),
        ),
       
        BlocProvider(create: (_) => AttendanceBloc(AttendanceRepository())),
        // Add more BLoCs here if needed
      ],
      child: MaterialApp(
       // showPerformanceOverlay: true,
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      ),
    );
  }
}
