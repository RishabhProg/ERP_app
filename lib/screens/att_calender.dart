import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class AttendanceCalendarDialog extends StatelessWidget {
  final List<Map<String, String>> attendanceData;
  final String subject;

  const AttendanceCalendarDialog({
    super.key,
    required this.attendanceData,
    required this.subject,
  });

  /// Group attendance data by date
  Map<DateTime, List<String>> _groupAttendanceByDate() {
    final Map<DateTime, List<String>> grouped = {};

    for (var entry in attendanceData) {
      final date = DateTime.parse(entry['date']!);
      final status = entry['status']!;

      final day = DateTime(date.year, date.month, date.day); // Remove time

      if (!grouped.containsKey(day)) {
        grouped[day] = [];
      }

      grouped[day]!.add(status);
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final groupedEvents = _groupAttendanceByDate();

    return Dialog(
      backgroundColor: const Color(0xFF2C2C2C),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "$subject Attendance",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 400,
              child: TableCalendar(
                firstDay: DateTime.utc(2023, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: DateTime.now(),
                calendarStyle: const CalendarStyle(
                  outsideDaysVisible: false,
                  markersAlignment: Alignment.bottomCenter,
                ),
                eventLoader: (day) {
                  return groupedEvents[DateTime(day.year, day.month, day.day)] ?? [];
                },
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    if (events.isEmpty) return const SizedBox();

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: events.map((e) {
                        // Safely cast e to String and use contains
                        final status = e as String? ?? '';  // Cast to String safely
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: status.contains('A') ? Colors.red : Colors.green,
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
                headerStyle: const HeaderStyle(
                  titleTextStyle: TextStyle(color: Colors.white),
                  formatButtonVisible: false,
                  leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
                  rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
                ),
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: Colors.white),
                  weekendStyle: TextStyle(color: Colors.redAccent),
                ),
                calendarFormat: CalendarFormat.month,
                availableGestures: AvailableGestures.all,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
