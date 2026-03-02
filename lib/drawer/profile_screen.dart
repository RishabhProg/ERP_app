import 'package:erp_app/bloc/profile_bloc/profile_state.dart';
import 'package:erp_app/models/profile_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

import '../bloc/profile_bloc/profile_bloc.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  /// ================= INFO ROW =================
  Widget _infoRow(String title, String? value) {
    final displayValue =
    (value == null || value.trim().isEmpty) ? "-" : value;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              displayValue,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  /// ================= SECTION CARD =================
  Widget _sectionCard(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProfileLoaded) {
            final profile = state.profile;

            return Stack(
              children: [
                /// ✅ NIGHT ANIMATION BACKGROUND
                Positioned.fill(
                  child: Lottie.asset(
                    'assets/night.json',
                    fit: BoxFit.cover,
                    repeat: true,
                  ),
                ),

                /// ✅ DARK OVERLAY FOR READABILITY
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.35),
                  ),
                ),

                /// ✅ MAIN CONTENT (BLACK SPACE FIXED)
                SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Column(
                            children: [
                              const SizedBox(height: 20),

                              /// ===== PROFILE HEADER =====
                              Padding(
                                padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  children: [
                                    const CircleAvatar(
                                      radius: 32,
                                      backgroundColor: Colors.white,
                                      child: Icon(
                                        Icons.person,
                                        size: 40,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Hello, ${profile.fullName}",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            profile.collegeEmail,
                                            style: const TextStyle(
                                              color: Colors.white70,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20),

                              /// ===== MY PROFILE =====
                              _sectionCard(
                                "My Profile",
                                [
                                  _infoRow(
                                      "Full Name", profile.fullName),
                                  _infoRow(
                                      "Roll No.", profile.rollNumber),
                                  _infoRow(
                                      "Date of Birth", profile.dob),
                                  _infoRow(
                                      "Email", profile.collegeEmail),
                                  _infoRow(
                                      "Contact", profile.contactNumber),
                                ],
                              ),

                              /// ===== ACADEMIC DETAILS =====
                              _sectionCard(
                                "Academic Details",
                                [
                                  _infoRow(
                                    "Course",
                                    "B.Tech in Computer Science",
                                  ),

                                  // ✅ SAFE — shows "-" if empty
                                  _infoRow(
                                      "Batch", profile.semester),

                                  _infoRow(
                                      "Section", profile.section),
                                ],
                              ),

                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }

          if (state is ProfileError) {
            return const Center(
              child: Text(
                'Error loading profile',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}