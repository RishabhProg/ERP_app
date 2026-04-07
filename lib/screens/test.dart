import 'package:circlify/circlify.dart';
import 'package:circlify/circlify_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../bloc/auth_bloc/auth_bloc.dart';
import '../bloc/profile_bloc/profile_bloc.dart';
import '../bloc/profile_bloc/profile_event.dart';
import '../bloc/profile_bloc/profile_state.dart';
import '../customizer/background_selector_screen.dart';
import '../models/attendance_model.dart';
import '../models/final_attendance_model.dart';
import '../models/profile_model.dart';
import '../bloc/final_attendance_Bloc/final_attendance_bloc.dart';
import '../bloc/final_attendance_Bloc/final_attendance_event.dart';
import '../bloc/final_attendance_Bloc/final_attendance_state.dart';
import '../repository/final_attendance_repo.dart';
import '../screens/home_screen.dart';
import '../widget_launcher.dart';
import 'attendance_list.dart';
import 'footer.dart';

class Test extends StatefulWidget {

  final void Function(int index) onBackgroundSelected;
  const Test({super.key, required this.onBackgroundSelected});

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

    return dateToStatus.entries
        .map((e) => {'date': e.key, 'status': e.value.join()})
        .toList()
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

  // Always-dark background wrapper — prevents white flash during loading
  Widget _bg(Widget child) => Material(
    color: Colors.transparent,
    child: Container(
      width: double.infinity,
      height: double.infinity,
      child: child,
    ),
  );

  @override
  Widget build(BuildContext context) {

       return BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, profileState) {
          if (profileState is ProfileLoading) {
            return _bg(
              const Center(
                child: CircularProgressIndicator(color: Color(0xFF2E9E5B)),
              ),
            );
          }

          if (profileState is ProfileLoaded) {
            final UserProfile profile = profileState.profile;

            return BlocConsumer<AttendanceBloc, AttendanceState>(
              listener: (context, state) {
                if (state.errorMessage != null &&
                    state.errorMessage!.contains('Session expired')) {
                  _clearAndRedirect(context);
                }

                if (!state.isLoading && state.errorMessage == null) {
                  final total = state.attendance.length;
                  final present = state.attendance.where((e) => !e.isAbsent).length;
                  final percentAsDouble = total > 0 ? (present / total * 100) : 0.0;
                  final percent = percentAsDouble.toStringAsFixed(2);

                  HomeWidget.saveWidgetData<String>('percent', percent);
                  HomeWidget.saveWidgetData<int>('present', present);
                  HomeWidget.saveWidgetData<int>('total', total);
                  HomeWidget.updateWidget(
                      name: 'HomeScreenWidgetProvider',
                      androidName: 'HomeScreenWidgetProvider');
                  HomeWidget.updateWidget(
                      name: 'HomeScreenWidgetAltProvider',
                      androidName: 'HomeScreenWidgetAltProvider');
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

                // //homescreen widget
                // HomeWidget.saveWidgetData<String>('percent', percent);
                // HomeWidget.saveWidgetData<int>('present', present);
                // HomeWidget.saveWidgetData<int>('total', total);
                // //widget1
                // HomeWidget.updateWidget(
                //   name: 'HomeScreenWidgetProvider',
                //   androidName: 'HomeScreenWidgetProvider'
                // );
                // //widget2
                // HomeWidget.updateWidget(
                //     name: 'HomeScreenWidgetAltProvider',
                //     androidName: 'HomeScreenWidgetAltProvider'
                // );


                int allowedMisses = ((present / 0.75).floor() - total)
                    .clamp(0, double.infinity)
                    .toInt();

                int requiredPresents = 0;
                if (percentAsDouble < 75.0) {
                  requiredPresents = ((0.75 * total - present) / 0.25).ceil();
                }

                return _bg(
                  RefreshIndicator(
                    color: const Color(0xFF2E9E5B),
                    backgroundColor: const Color(0xFF1E2235),
                    onRefresh: () async {
                      context.read<ProfileBloc>().add(FetchProfile());
                      context.read<AttendanceBloc>().add(LoadSemestersAndAttendance());

                      await context.read<AttendanceBloc>().stream.firstWhere(
                            (s) => !s.isLoading,
                      );
                    },

                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 124),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Header ──
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  const SizedBox(height: 40),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Hello,\n'
                                              '${profile.fullName}',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            // Text(
                                            //   profile.collegeEmail,
                                            //   style: TextStyle(
                                            //     color: Colors.white.withOpacity(0.5),
                                            //     fontSize: 14,
                                            //   ),
                                            //   overflow: TextOverflow.ellipsis,
                                            // ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                    
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(30),
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => BackgroundSelectorScreen(
                                                    onSelected: widget.onBackgroundSelected,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              width: 44,
                                              height: 44,
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.08),
                                                shape: BoxShape.circle,
                                                border: Border.all(color: Colors.white.withOpacity(0.15)),
                                              ),
                                              child: const Icon(
                                                Icons.auto_awesome_outlined,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                    
                                      const SizedBox(width: 10),
                    
                                      Theme(
                                        data: Theme.of(context).copyWith(
                                          canvasColor: const Color(0xFF1E2235).withOpacity(0.9),
                                        ),
                                        child: SizedBox(
                                          width: 105,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(30),
                                            child: BackdropFilter(
                                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                              child: DropdownButtonFormField<int>(
                                                value: state.selectedSemesterId,
                                                icon: const Icon(
                                                    Icons.keyboard_arrow_down_rounded,
                                                    color: Colors.white),
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(30),
                                                    borderSide: BorderSide(
                                                        color: Colors.white.withOpacity(0.15)),
                                                  ),
                                                  enabledBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(30),
                                                    borderSide: BorderSide(
                                                        color: Colors.white.withOpacity(0.15)),
                                                  ),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(30),
                                                    borderSide: BorderSide(
                                                        color: Colors.white.withOpacity(0.25)),
                                                  ),
                                                  isDense: true,
                                                  contentPadding: const EdgeInsets.symmetric(
                                                      horizontal: 16, vertical: 12),
                                                  filled: true,
                                                  fillColor: Colors.white.withOpacity(0.08),
                                                ),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                items: state.semesters
                                                    .map((sem) => DropdownMenuItem(
                                                  value: sem.id,
                                                  child: Text(
                                                    sem.name.replaceFirst('Semester', 'Sem'),
                                                    style: const TextStyle(color: Colors.white),
                                                  ),
                                                ))
                                                    .toList(),
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
                    
                            // ── Attendance analytics card ──
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
                                          Row(
                                            children: [
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
                                                              fontSize: 22,
                                                              fontWeight: FontWeight.w700,
                                                              color: Colors.white,
                                                            ),
                                                          ),
                                                          const TextSpan(
                                                            text: '%',
                                                            style: TextStyle(
                                                              fontSize: 12,
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
                                              Expanded(
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        _statBox('$present', 'PRESENT',
                                                            const Color(0xFF2E9E5B),
                                                            const Color(0xFF1A2E22)),
                                                        const SizedBox(width: 10),
                                                        _statBox('${total - present}', 'ABSENT',
                                                            const Color(0xFFE53935),
                                                            const Color(0xFF2E1A1A)),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Row(
                                                      children: [
                                                        _statBox('$total', 'TOTAL', Colors.white,
                                                            Colors.white.withOpacity(0.06)),
                                                        const SizedBox(width: 10),
                                                        _statBox(
                                                          percentAsDouble >= 75
                                                              ? '$allowedMisses'
                                                              : '$requiredPresents',
                                                          percentAsDouble >= 75
                                                              ? 'MISS UP TO'
                                                              : 'NEED TO ATTEND',
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
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 14, vertical: 10),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.05),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                  color: Colors.white.withOpacity(0.08)),
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
                                                        const TextSpan(
                                                            text: 'Your attendance is '),
                                                        TextSpan(
                                                          text:
                                                          '${(75 - percentAsDouble).toStringAsFixed(2)}% below',
                                                          style: const TextStyle(
                                                              color: Color(0xFFE53935),
                                                              fontWeight: FontWeight.w600),
                                                        ),
                                                        const TextSpan(
                                                            text: ' the minimum requirement.'),
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
                    
                            const SizedBox(height: 24),
                    
                            // ── All Subjects header ──
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
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
                    
                            // ── Subject list ──
                            state.isLoading
                                ? const Center(
                                child: CircularProgressIndicator(
                                    color: Color(0xFF2E9E5B)))
                                : state.errorMessage != null
                                ? Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32),
                                child: Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.wifi_off_rounded,
                                        size: 48,
                                        color:
                                        Colors.white.withOpacity(0.2)),
                                    const SizedBox(height: 12),
                                    Text(
                                      state.errorMessage!,
                                      style: TextStyle(
                                          color:
                                          Colors.white.withOpacity(0.7),
                                          fontSize: 14),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 12),
                                    ElevatedButton(
                                      onPressed: () {
                                        context.read<ProfileBloc>().add(FetchProfile());
                                        context.read<AttendanceBloc>().add(LoadSemestersAndAttendance());
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                        const Color(0xFF2E9E5B),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(12)),
                                      ),
                                      child: const Text('Retry',
                                          style: TextStyle(
                                              color: Colors.white)),
                                    ),
                                  ],
                                ),
                              ),
                            )
                                : grouped.isEmpty
                                ? const Center(
                                child: Text("No subjects found.",
                                    style: TextStyle(
                                        color: Colors.white54)))
                                : ListView(
                              cacheExtent: 500,
                              shrinkWrap: true,
                              physics:
                              const NeverScrollableScrollPhysics(),
                              children: grouped.entries.map((e) {
                                final subject = e.key;
                                final entries = e.value;
                                final total = entries.length;
                                final present = entries
                                    .where((el) => !el.isAbsent)
                                    .length;
                                final percent = total > 0
                                    ? (present / total * 100)
                                    .toStringAsFixed(2)
                                    : "0.00";
                                final groupedByDate =
                                groupByDate(state.attendance, subject);
                                return SubjectAttendanceTile(
                                  subject: subject,
                                  present: present,
                                  total: total,
                                  percent: percent,
                                  groupedByDate: groupedByDate,
                                );
                              }).toList(),
                            ),
                    
                            if (!state.isLoading && state.errorMessage == null) ...[
                              const AppFooter(),
                              //const SizedBox(height: 5),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }

          if (profileState is ProfileError) {
            return _bg(
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wifi_off_rounded,
                        size: 64, color: Colors.white.withOpacity(0.2)),
                    const SizedBox(height: 16),
                    Text(
                      profileState.error,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.7), fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ProfileBloc>().add(FetchProfile());
                        context.read<AttendanceBloc>().add(LoadSemestersAndAttendance());
                      },
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

          // Default loading
          return _bg(
            const Center(
              child: CircularProgressIndicator(color: Color(0xFF2E9E5B)),
            ),
          );
        },
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