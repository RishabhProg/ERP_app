import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../bloc/auth_bloc/auth_bloc.dart';
import '../bloc/profile_bloc/profile_bloc.dart';
import '../bloc/profile_bloc/profile_event.dart';
import '../bloc/profile_bloc/profile_state.dart';
import '../bloc/final_attendance_Bloc/final_attendance_bloc.dart';
import '../bloc/final_attendance_Bloc/final_attendance_event.dart';
import '../bloc/TT_bloc/tt_bloc.dart';
import '../drawer/assignment_screen.dart';
import '../drawer/eidentity_screen.dart';
import '../drawer/profile_screen.dart';
import '../models/login_response.dart';
import '../repository/final_attendance_repo.dart';
import '../repository/profile_repository.dart';
import '../repository/transport_attendance_repo.dart';
import '../screens/transport_attendance_screen.dart';
import '../screens/test.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;
  LoginResponse? _loginResponse;
  String _rollNumber = '';
  ProfileBloc? _profileBloc;

  // AttendanceBloc lives here — shared by Test and ProfileScreen
  late final AttendanceBloc _attendanceBloc;

  @override
  void initState() {
    super.initState();
    _attendanceBloc = AttendanceBloc(AttendanceRepository())
      ..add(LoadSemestersAndAttendance());
    _loadCredentials();
  }

  Future<void> _loadCredentials() async {
    const storage = FlutterSecureStorage();
    final accessToken = await storage.read(key: 'accessToken');
    final sessionId = await storage.read(key: 'sessionId');
    final xUserId = await storage.read(key: 'xUserId');
    final xToken = await storage.read(key: 'xToken');

    if (accessToken != null &&
        sessionId != null &&
        xUserId != null &&
        xToken != null) {
      final loginResponse = LoginResponse(
        accessToken: accessToken,
        sessionId: sessionId,
        xUserId: xUserId,
        xToken: xToken,
      );

      _profileBloc?.close();
      final freshBloc = ProfileBloc(
        profileRepository: ProfileRepository(),
        loginResponse: loginResponse,
      )..add(FetchProfile());

      setState(() {
        _loginResponse = loginResponse;
        _profileBloc = freshBloc;
      });
    }
  }

  @override
  void dispose() {
    _profileBloc?.close();
    _attendanceBloc.close();
    super.dispose();
  }

  Widget _bg(Widget child) => Material(
    color: Colors.transparent,
    child: Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF141840), Color(0xFF020617), Color(0xFF1C1736)],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: child,
    ),
  );

  List<Widget> _buildScreens(AuthBloc authBloc) {
    return [
      // 0 — Dashboard — gets AttendanceBloc from shell via context
      const Test(),

      // 1 — E-Identity
      const EIdentityScreen(),

      // 2 — Assignment
      const AssignmentScreen(),

      // 3 — Technical Training
      BlocProvider(
        create: (_) => TransportAttendanceBloc(
          TransportAttendanceRepo(const FlutterSecureStorage()),
        ),
        child: MandatoryAttendanceScreen(admissionNumber: _rollNumber),
      ),

      // 4 — Profile — uses shell-level _attendanceBloc directly
      if (_profileBloc != null)
        BlocProvider.value(
          value: _profileBloc!,
          child: ProfileScreen(
            attendanceBloc: _attendanceBloc,
            authBloc: authBloc,
          ),
        )
      else
        _bg(
          const Center(
            child: CircularProgressIndicator(color: Color(0xFF2E9E5B)),
          ),
        ),
    ];
  }

  Widget _navItem(IconData icon, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.35),
          size: 24,
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: Colors.white.withOpacity(0.12),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(Icons.grid_view_rounded, 0),
                _navItem(Icons.badge_outlined, 1),
                _navItem(Icons.assignment_outlined, 2),
                _navItem(Icons.computer_outlined, 3),
                _navItem(Icons.person_outline_rounded, 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authBloc = context.read<AuthBloc>();

    if (_profileBloc == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF020617),
        body: _bg(
          const Center(
            child: CircularProgressIndicator(color: Color(0xFF2E9E5B)),
          ),
        ),
        floatingActionButton: _buildBottomNav(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      );
    }

    // Provide both blocs above IndexedStack so ALL screens can access them
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _profileBloc!),
        BlocProvider.value(value: _attendanceBloc),
      ],
      child: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoaded) {
            final rollNumber = state.profile.rollNumber ?? '';
            if (rollNumber != _rollNumber) {
              setState(() => _rollNumber = rollNumber);
            }
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFF020617),
          body: IndexedStack(
            index: _selectedIndex,
            children: _buildScreens(authBloc),
          ),
          floatingActionButton: _buildBottomNav(),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        ),
      ),
    );
  }
}