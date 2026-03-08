import 'dart:ui';
import 'package:erp_app/bloc/profile_bloc/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc/auth_bloc.dart';
import '../bloc/auth_bloc/auth_event.dart';
import '../bloc/auth_bloc/auth_state.dart';
import '../bloc/final_attendance_Bloc/final_attendance_bloc.dart';
import '../bloc/final_attendance_Bloc/final_attendance_event.dart';
import '../bloc/final_attendance_Bloc/final_attendance_state.dart';
import '../bloc/profile_bloc/profile_bloc.dart';
import '../bloc/profile_bloc/profile_event.dart';
import '../screens/footer.dart';
import '../screens/home_screen.dart';

class ProfileScreen extends StatelessWidget {
  final String courseName;
  final String batchName;
  final String currentSemester;
  final AttendanceBloc attendanceBloc;
  final AuthBloc authBloc;

  const ProfileScreen({
    super.key,
    this.courseName = '',
    this.batchName = '',
    this.currentSemester = '',
    required this.attendanceBloc,
    required this.authBloc,
  });

  // Stacked label + value layout matching the design
  Widget _infoRow(String label, String? value) {
    final displayValue = (value == null || value.trim().isEmpty) ? "-" : value;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white.withOpacity(0.4),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            displayValue,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard(String title, IconData icon, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            Row(
              children: [
                Icon(icon, color: const Color(0xFF7B6FF0), size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Divider(color: Colors.white.withOpacity(0.1)),
            const SizedBox(height: 4),
            ...children,
          ],
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
          'Sign Out',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to sign out?',
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
              authBloc.add(LogoutRequested());
            },
            child: const Text(
              'Sign Out',
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
    return BlocListener<AuthBloc, AuthState>(
      bloc: authBloc,
      listener: (context, state) {
        if (state is AuthInitial) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
                (route) => false,
          );
        }
      },
      child: Scaffold(
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
                      child: CircularProgressIndicator(
                          color: Color(0xFF2E9E5B)),
                    );
                  }

                  if (state is ProfileLoaded) {
                    final profile = state.profile;
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          // Header — back button + title only
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                const SizedBox(width: 20),
                                const Text(
                                  'Profile',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
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
                                      // Avatar with purple ring + green dot
                                      Stack(
                                        children: [
                                          Container(
                                            width: 68,
                                            height: 68,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: const Color(0xFF7B6FF0),
                                                width: 2.5,
                                              ),
                                            ),
                                            child: Container(
                                              margin: const EdgeInsets.all(3),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white
                                                    .withOpacity(0.08),
                                              ),
                                              child: Icon(
                                                Icons.person,
                                                size: 34,
                                                color: Colors.white
                                                    .withOpacity(0.7),
                                              ),
                                            ),
                                          ),
                                          // Green online dot
                                          Positioned(
                                            bottom: 2,
                                            right: 2,
                                            child: Container(
                                              width: 14,
                                              height: 14,
                                              decoration: BoxDecoration(
                                                color:
                                                const Color(0xFF2E9E5B),
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: const Color(
                                                      0xFF141840),
                                                  width: 2,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
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
                                                fontSize: 12,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 8),
                                            // Active Student badge
                                            Container(
                                              padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                  vertical: 4),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF7B6FF0)
                                                    .withOpacity(0.2),
                                                borderRadius:
                                                BorderRadius.circular(20),
                                                border: Border.all(
                                                  color: const Color(
                                                      0xFF7B6FF0)
                                                      .withOpacity(0.4),
                                                  width: 1,
                                                ),
                                              ),
                                              child: const Text(
                                                'ACTIVE STUDENT',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF7B6FF0),
                                                  letterSpacing: 0.8,
                                                ),
                                              ),
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

                          // Personal Information
                          _sectionCard(
                            "Personal Information",
                            Icons.person_outline_rounded,
                            [
                              _infoRow("Full Name", profile.fullName),
                              _infoRow("Roll No.", profile.rollNumber),
                              _infoRow("Date of Birth", profile.dob),
                              _infoRow("Email Address", profile.collegeEmail),
                              _infoRow("Contact", profile.contactNumber),
                            ],
                          ),

                          // Academic Details
                          BlocBuilder<AttendanceBloc, AttendanceState>(
                            // Remove: bloc: attendanceBloc,
                            builder: (context, attendanceState) {
                              // If still loading after a while, trigger a fetch
                              if (attendanceState.isLoading) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Center(
                                    child: CircularProgressIndicator(color: Color(0xFF2E9E5B)),
                                  ),
                                );
                              }

                              // If semesters are empty but not loading, it never fetched — trigger it
                              if (attendanceState.semesters.isEmpty) {
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  context.read<AttendanceBloc>().add(LoadSemestersAndAttendance());
                                });
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Center(
                                    child: CircularProgressIndicator(color: Color(0xFF2E9E5B)),
                                  ),
                                );
                              }

                              final courseName = attendanceState.semesters.first.courseName;
                              final batchName = attendanceState.semesters.first.batchName;
                              final currentSemester = attendanceState.selectedSemesterId.toString();

                              return _sectionCard(
                                "Academic Details",
                                Icons.school_outlined,
                                [
                                  _infoRow("Course", courseName),
                                  _infoRow("Batch", batchName),
                                  _infoRow("Semester", 'Semester $currentSemester'),
                                ],
                              );
                            },
                          ),

                          // Family Details
                          _sectionCard(
                            "Family Details",
                            Icons.people_outline_rounded,
                            [
                              _infoRow("Father's Name", profile.fatherName),
                              _infoRow("Mother's Name", profile.motherName),
                              _infoRow("Parent Contact",
                                  profile.parentMobileNumber),
                              _infoRow("Address", profile.address),
                            ],
                          ),

                          // Sign Out button
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                            child: GestureDetector(
                              onTap: () => _showLogoutDialog(context),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                  child: Container(
                                    width: double.infinity,
                                    padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      color: const Color(0xFFB71C1C)
                                          .withOpacity(0.35),
                                      border: Border.all(
                                        color: const Color(0xFFFF6B6B)
                                            .withOpacity(0.3),
                                        width: 1.2,
                                      ),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'Sign Out',
                                        style: TextStyle(
                                          color: Color(0xFFFF6B6B),
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),
                          const AppFooter(),
                          const SizedBox(height: 100),
                        ],
                      ),
                    );
                  }

                  if (state is ProfileError) {
                    return Center(
                      child: Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 32),
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
                                    borderRadius:
                                    BorderRadius.circular(12)),
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
      ),
    );
  }
}