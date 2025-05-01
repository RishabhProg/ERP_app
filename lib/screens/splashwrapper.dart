import 'package:erp_app/bloc/auth_bloc/auth_bloc.dart';
import 'package:erp_app/bloc/auth_bloc/auth_state.dart';
import 'package:erp_app/bloc/profile_bloc/profile_bloc.dart';
import 'package:erp_app/bloc/profile_bloc/profile_event.dart';
import 'package:erp_app/models/login_response.dart';
import 'package:erp_app/repository/profile_repository.dart';
import 'package:erp_app/screens/dashboard_screen.dart';
import 'package:erp_app/screens/home_screen.dart';
import 'package:erp_app/screens/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erp_app/bloc/final_attendance_Bloc/final_attendance_bloc.dart';
import 'package:erp_app/bloc/final_attendance_Bloc/final_attendance_event.dart';
import 'package:erp_app/repository/final_attendance_repo.dart';

class SplashWrapper extends StatelessWidget {
  const SplashWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Scaffold(
            backgroundColor: Color(0xFF1E1E1E),
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (state is AuthSuccess) {
          final loginResponse = LoginResponse(
            accessToken: state.accessToken,
            sessionId: state.sessionId,
            xUserId: state.xUserId,
            xToken: state.xToken,
          );

          final profileBloc = ProfileBloc(
            profileRepository: ProfileRepository(),
            loginResponse: loginResponse,
          )..add(FetchProfile());

          return MultiBlocProvider(
            providers: [
              BlocProvider<ProfileBloc>.value(
                value: profileBloc, // use the same instance you created
              ),
              BlocProvider<AttendanceBloc>(
                create:
                    (_) =>
                        AttendanceBloc(AttendanceRepository())
                          ..add(LoadSemestersAndAttendance()),
              ),
            ],
            child: const Test(),
          );
        } else {
          return const HomeScreen();
        }
      },
    );
  }
}
