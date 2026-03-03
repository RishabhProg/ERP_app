import 'package:erp_app/bloc/profile_bloc/profile_bloc.dart';
import 'package:erp_app/bloc/profile_bloc/profile_state.dart';
import 'package:erp_app/models/profile_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Widget _buildProfileItem(String label, String value) {
    return Card(
      color: Color(0xFF2C2C2C), // Green card background
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 15,
      child: ListTile(
        title: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white, // White text
          ),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(color: Colors.green), // White text
        ),
        leading: const Icon(Icons.person, color: Colors.white), // White icon
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Whole screen background black
      appBar: AppBar(
        backgroundColor: Color(0xFF2C2C2C),
        centerTitle: true,
        title: const Text(
          "Student Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF2E9E5B)));
          } else if (state is ProfileLoaded) {
            UserProfile profile = state.profile;
            return SingleChildScrollView(
              child: Column(
                children: [
                  // Curved Header
                  ClipPath(
                    clipper: CurvedHeaderClipper(),
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(
                        minHeight: 280,
                        maxHeight: 350,
                      ),

                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Lottie.asset(
                            'assets/back1.json',
                            fit: BoxFit.cover,
                            repeat: true,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 20,
                            ),
                            color: Colors.black.withOpacity(0.3),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 130,
                                  width: 130,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.black,
                                          shape: BoxShape.circle,
                                        ),
                                        child: CircleAvatar(
                                          radius: 50,
                                          backgroundColor: Colors.green,
                                          child: const Icon(
                                            Icons.account_circle,
                                            size: 80,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  profile.fullName,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  profile.collegeEmail,
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    color: Colors.black,
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        _buildProfileItem("Roll Number", profile.rollNumber),
                        _buildProfileItem("Semester", profile.semester),
                        _buildProfileItem("Section", profile.section),
                        _buildProfileItem("DOB", profile.dob),
                        _buildProfileItem(
                          "Contact Number",
                          profile.contactNumber,
                        ),
                        _buildProfileItem("Address", profile.address),
                        _buildProfileItem("Father's Name", profile.fatherName),
                        _buildProfileItem("Mother's Name", profile.motherName),
                        _buildProfileItem(
                          "Parent Mobile",
                          profile.parentMobileNumber,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else if (state is ProfileError) {
            return const Center(
              child: Text(
                'Error loading profile',
                style: TextStyle(color: Colors.white),
              ),
            );
          }
          return const Center(
            child: Text(
              "Press a button to load profile",
              style: TextStyle(color: Colors.white),
            ),
          );
        },
      ),
    );
  }
}

class CurvedHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 40,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
