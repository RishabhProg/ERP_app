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
import '../models/attendance_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:ui';



class Test extends StatelessWidget {
  const Test({super.key});

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
        drawer: _buildDrawer(context),
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ProfileLoaded) {
              UserProfile profile = state.profile;
              return BlocBuilder<AttendanceBloc, AttendanceState>(
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
                       colors: [Color(0xFFF5F7FA), Color(0xFFE8EDF5)],
                     ),
                   ),
                   child: Stack(
                     children: [
                       Positioned.fill(
                         child: Opacity(
                           opacity: 0.3,
                           child: Lottie.asset(
                             'assets/night.json',
                             fit: BoxFit.cover,
                             repeat: true,
                           ),
                         ),
                       ),
                      SingleChildScrollView(
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
                                                            color: Color(0xFF1A1A2E),
                                                          ),
                                                        ),
                                                        const SizedBox(height: 2),
                                                        Text(
                                                          profile.collegeEmail,
                                                          style: const TextStyle(
                                                            color: Color(0xFF555770),
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
                                                      canvasColor: Colors.white,
                                                    ),
                                                    child: SizedBox(
                                                      width: 140,
                                                      child: DropdownButtonFormField<int>(
                                                        value: state.selectedSemesterId,
                                                        decoration: InputDecoration(
                                                          border: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(8),
                                                            borderSide: BorderSide(color: Colors.black.withOpacity(0.15)),
                                                          ),
                                                          enabledBorder: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(8),
                                                            borderSide: BorderSide(color: Colors.black.withOpacity(0.15)),
                                                          ),
                                                          focusedBorder: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(8),
                                                            borderSide: BorderSide(color: Colors.black.withOpacity(0.15)),
                                                          ),
                                                          isDense: true,
                                                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                                          filled: true,
                                                          fillColor: Colors.white.withOpacity(0.6),
                                                        ),
                                                        style: const TextStyle(color: Color(0xFF1A1A2E)),
                                                        items: state.semesters.map((sem) => DropdownMenuItem(
                                                          value: sem.id,
                                                          child: Text(sem.name, style: const TextStyle(color: Color(0xFF1A1A2E))),
                                                        )).toList(),
                                                        onChanged: (id) => bloc.add(ChangeSemester(id!)),
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
                                    if (!state.isLoading)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(18),
                                          child: BackdropFilter(
                                            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(18),
                                                color: Colors.white.withOpacity(0.25),
                                                border: Border.all(
                                                  color: Colors.white.withOpacity(0.5),
                                                  width: 1.5,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.white.withOpacity(0.1),
                                                    blurRadius: 20,
                                                    spreadRadius: 2,
                                                  ),
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(0.08),
                                                    blurRadius: 30,
                                                    offset: const Offset(0, 8),
                                                  ),
                                                ],
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(16),
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      flex: 2,
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          const Text(
                                                            "Overall Attendance",
                                                            style: TextStyle(
                                                              fontSize: 22,
                                                              fontWeight: FontWeight.bold,
                                                              color: Color(0xFF1A1A2E),
                                                            ),
                                                          ),
                                                          const SizedBox(height: 8),
                                                          Text(
                                                            "Total Classes: $total",
                                                            style: TextStyle(
                                                              color: Colors.black.withOpacity(0.6),
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                          Text(
                                                            "Total Presents: $present",
                                                            style: TextStyle(
                                                              color: Colors.black.withOpacity(0.6),
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                          Text(
                                                            "Overall Percentage: $percent%",
                                                            style: TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                              color: double.parse(percent) < 75
                                                                  ? const Color(0xFFE53935)
                                                                  : const Color(0xFF2E7D32),
                                                            ),
                                                          ),
                                                          const SizedBox(height: 6),
                                                          Text(
                                                            percentAsDouble >= 75
                                                                ? 'You can miss $allowedMisses more class${allowedMisses == 1 ? '' : 'es'}'
                                                                : 'Attend $requiredPresents more class${requiredPresents == 1 ? '' : 'es'} to reach 75%',
                                                            style: TextStyle(
                                                              fontSize: 13,
                                                              fontWeight: FontWeight.w500,
                                                              color: percentAsDouble >= 75
                                                                  ? const Color(0xFF2E9E5B)
                                                                  : const Color(0xFFE53935),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(width: 16),
                                                    SizedBox(
                                                      width: 120,
                                                      height: 120,
                                                      child: Stack(
                                                        alignment: Alignment.center,
                                                        children: [
                                                        Circlify(
                                                        segmentWidth: 10,
                                                        labelStyle: const TextStyle(
                                                          color: Color(0xFF1A1A2E),
                                                          fontSize: 20,
                                                          fontWeight: FontWeight.w700,
                                                        ),
                                                        items: [
                                                          CirclifyItem(
                                                            id: '2',
                                                            color: const Color(0xFF2E7D32),
                                                            value: (present / total) * 100,
                                                            label: '',
                                                          ),
                                                          CirclifyItem(
                                                            id: '1',
                                                            color: const Color(0xFFE53935),
                                                            value: 100 - ((present / total) * 100),
                                                            label: '',
                                                          ),
                                                        ],
                                                      ),
                                                          RichText(
                                                            text: TextSpan(
                                                              children: [
                                                                TextSpan(
                                                                  text: "${((present / total) * 100).toStringAsFixed(0)}",
                                                                  style: const TextStyle(
                                                                    fontSize: 25,
                                                                    fontWeight: FontWeight.w300,
                                                                    color: Color(0xFF1A1A2E),
                                                                  ),
                                                                ),
                                                                TextSpan(
                                                                  text: ".${((present / total) * 100).toStringAsFixed(2).split('.')[1]}%",
                                                                  style: const TextStyle(
                                                                    fontSize: 15,
                                                                    fontWeight: FontWeight.w300,
                                                                    color: Color(0xFF1A1A2E),
                                                                  ),
                                                                ),
                                                              ],
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
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 8.0,
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "All Subjects",
                                      style: const TextStyle(
                                        color: Color(0xFF1A1A2E),
                                        fontSize: 24,
                                        fontWeight: FontWeight.w600,
                                      )
                                  ),
                                ),
                              ),

                              state.isLoading
                                  ? const Center(child: CircularProgressIndicator())
                                  : grouped.isEmpty
                                  ? const Center(child: Text("No subjects found."))
                                  : ListView(
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
            else if(state is ProfileError){
              return Center(
                child: Text(
                  "Failed to load profile",
                  style: TextStyle(color: Colors.white),
                ),
              );
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}

Drawer _buildDrawer(BuildContext context) {
  return Drawer(
    backgroundColor: Colors.transparent,
    child: ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(24),
        bottomRight: Radius.circular(24),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          color: Colors.white.withOpacity(0.15),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  border: Border(
                    bottom: BorderSide(color: Colors.white.withOpacity(0.2)),
                  ),
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

              _drawerItem(context, 'Profile', Icons.person, () {
                final authState = BlocProvider.of<AuthBloc>(context).state;
                if (authState is AuthSuccess) {
                  final loginResponse = LoginResponse(
                    accessToken: authState.accessToken,
                    sessionId: authState.sessionId,
                    xUserId: authState.xUserId,
                    xToken: authState.xToken,
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (_) => ProfileBloc(
                          profileRepository: ProfileRepository(),
                          loginResponse: loginResponse,
                        )..add(FetchProfile()),
                        child: const ProfileScreen(),
                      ),
                    ),
                  );
                }
              }),
              _drawerItem(context, 'Assignment', Icons.assignment, () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AssignmentScreen()));
              }),
              _drawerItem(context, 'E-Identity', Icons.badge, () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const EIdentityScreen()));
              }),
              _drawerItem(context, 'PDP', Icons.badge, () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const Pdp()));
              }),
              _drawerItem(context, 'Sign Out', Icons.logout, () async {
                final storage = FlutterSecureStorage();
                await storage.delete(key: 'accessToken');
                await storage.delete(key: 'sessionId');
                await storage.delete(key: 'xUserId');
                await storage.delete(key: 'xToken');
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                      (Route<dynamic> route) => false,
                );
              }),
            ],
          ),
        ),
      ),
    ),
  );
}

ListTile _drawerItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
    ) {
  return ListTile(
    leading: Icon(icon, color: const Color(0xFF1A1A2E).withOpacity(0.7)),
    title: Text(
      title,
      style: TextStyle(
        color: const Color(0xFF1A1A2E),
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
