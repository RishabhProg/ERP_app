import 'dart:ui';
import 'package:erp_app/bloc/profile_bloc/profile_state.dart';
import 'package:erp_app/models/profile_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import '../bloc/final_attendance_Bloc/final_attendance_bloc.dart';
import '../bloc/final_attendance_Bloc/final_attendance_state.dart';
import '../bloc/profile_bloc/profile_bloc.dart';
import '../bloc/profile_bloc/profile_event.dart';

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
                color: const Color(0xFF1A1A2E).withOpacity(0.5),
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              displayValue,
              style: const TextStyle(
                color: Color(0xFF1A1A2E),
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
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withOpacity(0.85),
          border: Border.all(
            color: Colors.white.withOpacity(0.7),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 4),
            Divider(color: Colors.black.withOpacity(0.08)),
            const SizedBox(height: 4),
            ...children,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: Stack(
        children: [
          // Lottie background
          Positioned.fill(
            child: Opacity(
              opacity: 0.3,
              child: Lottie.asset(
                'assets/night.json',
                frameRate: FrameRate(30),
                fit: BoxFit.cover,
                repeat: true,
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
                        // Header with back button
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.arrow_back_ios_new,
                                  color: Color(0xFF1A1A2E),
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
                                  color: Color(0xFF1A1A2E),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Avatar + name card
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: Colors.white.withOpacity(0.5),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.7),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 16,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 64,
                                      height: 64,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0xFF2E9E5B).withOpacity(0.1),
                                        border: Border.all(
                                          color: const Color(0xFF2E9E5B).withOpacity(0.3),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.person,
                                        size: 36,
                                        color: const Color(0xFF2E9E5B).withOpacity(0.7),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            profile.fullName,
                                            style: const TextStyle(
                                              color: Color(0xFF1A1A2E),
                                              fontSize: 17,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            profile.collegeEmail,
                                            style: TextStyle(
                                              color: const Color(0xFF1A1A2E).withOpacity(0.5),
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
                                  child: CircularProgressIndicator(color: Color(0xFF2E9E5B)),
                                ),
                              );
                            }

                            final courseName = attendanceState.semesters.isNotEmpty
                                ? attendanceState.semesters.first.courseName
                                : '-';
                            final batchName = attendanceState.semesters.isNotEmpty
                                ? attendanceState.semesters.first.batchName
                                : '-';
                            final currentSemester = attendanceState.selectedSemesterId.toString() ?? '-';

                            return _sectionCard("Academic Details", [
                              _infoRow("Course", courseName),
                              _infoRow("Batch", batchName),
                              _infoRow("Semester", 'Semester $currentSemester'),
                              //_infoRow("Section", profile.section),
                            ]);
                          },
                        ),

                        _sectionCard("Family Details", [
                          _infoRow("Father's Name", profile.fatherName),
                          _infoRow("Mother's Name", profile.motherName),
                          _infoRow("Parent Contact", profile.parentMobileNumber),
                          _infoRow("Address", profile.address),
                        ]),

                        const SizedBox(height: 30),
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
                          Icon(Icons.wifi_off_rounded, size: 64,
                              color: const Color(0xFF1A1A2E).withOpacity(0.2)),
                          const SizedBox(height: 16),
                          Text(
                            state.error,
                            style: TextStyle(
                              color: const Color(0xFF1A1A2E).withOpacity(0.7),
                              fontSize: 15,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () =>
                                context.read<ProfileBloc>().add(FetchProfile()),
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