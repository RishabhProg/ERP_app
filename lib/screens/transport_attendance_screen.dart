import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../bloc/TT_bloc/tt_bloc.dart';
import '../bloc/TT_bloc/tt_event.dart';
import '../bloc/TT_bloc/tt_state.dart';
import '../models/transport_attendance_model.dart';
import 'footer.dart';

class MandatoryAttendanceScreen extends StatefulWidget {
  final String admissionNumber;

  const MandatoryAttendanceScreen({
    super.key,
    required this.admissionNumber,
  });

  @override
  State<MandatoryAttendanceScreen> createState() =>
      _MandatoryAttendanceScreenState();
}

class _MandatoryAttendanceScreenState
    extends State<MandatoryAttendanceScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<TransportAttendanceBloc>().add(FetchTransportAttendance());
    });
  }

  Future<void> _onRefresh() async {
    context.read<TransportAttendanceBloc>().add(FetchTransportAttendance());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: Stack(
        children: [
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
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new,
                            color: Color(0xFF1A1A2E), size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: BlocBuilder<TransportAttendanceBloc,
                      TransportAttendanceState>(
                    builder: (context, state) {
                      if (state is TransportAttendanceLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFF2E9E5B)),
                        );
                      }

                      if (state is TransportAttendanceError) {
                        return _errorView(state.message);
                      }

                      if (state is TransportAttendanceLoaded) {
                        final list =
                        List<TransportAttendanceModel>.from(state.attendance)
                          ..sort((a, b) =>
                              b.attendanceDate.compareTo(a.attendanceDate));

                        if (list.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.event_busy_outlined,
                                    size: 64,
                                    color: const Color(0xFF1A1A2E)
                                        .withOpacity(0.15)),
                                const SizedBox(height: 16),
                                Text(
                                  'No attendance found',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: const Color(0xFF1A1A2E)
                                        .withOpacity(0.4),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        final total = list.length;
                        final present = list.where((e) => !e.isInAbsent).length;
                        final percent = total > 0 ? (present / total * 100) : 0.0;
                        final percentStr = percent.toStringAsFixed(1);
                        final isGood = percent >= 80;

                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                                  child: Container(
                                    padding: const EdgeInsets.all(20),
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
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Technical Training',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF1A1A2E),
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              _statChip('Total', '$total', const Color(0xFF1A1A2E)),
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  _statChip('Present', '$present', const Color(0xFF2E9E5B)),
                                                  const SizedBox(width: 8),
                                                  _statChip('Absent', '${total - present}', const Color(0xFFE53935)),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            isGood
                                                ? 'You can miss ${((present / 0.80).ceil() - total).clamp(0, 999)} more classes'
                                                : 'Attend ${((0.80 * total - present) / 0.20).ceil()} more to reach 80%',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: isGood
                                                  ? const Color(0xFF2E9E5B)
                                                  : const Color(0xFFE53935),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Column(
                                      children: [
                                        Text(
                                          '$percentStr%',
                                          style: TextStyle(
                                            fontSize: 36,
                                            fontWeight: FontWeight.w700,
                                            color: isGood
                                                ? const Color(0xFF2E9E5B)
                                                : const Color(0xFFE53935),
                                          ),
                                        ),
                                        Text(
                                          'Attendance',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF1A1A2E),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),),
                            ),
                            Expanded(
                                child: RefreshIndicator(
                                  onRefresh: _onRefresh,
                                  color: const Color(0xFF2E9E5B),
                                  child: ListView.builder(
                                    padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: list.length + 1,
                                    itemBuilder: (context, index) {
                                      if (index == list.length) {
                                        return const AppFooter();
                                      }
                                      final item = list[index];
                                      final isAbsent = item.isInAbsent;
                                      final date = DateFormat('dd MMM yyyy').format(item.attendanceDate);
                                      return _attendanceCard(date: date, isAbsent: isAbsent);
                                    },
                                  ),
                                )
                            )
                          ],
                        );
                      }

                      return const SizedBox();
                    },
                  ),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _errorView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded,
                size: 56,
                color: const Color(0xFF1A1A2E).withOpacity(0.2)),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                color: const Color(0xFF1A1A2E).withOpacity(0.6),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _onRefresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E9E5B),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child:
              const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _attendanceCard({
    required String date,
    required bool isAbsent,
  }) {
    final statusColor =
    isAbsent ? const Color(0xFFE53935) : const Color(0xFF2E9E5B);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withOpacity(0.7),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [


          // Date
          Expanded(
            child: Text(
              date,
              style: const TextStyle(
                color: Color(0xFF1A1A2E),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),


          // Status circle
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: statusColor.withOpacity(0.1),
            ),
            child: Icon(
              isAbsent ? Icons.close_rounded : Icons.check_rounded,
              color: statusColor,
              size: 20,
            ),
          ),
          // const SizedBox(width: 14),

          // Status badge
          // Container(
          //   padding:
          //   const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          //   decoration: BoxDecoration(
          //     color: statusColor.withOpacity(0.1),
          //     borderRadius: BorderRadius.circular(20),
          //   ),
          //   child: Text(
          //     isAbsent ? 'Absent' : 'Present',
          //     style: TextStyle(
          //       color: statusColor,
          //       fontSize: 12,
          //       fontWeight: FontWeight.w600,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}