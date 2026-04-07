import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/TT_bloc/tt_bloc.dart';
import '../bloc/TT_bloc/tt_event.dart';
import '../bloc/TT_bloc/tt_state.dart';
import '../models/transport_attendance_model.dart';
import 'footer.dart';

class MandatoryAttendanceScreen extends StatefulWidget {
  final String admissionNumber;
  final bool hideBackButton;

  const MandatoryAttendanceScreen({
    super.key,
    required this.admissionNumber,
    this.hideBackButton = false,
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
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [

          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      SizedBox(width: 20,),
                      const Text(
                        'Technical Training',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
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
                                    color: Colors.white.withOpacity(0.15)),
                                const SizedBox(height: 16),
                                Text(
                                  'No attendance found',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white.withOpacity(0.4),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        final total = list.length;
                        final present =
                            list.where((e) => !e.isInAbsent).length;
                        final percent =
                            total > 0 ? (present / total * 100) : 0.0;
                        final percentStr = percent.toStringAsFixed(1);
                        final isGood = percent >= 80;

                        return RefreshIndicator(
                          onRefresh: _onRefresh,
                          color: const Color(0xFF2E9E5B),
                          child: CustomScrollView(
                            physics: const BouncingScrollPhysics(
                              parent: AlwaysScrollableScrollPhysics(),
                            ),
                            slivers: [
                              // Summary card
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                          sigmaX: 15, sigmaY: 15),
                                      child: Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: Colors.white.withOpacity(0.07),
                                          border: Border.all(
                                            color:
                                                Colors.white.withOpacity(0.12),
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Label row
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  'ATTENDANCE OVERVIEW',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.white
                                                        .withOpacity(0.45),
                                                    letterSpacing: 1.2,
                                                  ),
                                                ),
                                                Icon(Icons.computer_outlined,
                                                    color: Colors.white
                                                        .withOpacity(0.3),
                                                    size: 18),
                                              ],
                                            ),
                                            const SizedBox(height: 16),

                                            // Percent + stats row
                                            Row(
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '$percentStr%',
                                                      style: TextStyle(
                                                        fontSize: 42,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: isGood
                                                            ? const Color(
                                                                0xFF2E9E5B)
                                                            : const Color(
                                                                0xFFE53935),
                                                      ),
                                                    ),
                                                    Text(
                                                      'Attendance',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.white
                                                            .withOpacity(0.45),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(width: 20),
                                                Expanded(
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          _statBox(
                                                            '$present',
                                                            'PRESENT',
                                                            const Color(
                                                                0xFF2E9E5B),
                                                            const Color(
                                                                0xFF1A2E22),
                                                          ),
                                                          const SizedBox(
                                                              width: 10),
                                                          _statBox(
                                                            '${total - present}',
                                                            'ABSENT',
                                                            const Color(
                                                                0xFFE53935),
                                                            const Color(
                                                                0xFF2E1A1A),
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
                                                            Colors.white
                                                                .withOpacity(
                                                                    0.06),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),

                                            const SizedBox(height: 14),

                                            // Bottom hint
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 14,
                                                      vertical: 10),
                                              decoration: BoxDecoration(
                                                color: Colors.white
                                                    .withOpacity(0.05),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                    color: Colors.white
                                                        .withOpacity(0.08)),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    isGood
                                                        ? Icons.verified_outlined
                                                        : Icons
                                                            .warning_amber_rounded,
                                                    color: isGood
                                                        ? const Color(
                                                            0xFF2E9E5B)
                                                        : const Color(
                                                            0xFFE53935),
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: Text(
                                                      isGood
                                                          ? 'You can miss ${((present / 0.80).ceil() - total).clamp(0, 999)} more classes'
                                                          : 'Attend ${((0.80 * total - present) / 0.20).ceil()} more to reach 80%',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: isGood
                                                            ? const Color(
                                                                0xFF2E9E5B)
                                                            : const Color(
                                                                0xFFE53935),
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
                              ),

                              // Attendance list
                              SliverPadding(
                                padding: const EdgeInsets.only(
                                    left: 16, right: 16, top: 8, bottom: 20),
                                sliver: SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) => _attendanceCard(
                                      date: DateFormat('dd MMM yyyy')
                                          .format(list[index].attendanceDate),
                                      isAbsent: list[index].isInAbsent,
                                    ),
                                    childCount: list.length,
                                  ),
                                ),
                              ),

                              // Footer
                              const SliverToBoxAdapter(
                                child: Column(
                                  children: [
                                    AppFooter(),
                                    SizedBox(height: 100),
                                  ],
                                ),
                              ),
                            ],
                          ),
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

  Widget _statBox(
      String value, String label, Color valueColor, Color bgColor) {
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
                fontSize: 9,
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

  Widget _errorView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded,
                size: 56, color: Colors.white.withOpacity(0.2)),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
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
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
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
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              date,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: statusColor.withOpacity(0.12),
            ),
            child: Icon(
              isAbsent ? Icons.close_rounded : Icons.check_rounded,
              color: statusColor,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
