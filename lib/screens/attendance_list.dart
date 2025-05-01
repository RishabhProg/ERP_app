import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class SubjectAttendanceTile extends StatefulWidget {
  final String subject;
  final int present;
  final int total;
  final String percent;
  final List<Map<String, String>> groupedByDate;

  const SubjectAttendanceTile({
    super.key,
    required this.subject,
    required this.present,
    required this.total,
    required this.percent,
    required this.groupedByDate,
  });

  @override
  _SubjectAttendanceTileState createState() => _SubjectAttendanceTileState();
}

class _SubjectAttendanceTileState extends State<SubjectAttendanceTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final double percentValue = double.tryParse(widget.percent) ?? 0;

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      alignment: Alignment.topCenter,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 172, 127, 209),
              Color.fromARGB(255, 192, 178, 196)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Column(
            children: [
              ListTile(
                title: Text(
                  widget.subject,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                subtitle: Text(
                  "Present: ${widget.present} / ${widget.total}   (${widget.percent}%)",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: percentValue < 75 ? Colors.red : Colors.green,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.calendar_month, color: Colors.white),
                      onPressed: () => _showCalendarDialog(context),
                    ),
                    Icon(
                      _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: Colors.white,
                    ),
                  ],
                ),
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
              ),
              if (_isExpanded)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isExpanded = false;
                    });
                  },
                  child: Column(
                    children: widget.groupedByDate.isEmpty
                        ? [
                            const ListTile(
                              title: Text(
                                "No attendance data.",
                                style: TextStyle(color: Colors.white),
                              ),
                            )
                          ]
                        : widget.groupedByDate.map((item) {
                            final status = item['status'] ?? '';
                            final date = item['date'] ?? 'Unknown Date';
                            return ListTile(
                              leading: Icon(
                                status.contains('A') ? Icons.cancel : Icons.check_circle,
                                color: status.contains('A') ? Colors.red : Colors.green,
                              ),
                              title: Text(
                                "$date - $status",
                                style: const TextStyle(color: Colors.white),
                              ),
                            );
                          }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCalendarDialog(BuildContext context) {
  final inputFormat = DateFormat('dd MMM yyyy'); // e.g., 17 Apr 2025
  Map<DateTime, String> statusByDate = {};

  for (var item in widget.groupedByDate) {
    final dateStr = item['date'];
    final status = item['status'];
    if (dateStr != null && status != null) {
      try {
        final parsed = inputFormat.parse(dateStr);
        final normalizedDate = DateTime(parsed.year, parsed.month, parsed.day);
        statusByDate.update(
          normalizedDate,
          (existing) => existing + status,
          ifAbsent: () => status,
        );
      } catch (e) {
        debugPrint("Date parsing error: $e");
      }
    }
  }

  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF1E1E1E),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(widget.subject, style: const TextStyle(color: Colors.white, fontSize: 18)),
          const SizedBox(height: 12),
          Expanded(
            child: TableCalendar(
  firstDay: DateTime.utc(2023, 1, 1),
  lastDay: DateTime.utc(2025, 12, 31),
  focusedDay: DateTime.now(),
  calendarStyle: CalendarStyle(
    defaultTextStyle: const TextStyle(color: Colors.white),
    weekendTextStyle: const TextStyle(color: Colors.white),
    outsideTextStyle: const TextStyle(color: Colors.white54),
    todayTextStyle: const TextStyle(color: Colors.white),
    disabledTextStyle: const TextStyle(color: Colors.white38),
    selectedTextStyle: const TextStyle(color: Colors.black),
    todayDecoration: const BoxDecoration(
      color: Colors.blueAccent,
      shape: BoxShape.circle,
    ),
    markerDecoration: const BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.transparent,
    ),
  ),
  headerStyle: const HeaderStyle(
    titleTextStyle: TextStyle(color: Colors.white, fontSize: 16),
    formatButtonTextStyle: TextStyle(color: Colors.white),
    formatButtonDecoration: BoxDecoration(
      color: Colors.transparent,
    ),
    leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
    rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
  ),
  calendarBuilders: CalendarBuilders(
    markerBuilder: (context, date, events) {
      final normalized = DateTime(date.year, date.month, date.day);
      final status = statusByDate[normalized];

      if (status != null && status.isNotEmpty) {
        List<Widget> dots = status.split('').map((char) {
          return Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: char == 'A' ? Colors.red : Colors.green,
            ),
          );
        }).toList();

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: dots,
        );
      }
      return null;
    },
  ),
)

   ),
        ],
      ),
    ),
  );
}

}
