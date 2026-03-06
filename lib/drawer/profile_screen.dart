import 'dart:ui';
import 'package:erp_app/bloc/profile_bloc/profile_state.dart';
import 'package:erp_app/models/profile_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc/auth_bloc.dart';
import '../bloc/auth_bloc/auth_event.dart';
import '../bloc/final_attendance_Bloc/final_attendance_bloc.dart';
import '../bloc/final_attendance_Bloc/final_attendance_state.dart';
import '../bloc/profile_bloc/profile_bloc.dart';
import '../bloc/profile_bloc/profile_event.dart';
import '../screens/footer.dart';

class ProfileScreen extends StatelessWidget {
  final String courseName;
  final String batchName;
  final String currentSemester;
  final AttendanceBloc attendanceBloc;

  const ProfileScreen({
    super.key,
    this.courseName = '',
    this.batchName = '',
    this.currentSemester = '',
    required this.attendanceBloc,
  });

  Widget _infoRow(String title, String? value) {
    final displayValue = (value == null || value.trim().isEmpty) ? "-" : value;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.white.withOpacity(0.45),
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              displayValue,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard(String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white.withOpacity(0.07),
              border: Border.all(
                color: Colors.white.withOpacity(0.12),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Divider(color: Colors.white.withOpacity(0.1)),
                const SizedBox(height: 4),
                ...children,
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1C1736),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Logout',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white.withOpacity(0.5)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(LogoutRequested());
            },
            child: const Text(
              'Logout',
              style: TextStyle(
                color: Color(0xFFFF6B6B),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Dark gradient background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF141840),
                    Color(0xFF020617),
                    Color(0xFF1C1736),
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          SafeArea(
            child: BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, state) {
                if (state is ProfileLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF2E9E5B)),
                  );
                }

                if (state is ProfileLoaded) {
                  final profile = state.profile;
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        // Header with back button + logout
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.arrow_back_ios_new,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Profile',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const Spacer(),
                              // Logout button
                              GestureDetector(
                                onTap: () => _showLogoutDialog(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: const Color(0xFFFF6B6B).withOpacity(0.15),
                                    border: Border.all(
                                      color: const Color(0xFFFF6B6B).withOpacity(0.4),
                                      width: 1.2,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(
                                        Icons.logout_rounded,
                                        color: Color(0xFFFF6B6B),
                                        size: 16,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        'Logout',
                                        style: TextStyle(
                                          color: Color(0xFFFF6B6B),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Avatar + name card
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: BackdropFilter(
                              filter:
                              ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: Colors.white.withOpacity(0.07),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.12),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 64,
                                      height: 64,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0xFF2E9E5B)
                                            .withOpacity(0.15),
                                        border: Border.all(
                                          color: const Color(0xFF2E9E5B)
                                              .withOpacity(0.4),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.person,
                                        size: 36,
                                        color: const Color(0xFF2E9E5B)
                                            .withOpacity(0.9),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            profile.fullName,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 17,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            profile.collegeEmail,
                                            style: TextStyle(
                                              color: Colors.white
                                                  .withOpacity(0.45),
                                              fontSize: 13,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        _sectionCard("My Profile", [
                          _infoRow("Full Name", profile.fullName),
                          _infoRow("Roll No.", profile.rollNumber),
                          _infoRow("Date of Birth", profile.dob),
                          _infoRow("Email", profile.collegeEmail),
                          _infoRow("Contact", profile.contactNumber),
                        ]),

                        BlocBuilder<AttendanceBloc, AttendanceState>(
                          bloc: attendanceBloc,
                          builder: (context, attendanceState) {
                            if (attendanceState.isLoading) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: CircularProgressIndicator(
                                      color: Color(0xFF2E9E5B)),
                                ),
                              );
                            }

                            final courseName =
                            attendanceState.semesters.isNotEmpty
                                ? attendanceState
                                .semesters.first.courseName
                                : '-';
                            final batchName =
                            attendanceState.semesters.isNotEmpty
                                ? attendanceState.semesters.first.batchName
                                : '-';
                            final currentSemester = attendanceState
                                .selectedSemesterId
                                .toString() ??
                                '-';

                            return _sectionCard("Academic Details", [
                              _infoRow("Course", courseName),
                              _infoRow("Batch", batchName),
                              _infoRow(
                                  "Semester", 'Semester $currentSemester'),
                            ]);
                          },
                        ),

                        _sectionCard("Family Details", [
                          _infoRow("Father's Name", profile.fatherName),
                          _infoRow("Mother's Name", profile.motherName),
                          _infoRow(
                              "Parent Contact", profile.parentMobileNumber),
                          _infoRow("Address", profile.address),
                        ]),

                        const AppFooter(),
                      ],
                    ),
                  );
                }

                if (state is ProfileError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.wifi_off_rounded,
                              size: 64,
                              color: Colors.white.withOpacity(0.2)),
                          const SizedBox(height: 16),
                          Text(
                            state.error,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 15,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => context
                                .read<ProfileBloc>()
                                .add(FetchProfile()),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E9E5B),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Retry',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}