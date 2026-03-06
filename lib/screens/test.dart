import 'package:circlify/circlify.dart';
import 'package:circlify/circlify_item.dart';
import 'package:erp_app/bloc/final_attendance_Bloc/final_attendance_bloc.dart';
import 'package:erp_app/bloc/final_attendance_Bloc/final_attendance_event.dart';
import 'package:erp_app/bloc/final_attendance_Bloc/final_attendance_state.dart';
import 'package:erp_app/models/final_attendance_model.dart';
import 'package:erp_app/repository/final_attendance_repo.dart';
import 'package:erp_app/screens/attendance_list.dart';
import 'package:erp_app/screens/chart.dart';
import 'package:erp_app/screens/pdp.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:erp_app/bloc/auth_bloc/auth_bloc.dart';
import 'package:erp_app/bloc/auth_bloc/auth_state.dart';
import 'package:erp_app/bloc/profile_bloc/profile_bloc.dart';
import 'package:erp_app/bloc/profile_bloc/profile_event.dart';
import 'package:erp_app/bloc/profile_bloc/profile_state.dart';
import 'package:erp_app/drawer/assignment_screen.dart';
import 'package:erp_app/drawer/calendar_screen.dart';
import 'package:erp_app/drawer/eidentity_screen.dart';
import 'package:erp_app/drawer/profile_screen.dart';
import 'package:erp_app/models/login_response.dart';
import 'package:erp_app/models/profile_model.dart';
import 'package:erp_app/repository/profile_repository.dart';
import 'package:erp_app/screens/home_screen.dart';
import 'package:erp_app/screens/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:erp_app/bloc/final_attendance_Bloc/final_attendance_bloc.dart';
import 'package:erp_app/bloc/final_attendance_Bloc/final_attendance_event.dart';
import 'package:erp_app/bloc/final_attendance_Bloc/final_attendance_state.dart';
import 'package:erp_app/screens/dashboard_screen.dart';
import 'package:erp_app/screens/att_calender.dart';
import 'package:erp_app/screens/splashwrapper.dart';
import 'package:lottie/lottie.dart';
//import '../blocs/attendance_bloc.dart';
import '../bloc/TT_bloc/tt_bloc.dart';
import '../models/attendance_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:ui';
import 'package:erp_app/screens/transport_attendance_screen.dart';

import '../repository/transport_attendance_repo.dart';
import 'footer.dart';



class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  List<Map<String, String>> groupByDate(
    List<AttendanceEntry> entries,
    String subjectName,
  ) {
    final formatter = DateFormat('dd MMM yyyy');
    final Map<String, List<String>> dateToStatus = {};

    for (var e in entries.where(
      (e) => e.subjectName == subjectName && e.absentDate != null,
    )) {
      final date = formatter.format(DateTime.parse(e.absentDate!));
      final status = e.isAbsent ? 'A' : 'P';
      dateToStatus.putIfAbsent(date, () => []).add(status);
    }

    return dateToStatus.entries.map((e) {
        return {'date': e.key, 'status': e.value.join()};
      }).toList()
      ..sort(
        (a, b) =>
            formatter.parse(b['date']!).compareTo(formatter.parse(a['date']!)),
      );
  }
  Future<void> _clearAndRedirect(BuildContext context) async {
    const storage = FlutterSecureStorage();
    await storage.deleteAll();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return BlocProvider(
      create:
          (_) =>
              AttendanceBloc(AttendanceRepository())
                ..add(LoadSemestersAndAttendance()),
      child: Scaffold(
        // appBar: AppBar(
        //   title: const Text("Dashboard", style: TextStyle(color: Colors.white)),
        //   backgroundColor: Color(0xFF2C2C2C),
        //   iconTheme: IconThemeData(color: Colors.white),
        //   centerTitle: true,
        // ),
        //backgroundColor: Colors.white,
        drawerScrimColor: Colors.transparent,
        drawer: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            String rollNumber = "";

            if (state is ProfileLoaded) {
              rollNumber = state.profile.rollNumber ?? "";
            }

            return _buildDrawer(context, rollNumber);
          },
        ),
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return Center(
                child: CircularProgressIndicator(color: Color(0xFF2E9E5B)),
              );
            } else if (state is ProfileLoaded) {
              UserProfile profile = state.profile;
              return BlocConsumer<AttendanceBloc, AttendanceState>(
                listener: (context, state) {
                  if (state.errorMessage != null &&
                      state.errorMessage!.contains('Session expired')) {
                    _clearAndRedirect(context);
                  }
                },
                builder: (context, state) {
                  final bloc = context.read<AttendanceBloc>();
                  final grouped = <String, List<AttendanceEntry>>{};

                  for (var entry in state.attendance) {
                    grouped.putIfAbsent(entry.subjectName, () => []).add(entry);
                  }

                  int total = state.attendance.length;
                  int present = state.attendance.where((e) => !e.isAbsent).length;

                  double percentAsDouble = total > 0 ? (present / total * 100) : 0.0;
                  String percent = percentAsDouble.toStringAsFixed(2);

                  int allowedMisses = ((present / 0.75).ceil() - total)
                      .clamp(0, double.infinity)
                      .toInt();

                  int requiredPresents = 0;
                  if (percentAsDouble < 75.0) {
                    requiredPresents = ((0.75 * total - present) / 0.25).ceil();
                  }
                 return Container(
                   decoration: const BoxDecoration(
                     gradient: LinearGradient(
                       begin: Alignment.topLeft,
                       end: Alignment.bottomRight,
                       colors: [ Color(0xFF141840),
                         Color(0xFF020617),
                         Color(0xFF1C1736),],
                       stops: [0.0, 0.5, 1.0],
                     ),
                   ),
                   child: Stack(
                     children: [
                       // Positioned.fill(
                       //   child: Opacity(
                       //     opacity: 0.3,
                       //     child: Lottie.asset(
                       //       'assets/night.json',
                       //       frameRate: FrameRate(30),
                       //       fit: BoxFit.cover,
                       //       repeat: true,
                       //     ),
                       //   ),
                       // ),
                      SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.only(
                            bottom: 16,
                          ), // prevent overflow on bottom
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            children: [
                                              const SizedBox(height: 40),
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  IconButton(
                                                    onPressed: () {
                                                      Scaffold.of(context).openDrawer();
                                                    },
                                                    icon: const Icon(
                                                      Icons.menu,
                                                      color: Color(0xFF1A1A2E),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          'Hello, ${profile.fullName}',
                                                          style: const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.w600,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 2),
                                                        Text(
                                                          profile.collegeEmail,
                                                          style:  TextStyle(
                                                            color: Colors.white.withOpacity(0.5),
                                                            fontSize: 14,
                                                          ),
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 20),
                                                  Theme(
                                                    data: Theme.of(context).copyWith(
                                                      canvasColor: const Color(0xFF1E2235).withOpacity(0.9),
                                                    ),
                                                    child: SizedBox(
                                                      width: 140,
                                                      child: ClipRRect(
                                                        borderRadius: BorderRadius.circular(30),
                                                        child: BackdropFilter(
                                                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                                          child: DropdownButtonFormField<int>(
                                                            value: state.selectedSemesterId,
                                                            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white),
                                                            decoration: InputDecoration(
                                                              border: OutlineInputBorder(
                                                                borderRadius: BorderRadius.circular(30),
                                                                borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
                                                              ),
                                                              enabledBorder: OutlineInputBorder(
                                                                borderRadius: BorderRadius.circular(30),
                                                                borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
                                                              ),
                                                              focusedBorder: OutlineInputBorder(
                                                                borderRadius: BorderRadius.circular(30),
                                                                borderSide: BorderSide(color: Colors.white.withOpacity(0.25)),
                                                              ),
                                                              isDense: true,
                                                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                                              filled: true,
                                                              fillColor: Colors.white.withOpacity(0.08),
                                                            ),
                                                            style: const TextStyle(
                                                              color: Colors.white,
                                                              fontSize: 15,
                                                              fontWeight: FontWeight.w600,
                                                            ),
                                                            items: state.semesters.map((sem) => DropdownMenuItem(
                                                              value: sem.id,
                                                              child: Text(sem.name, style: const TextStyle(color: Colors.white)),
                                                            )).toList(),
                                                            onChanged: (id) => bloc.add(ChangeSemester(id!)),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),


                                    const SizedBox(height: 40),

                                    // Bottom section (no Lottie background)
                                        // Replace the entire overall attendance card with this:

                                        if (!state.isLoading)
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 16),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(20),
                                              child: BackdropFilter(
                                                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(20),
                                                    color: Colors.white.withOpacity(0.05),
                                                    border: Border.all(
                                                      color: Colors.white.withOpacity(0.1),
                                                      width: 1.5,
                                                    ),
                                                  ),
                                                  padding: const EdgeInsets.all(20),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      // Header
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text(
                                                            'ATTENDANCE ANALYTICS',
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              fontWeight: FontWeight.w700,
                                                              color: Colors.white.withOpacity(0.5),
                                                              letterSpacing: 1.2,
                                                            ),
                                                          ),
                                                          Icon(Icons.show_chart_rounded,
                                                              color: Colors.white.withOpacity(0.4), size: 20),
                                                        ],
                                                      ),

                                                      const SizedBox(height: 20),

                                                      // Circle + Grid row
                                                      Row(
                                                        children: [
                                                          // Circle chart
                                                          SizedBox(
                                                            width: 120,
                                                            height: 120,
                                                            child: Stack(
                                                              alignment: Alignment.center,
                                                              children: [
                                                                Circlify(
                                                                  segmentWidth: 10,
                                                                  labelStyle: const TextStyle(fontSize: 0),
                                                                  items: [
                                                                    CirclifyItem(
                                                                      id: '2',
                                                                      color: const Color(0xFF7B6FF0),
                                                                      value: double.parse(percent),
                                                                      label: '',
                                                                    ),
                                                                    CirclifyItem(
                                                                      id: '1',
                                                                      color: Colors.white.withOpacity(0.08),
                                                                      value: 100 - double.parse(percent),
                                                                      label: '',
                                                                    ),
                                                                  ],
                                                                ),
                                                                RichText(
                                                                  text: TextSpan(
                                                                    children: [
                                                                      TextSpan(
                                                                        text: percent,
                                                                        style: const TextStyle(
                                                                          fontSize: 26,
                                                                          fontWeight: FontWeight.w700,
                                                                          color: Colors.white,
                                                                        ),
                                                                      ),
                                                                      const TextSpan(
                                                                        text: '%',
                                                                        style: TextStyle(
                                                                          fontSize: 14,
                                                                          fontWeight: FontWeight.w400,
                                                                          color: Colors.white,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),

                                                          const SizedBox(width: 16),

                                                          // Stats grid
                                                          Expanded(
                                                            child: Column(
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    _statBox(
                                                                      '$present',
                                                                      'PRESENT',
                                                                      const Color(0xFF2E9E5B),
                                                                      const Color(0xFF1A2E22),
                                                                    ),
                                                                    const SizedBox(width: 10),
                                                                    _statBox(
                                                                      '${total - present}',
                                                                      'ABSENT',
                                                                      const Color(0xFFE53935),
                                                                      const Color(0xFF2E1A1A),
                                                                    ),
                                                                  ],
                                                                ),
                                                                const SizedBox(height: 10),
                                                                Row(
                                                                  children: [
                                                                    _statBox(
                                                                      '$total',
                                                                      'TOTAL',
                                                                      Colors.white,
                                                                      Colors.white.withOpacity(0.06),
                                                                    ),
                                                                    const SizedBox(width: 10),
                                                                    _statBox(
                                                                      percentAsDouble >= 75 ? '$allowedMisses' : '$requiredPresents',
                                                                      percentAsDouble >= 75 ? 'MISS UP TO' : 'NEED TO ATTEND',
                                                                      const Color(0xFF7B6FF0),
                                                                      const Color(0xFF1E1A2E),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),

                                                      const SizedBox(height: 16),

                                                      // Bottom message
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                                        decoration: BoxDecoration(
                                                          color: Colors.white.withOpacity(0.05),
                                                          borderRadius: BorderRadius.circular(12),
                                                          border: Border.all(color: Colors.white.withOpacity(0.08)),
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                              percentAsDouble >= 75
                                                                  ? Icons.verified_outlined
                                                                  : Icons.warning_amber_rounded,
                                                              color: percentAsDouble >= 75
                                                                  ? const Color(0xFF2E9E5B)
                                                                  : const Color(0xFFE53935),
                                                              size: 18,
                                                            ),
                                                            const SizedBox(width: 10),
                                                            Expanded(
                                                              child: Text.rich(
                                                                TextSpan(
                                                                  style: const TextStyle(
                                                                      fontSize: 13, color: Colors.white70),
                                                                  children: percentAsDouble >= 75
                                                                      ? [
                                                                    const TextSpan(
                                                                        text: 'Your attendance is '),
                                                                    TextSpan(
                                                                      text:
                                                                      '${(percentAsDouble - 75).toStringAsFixed(2)}% above',
                                                                      style: const TextStyle(
                                                                          color: Color(0xFF2E9E5B),
                                                                          fontWeight: FontWeight.w600),
                                                                    ),
                                                                    const TextSpan(
                                                                        text: ' the minimum requirement.'),
                                                                  ]
                                                                      : [
                                                                    TextSpan(text: 'Your attendance is '),
                                                                    TextSpan(
                                                                      text: '${(75 - percentAsDouble).toStringAsFixed(2)}% below',
                                                                      style: const TextStyle(
                                                                          color: Color(0xFFE53935),
                                                                          fontWeight: FontWeight.w600),
                                                                    ),
                                                                    const TextSpan(text: ' the minimum requirement.'),
                                                                  ],
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
                                  ],
                                ),


                              const SizedBox(height: 24),
                              // const Padding(
                              //   padding: EdgeInsets.symmetric(
                              //     horizontal: 16.0,
                              //     vertical: 8.0,
                              //   ),
                              //   child: Align(
                              //     alignment: Alignment.centerLeft,
                              //     child: Text(
                              //       "Your Statistics",
                              //       style: TextStyle(
                              //         color: Colors.white,
                              //         fontSize: 24,
                              //         fontWeight: FontWeight.w600,
                              //       ),
                              //     ),
                              //   ),
                              // ),
                              // const SizedBox(height: 1),
                              // Padding(
                              //   padding: const EdgeInsets.symmetric(horizontal: 16),
                              //   child: SingleChildScrollView(
                              //     scrollDirection: Axis.horizontal,
                              //     child: Row(
                              //       children: [
                              //         // Orange Bordered Card
                              //         SizedBox(
                              //           width: 200,
                              //           height: 200,
                              //           child: Card(
                              //             color: Colors.black, // Background color black
                              //             shape: RoundedRectangleBorder(
                              //               borderRadius: BorderRadius.circular(10),
                              //               side: const BorderSide(
                              //                 color: Colors.orange, // Border color
                              //                 width: 2,
                              //               ),
                              //             ),
                              //             child: Padding(
                              //               padding: const EdgeInsets.all(16.0),
                              //               child: Column(
                              //                 mainAxisAlignment: MainAxisAlignment.center,
                              //                 children: [
                              //                   const Spacer(),
                              //                   Image.asset(
                              //                     'assets/org.png',
                              //                     height: 50,
                              //                     width: 50,
                              //                     fit: BoxFit.contain,
                              //                   ),
                              //                   const SizedBox(height: 10),
                              //                   const Text(
                              //                     'Organization',
                              //                     style: TextStyle(
                              //                       color: Colors.orange, // Text color same as border
                              //                       fontWeight: FontWeight.bold,
                              //                       fontSize: 16,
                              //                     ),
                              //                   ),
                              //                   const SizedBox(height: 4),
                              //                   const Text(
                              //                     'AKGEC, Ghaziabad',
                              //                     style: TextStyle(
                              //                       color: Colors.orangeAccent,
                              //                       fontWeight: FontWeight.w500,
                              //                       fontSize: 14,
                              //                     ),
                              //                   ),
                              //                   const Spacer(),
                              //                 ],
                              //               ),
                              //             ),
                              //           ),
                              //         ),
                              //         const SizedBox(width: 16),
                              //
                              //         // Blue Bordered Card
                              //         SizedBox(
                              //           width: 200,
                              //           height: 200,
                              //           child: Card(
                              //             color: Colors.black,
                              //             shape: RoundedRectangleBorder(
                              //               borderRadius: BorderRadius.circular(10),
                              //               side: const BorderSide(
                              //                 color: Colors.blue,
                              //                 width: 2,
                              //               ),
                              //             ),
                              //             child: Padding(
                              //               padding: const EdgeInsets.all(16.0),
                              //               child: Column(
                              //                 mainAxisAlignment: MainAxisAlignment.center,
                              //                 children: [
                              //                   const Spacer(),
                              //                   ClipOval(
                              //                     child: Image.asset(
                              //                       'assets/course1.jpg',
                              //                       height: 50,
                              //                       width: 50,
                              //                       fit: BoxFit.cover,
                              //                     ),
                              //                   ),
                              //                   const SizedBox(height: 10),
                              //                   const Text(
                              //                     'Course',
                              //                     style: TextStyle(
                              //                       color: Colors.blue,
                              //                       fontWeight: FontWeight.bold,
                              //                       fontSize: 16,
                              //                     ),
                              //                   ),
                              //                   const SizedBox(height: 4),
                              //                   const Text(
                              //                     'B.Tech.',
                              //                     style: TextStyle(
                              //                       color: Colors.lightBlueAccent,
                              //                       fontWeight: FontWeight.w500,
                              //                       fontSize: 14,
                              //                     ),
                              //                   ),
                              //                   const Spacer(),
                              //                 ],
                              //               ),
                              //             ),
                              //           ),
                              //         ),
                              //         const SizedBox(width: 16),
                              //
                              //         // Green Bordered Card
                              //         SizedBox(
                              //             width: 200,
                              //             height: 200,
                              //             child: Card(
                              //               color: Colors.black,
                              //               shape: RoundedRectangleBorder(
                              //                 borderRadius: BorderRadius.circular(10),
                              //                 side: const BorderSide(
                              //                   color: Colors.green,
                              //                   width: 2,
                              //                 ),
                              //               ),
                              //               child: Padding(
                              //                 padding: const EdgeInsets.all(16.0),
                              //                 child: Column(
                              //                   mainAxisAlignment: MainAxisAlignment.center,
                              //                   children: [
                              //                     const Spacer(),
                              //                     Icon(
                              //                       percentAsDouble >= 75 ? Icons.check_circle : Icons.warning,
                              //                       size: 50,
                              //                       color: percentAsDouble >= 75 ? Colors.green : Colors.red,
                              //                     ),
                              //                     const SizedBox(height: 10),
                              //                     Text(
                              //                       percentAsDouble >= 75 ? 'Above 75% :)' : 'Below 75%',
                              //                       style: TextStyle(
                              //                         color: percentAsDouble >= 75 ? Colors.green : Colors.red,
                              //                         fontWeight: FontWeight.bold,
                              //                         fontSize: 16,
                              //                       ),
                              //                     ),
                              //                     const SizedBox(height: 2),
                              //                     Text(
                              //                       percentAsDouble >= 75
                              //                           ? 'You can miss\n$allowedMisses class${allowedMisses == 1 ? '' : 'es'}'
                              //                           : 'Attend $requiredPresents more class${requiredPresents == 1 ? '' : 'es'} to reach 75%',
                              //                       style: const TextStyle(
                              //                         color: Colors.greenAccent,
                              //                         fontSize: 16,
                              //                         fontWeight: FontWeight.w600,
                              //                       ),
                              //                       textAlign: TextAlign.center,
                              //                     ),
                              //                     const Spacer(),
                              //                   ],
                              //                 ),
                              //               ),
                              //             ),
                              //           )
                              //
                              //       ],
                              //     )
                              //
                              //
                              //   ),
                              // ),
                              //const SizedBox(height: 20),
                               Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 8.0,
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'All Subjects',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'ATTENDANCE OVERVIEW',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.4),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              state.isLoading
                                  ? Center(child: CircularProgressIndicator(color: Color(0xFF2E9E5B)))
                                  : state.errorMessage != null
                                  ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 32),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.wifi_off_rounded, size: 48,
                                          color: const Color(0xFF1A1A2E).withOpacity(0.2)),
                                      const SizedBox(height: 12),
                                      Text(
                                        state.errorMessage!,
                                        style: TextStyle(
                                          color: const Color(0xFF1A1A2E).withOpacity(0.7),
                                          fontSize: 14,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 12),
                                      ElevatedButton(
                                        onPressed: () => context.read<AttendanceBloc>()
                                            .add(LoadSemestersAndAttendance()),
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
                              )
                                  : grouped.isEmpty
                                  ? const Center(child: Text("No subjects found."))
                                  : ListView(
                                    cacheExtent: 500,
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    children:
                                        grouped.entries.map((e) {
                                          final subject = e.key;
                                          final entries = e.value;
                                          final total = entries.length;
                                          final present =
                                              entries
                                                  .where((el) => !el.isAbsent)
                                                  .length;
                                          final percent =
                                              total > 0
                                                  ? (present / total * 100)
                                                      .toStringAsFixed(2)
                                                  : "0.00";

                                          final groupedByDate = groupByDate(
                                            state.attendance,
                                            subject,
                                          );

                                          return SubjectAttendanceTile(
                                                subject: subject,
                                                present: present,
                                                total: total,
                                                percent: percent,
                                                groupedByDate: groupedByDate,
                                              );
                                            }).toList(),/* Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    gradient: const LinearGradient(
                                      colors: [Color.fromARGB(255, 172, 127, 209), Color.fromARGB(255, 192, 178, 196)], // You can customize colors
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.all(2), // Thickness of gradient border
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1E1E1E), // Slightly darker than before for better contrast
                                      borderRadius: BorderRadius.circular(13),
                                    ),
                                    child: Theme(
                                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                      child: ExpansionTile(
                                        title: Text(
                                          subject,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        subtitle: Text(
                                          "Present: $present / $total   ($percent%)",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: double.parse(percent) < 75 ? Colors.red : Colors.green,
                                          ),
                                        ),
                                        children: [
                                          if (groupedByDate.isEmpty)
                                            const ListTile(
                                              title: Text(
                                                "No attendance data.",
                                                style: TextStyle(color: Colors.white),
                                              ),
                                            )
                                          else
                                            ...groupedByDate.map((item) {
                                              final status = item['status']!;
                                              return ListTile(
                                                leading: Icon(
                                                  status.contains('A') ? Icons.cancel : Icons.check_circle,
                                                  color: status.contains('A') ? Colors.red : Colors.green,
                                                ),
                                                title: Text(
                                                  "${item['date']} - $status",
                                                  style: const TextStyle(color: Colors.white),
                                                ),
                                              );
                                            }).toList(),
                                        ],
                                      ),
                                    ),
                                  ),
                                );*/

                                      //  }).toList(),
                                  ),

                              if (!state.isLoading && state.errorMessage == null) const AppFooter(),
                            ],

                          ),
                        ),
                      ),
                     ]
                   ),
                 );
                },
              );
            }

            else if (state is ProfileError) {
              return Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFF5F7FA), Color(0xFFE8EDF5)],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.wifi_off_rounded,
                        size: 64,
                        color: const Color(0xFF1A1A2E).withOpacity(0.2),
                      ),
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
                        onPressed: () => context.read<ProfileBloc>().add(FetchProfile()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E9E5B),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Retry', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              );
            }
            return Center(
              child: CircularProgressIndicator(color: Color(0xFF2E9E5B)),
            );
          },
        ),
      ),
    );
  }
}

Widget _statBox(String value, String label, Color valueColor, Color bgColor) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.4),
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    ),
  );
}

Drawer _buildDrawer(BuildContext context, String rollNumber) {
  return Drawer(
    backgroundColor: Colors.transparent,
    child: ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(24),
        bottomRight: Radius.circular(24),
      ),
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                // border: Border(
                //   bottom: BorderSide(color: Colors.black.withOpacity(0.08)),
                // ),
              ),
              child: const DrawerHeader(
                decoration: BoxDecoration(color: Colors.transparent),
                child: Center(
                  child: Text(
                    'Menu',
                    style: TextStyle(
                      color: Color(0xFF1A1A2E),
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            _drawerItem(context, 'Profile', Icons.person, () async {
              const storage = FlutterSecureStorage();
              final accessToken = await storage.read(key: 'accessToken');
              final sessionId = await storage.read(key: 'sessionId');
              final xUserId = await storage.read(key: 'xUserId');
              final xToken = await storage.read(key: 'xToken');

              final attendanceBloc = context.read<AttendanceBloc>();

              if (accessToken != null) {
                final loginResponse = LoginResponse(
                  accessToken: accessToken,
                  sessionId: sessionId!,
                  xUserId: xUserId!,
                  xToken: xToken!,
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) => ProfileBloc(
                        profileRepository: ProfileRepository(),
                        loginResponse: loginResponse,
                      )..add(FetchProfile()),
                      child: ProfileScreen(
                        attendanceBloc: attendanceBloc,
                      ),
                    ),
                  ),
                );
              }
            }),
            _drawerItem(context, 'Assignment', Icons.assignment, () async{
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AssignmentScreen()));
            }),
            _drawerItem(context, 'E-Identity', Icons.badge, () async{
              Navigator.push(context, MaterialPageRoute(builder: (_) => const EIdentityScreen()));
            }),
            // _drawerItem(context, 'PDP', Icons.badge, () async{
            //   Navigator.push(context, MaterialPageRoute(builder: (_) => const Pdp()));
            // }),

            _drawerItem(
              context,
              'Technical Training',
              Icons.computer_outlined,
                  () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) => TransportAttendanceBloc(
                        TransportAttendanceRepo(const FlutterSecureStorage()),
                      ),
                      child: MandatoryAttendanceScreen(
                        admissionNumber: rollNumber,
                      ),
                    ),
                  ),
                );
              },
            ),


            //const SizedBox(height: 400),
            _drawerItem(context, 'Sign Out', Icons.logout, () async {
              final storage = FlutterSecureStorage();
              await storage.deleteAll();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (Route<dynamic> route) => false,
              );
            }, color: const Color(0xFFE53935)
            ),
          ],
        ),
      ),
    ),
  );
}

ListTile _drawerItem(
    BuildContext context,
    String title,
    IconData icon,
    AsyncCallback onTap, {
      Color? color
    }
    ) {
      final itemColor = color ?? const Color(0xFF1A1A2E);
  return ListTile(
    leading: Icon(icon, color: itemColor.withOpacity(0.7)),
    title: Text(
      title,
      style: TextStyle(
        color: itemColor,
        fontWeight: FontWeight.w500,
        fontSize: 15,
      ),
    ),
    onTap: () {
      Navigator.pop(context);
      onTap();
    },
  );
}
