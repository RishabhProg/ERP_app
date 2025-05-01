// import 'package:erp_app/bloc/auth_bloc/auth_bloc.dart';
// import 'package:erp_app/bloc/auth_bloc/auth_state.dart';
// import 'package:erp_app/bloc/profile_bloc/profile_bloc.dart';
// import 'package:erp_app/bloc/profile_bloc/profile_event.dart';
// import 'package:erp_app/bloc/profile_bloc/profile_state.dart';
// import 'package:erp_app/drawer/assignment_screen.dart';
// import 'package:erp_app/drawer/calendar_screen.dart';
// import 'package:erp_app/drawer/eidentity_screen.dart';
// import 'package:erp_app/drawer/profile_screen.dart';
// import 'package:erp_app/models/login_response.dart';
// import 'package:erp_app/models/profile_model.dart'; // Import the Profile model
// import 'package:erp_app/repository/profile_repository.dart';
// import 'package:erp_app/screens/home_screen.dart';
// import 'package:erp_app/screens/test.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:erp_app/bloc/final_attendance_Bloc/final_attendance_bloc.dart';
// import 'package:erp_app/bloc/final_attendance_Bloc/final_attendance_event.dart';
// import 'package:erp_app/bloc/final_attendance_Bloc/final_attendance_state.dart';
// import 'package:fl_chart/fl_chart.dart';

// class DashboardScreen extends StatefulWidget {
//   const DashboardScreen({super.key});

//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends State<DashboardScreen> {
//   @override
//   void initState() {
//     super.initState();
//     // Dispatch event to load attendance data when DashboardScreen is loaded
//     context.read<AttendanceBloc>().add(LoadSemestersAndAttendance());
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         centerTitle: true,
//         iconTheme: const IconThemeData(color: Colors.white),
//         title: const Text(
//           'Dashboard',
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//       ),
//       drawer: _buildDrawer(context),
//       body: BlocBuilder<ProfileBloc, ProfileState>(
//         builder: (context, state) {
//           if (state is ProfileLoading) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (state is ProfileLoaded) {
//             // Extract profile data from the loaded state
//             UserProfile profile = state.profile;

//             return SingleChildScrollView(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Display name
//                   Text(
//                     'Hello, ${profile.fullName}',
//                     style: const TextStyle(
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                   const SizedBox(height: 6),
//                   // Display email
//                   Text(
//                     profile.collegeEmail,
//                     style: const TextStyle(color: Colors.white70),
//                   ),
//                   const SizedBox(height: 24),

//                   // Attendance Graph
//                   BlocBuilder<AttendanceBloc, AttendanceState>(
//                     builder: (context, attendanceState) {
//                       if (attendanceState.isLoading) {
//                         return const Center(child: CircularProgressIndicator());
//                       } else if (attendanceState.attendance != null) {
//                         int totalPresent = 0;
//                         int totalAbsent = 0;

//                         // Calculate total present and absent
//                         for (var entry in attendanceState.attendance!) {
//                           if (entry.isAbsent) {
//                             totalAbsent++;
//                           } else {
//                             totalPresent++;
//                           }
//                         }

//                         // Create a pie chart for total present and absent
//                         return Column(
//                           children: [
//                             const SizedBox(height: 20),
//                             Text(
//                               "Overall Attendance",
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             const SizedBox(height: 10),
//                             SizedBox(
//                               height: 200,
//                               child: PieChart(
//                                 PieChartData(
//                                   sectionsSpace: 4,
//                                   centerSpaceRadius: 40,
//                                   startDegreeOffset:
//                                       -90, // Optional: makes the chart start from top
//                                   sections: [
//                                     PieChartSectionData(
//                                       value: totalPresent.toDouble(),
//                                       title: 'Present\n$totalPresent',
//                                       color: Colors.green,
//                                       radius: 60,
//                                       titleStyle: const TextStyle(
//                                         fontSize: 14,
//                                         fontWeight: FontWeight.bold,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                                     PieChartSectionData(
//                                       value: totalAbsent.toDouble(),
//                                       title: 'Absent\n$totalAbsent',
//                                       color: Colors.red,
//                                       radius: 60,
//                                       titleStyle: const TextStyle(
//                                         fontSize: 14,
//                                         fontWeight: FontWeight.bold,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 swapAnimationDuration: const Duration(
//                                   milliseconds: 1000,
//                                 ), // Animation duration
//                                 swapAnimationCurve:
//                                     Curves.easeInOut, // Animation curve
//                               ),
//                             ),

//                             const SizedBox(height: 20),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                               children: [
//                                 _buildInfoCard(
//                                   "Total Present",
//                                   "$totalPresent",
//                                   Colors.green,
//                                 ),
//                                 _buildInfoCard(
//                                   "Total Absent",
//                                   "$totalAbsent",
//                                   Colors.red,
//                                 ),
//                               ],
//                             ),
//                           ],
//                         );
//                       } else {
//                         return const Center(
//                           child: Text(
//                             "No attendance data available",
//                             style: TextStyle(color: Colors.white),
//                           ),
//                         );
//                       }
//                     },
//                   ),

//                   // Attendance data below graph
//                   const Center(
//                     child: Text(
//                       "Attendance data will go here",
//                       style: TextStyle(color: Colors.white),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           } else {
//             return const Center(
//               child: Text(
//                 "Failed to load profile",
//                 style: TextStyle(color: Colors.white),
//               ),
//             );
//           }
//         },
//       ),
//     );
//   }

//   Widget _buildInfoCard(String label, String value, Color color) {
//     return Container(
//       width: 150,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [color.withOpacity(0.8), color.withOpacity(0.4)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: color.withOpacity(0.4),
//             blurRadius: 8,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Text(
//             label,
//             textAlign: TextAlign.center,
//             style: const TextStyle(
//               color: Colors.white70,
//               fontSize: 14,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             value,
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Drawer _buildDrawer(BuildContext context) {
//     return Drawer(
//       child: ListView(
//         padding: EdgeInsets.zero,
//         children: [
//           const DrawerHeader(
//             decoration: BoxDecoration(color: Colors.purple),
//             child: Text(
//               'Menu',
//               style: TextStyle(color: Colors.white, fontSize: 24),
//             ),
//           ),
//           _drawerItem('Dashboard', Icons.dashboard, () {
//             final authState = BlocProvider.of<AuthBloc>(context).state;
//             if (authState is AuthSuccess) {
//               final loginResponse = LoginResponse(
//                 accessToken: authState.accessToken,
//                 sessionId: authState.sessionId,
//                 xUserId: authState.xUserId,
//                 xToken: authState.xToken,
//               );

//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(
//                   builder:
//                       (_) => BlocProvider(
//                         create:
//                             (_) => ProfileBloc(
//                               profileRepository: ProfileRepository(),
//                               loginResponse: loginResponse,
//                             )..add(FetchProfile()),
//                         child: const DashboardScreen(),
//                       ),
//                 ),
//               );
//             }
//           }),
//           _drawerItem('Profile', Icons.person, () {
//             final authState = BlocProvider.of<AuthBloc>(context).state;

//             if (authState is AuthSuccess) {
//               final loginResponse = LoginResponse(
//                 accessToken: authState.accessToken,
//                 sessionId: authState.sessionId,
//                 xUserId: authState.xUserId,
//                 xToken: authState.xToken,
//               );

//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder:
//                       (_) => BlocProvider(
//                         create:
//                             (_) => ProfileBloc(
//                               profileRepository: ProfileRepository(),
//                               loginResponse: loginResponse,
//                             )..add(FetchProfile()),
//                         child: const ProfileScreen(),
//                       ),
//                 ),
//               );
//             }
//           }),
//           _drawerItem('Assignment', Icons.assignment, () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => const AssignmentScreen()),
//             );
//           }),
//           _drawerItem('Attendance', Icons.assignment, () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => const Test()),
//             );
//           }),
//           _drawerItem('E-Identity', Icons.badge, () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => const EIdentityScreen()),
//             );
//           }),
//           _drawerItem('Calendar', Icons.calendar_month, () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => const CalendarScreen()),
//             );
//           }),
//           _drawerItem('Sign Out', Icons.logout, () async {
//             final storage = FlutterSecureStorage();

//             // Delete the stored session and authentication data
//             await storage.delete(key: 'accessToken');
//             await storage.delete(key: 'sessionId');
//             await storage.delete(key: 'xUserId');
//             await storage.delete(key: 'xToken');
//             Navigator.pushAndRemoveUntil(
//               context,
//               MaterialPageRoute(builder: (_) => const HomeScreen()),
//               (Route<dynamic> route) => false,
//             );
//           }),
//         ],
//       ),
//     );
//   }

//   ListTile _drawerItem(String title, IconData icon, VoidCallback onTap) {
//     return ListTile(
//       leading: Icon(icon, color: Colors.purple),
//       title: Text(title),
//       onTap: () {
//         Navigator.pop(context); // Close the drawer
//         onTap();
//       },
//     );
//   }
// }
