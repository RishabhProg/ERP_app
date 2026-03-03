import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../bloc/TT_bloc/tt_bloc.dart';
import '../bloc/TT_bloc/tt_event.dart';
import '../bloc/TT_bloc/tt_state.dart';
import '../models/transport_attendance_model.dart';

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

    /// ✅ Correct event call (no parameter now)
    Future.microtask(() {
      context.read<TransportAttendanceBloc>().add(
        FetchTransportAttendance(),
      );
    });
  }

  Future<void> _onRefresh() async {
    context.read<TransportAttendanceBloc>().add(
      FetchTransportAttendance(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1A),
      appBar: AppBar(
        title: const Text("Mandatory Attendance"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          /// 🌌 Background animation
          Positioned.fill(
            child: Opacity(
              opacity: 0.35,
              child: Lottie.asset(
                'assets/night.json',
                fit: BoxFit.cover,
                repeat: true,
              ),
            ),
          ),

          /// 🔥 Content
          SafeArea(
            child: BlocBuilder<TransportAttendanceBloc,
                TransportAttendanceState>(
              builder: (context, state) {
                if (state is TransportAttendanceLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
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
                    return const Center(
                      child: Text(
                        "No attendance found",
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      physics: const BouncingScrollPhysics(),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final item = list[index];

                        final isAbsent = item.isInAbsent;
                        final status = isAbsent ? "Absent" : "Present";
                        final date = DateFormat('dd MMM yyyy')
                            .format(item.attendanceDate);

                        return _attendanceCard(
                          date: date,
                          status: status,
                          isAbsent: isAbsent,
                        );
                      },
                    ),
                  );
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  /// ❌ Error UI
  Widget _errorView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 56,
              color: Colors.white.withOpacity(0.4),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _onRefresh,
              child: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }

  /// 🎯 Clean premium card (NO remarks)
  Widget _attendanceCard({
    required String date,
    required String status,
    required bool isAbsent,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
              ),
            ),
            child: Row(
              children: [
                /// Status icon
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: isAbsent
                        ? Colors.red.withOpacity(0.2)
                        : Colors.green.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isAbsent ? Icons.close : Icons.check,
                    color: isAbsent ? Colors.red : Colors.green,
                  ),
                ),
                const SizedBox(width: 14),

                /// Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        date,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        status,
                        style: TextStyle(
                          color: isAbsent
                              ? Colors.redAccent
                              : Colors.greenAccent,
                          fontWeight: FontWeight.w600,
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
    );
  }
}