import 'dart:ui';
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
    final bool isLow = percentValue < 75;
    final Color statusColor =
    isLow ? const Color(0xFFE53935) : const Color(0xFF3DAA70);

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Colors.white.withOpacity(0.05),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              InkWell(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                  child: Row(
                    children: [
                      // Vertical color bar
                      Container(
                        width: 4,
                        height: 80,
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(14),
                            bottomLeft: Radius.circular(14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Content
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.subject,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 17,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'ATTENDED',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white.withOpacity(0.4),
                                          letterSpacing: 1,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "${widget.present} / ${widget.total}",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 16),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          color: statusColor.withOpacity(0.5)),
                                    ),
                                    child: Text(
                                      "${widget.percent}%",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: statusColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Trailing icons
                      Column(
                        children: [
                          // IconButton(
                          //   icon: Icon(
                          //     Icons.calendar_month_outlined,
                          //     color: Colors.white.withOpacity(0.4),
                          //     size: 20,
                          //   ),
                          //   onPressed: () => _showCalendarDialog(context),
                          // ),
                          Icon(
                            _isExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: Colors.white.withOpacity(0.4),
                            size: 20,
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ),
              if (_isExpanded) ...[
                Divider(
                  height: 1,
                  color: Colors.white.withOpacity(0.08),
                  indent: 16,
                  endIndent: 16,
                ),
                GestureDetector(
                  onTap: () => setState(() => _isExpanded = false),
                  child: widget.groupedByDate.isEmpty
                      ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      "No attendance data.",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.3),
                        fontSize: 14,
                      ),
                    ),
                  )
                      : Column(
                    children: widget.groupedByDate.map((item) {
                      final status = item['status'] ?? '';
                      final date = item['date'] ?? 'Unknown Date';

                      return ListTile(
                        dense: false,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 0.1),
                        title: Text(
                          date,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: status.split('').map((char) {
                            final isAbsent = char == 'A';
                            return Container(
                              width: 34,
                              height: 34,
                              margin: const EdgeInsets.only(left: 6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: (isAbsent
                                    ? const Color(0xFFE53935)
                                    : const Color(0xFF2E7D32))
                                    .withOpacity(0.1),
                                border: Border.all(
                                  color: (isAbsent
                                      ? const Color(0xFFE53935)
                                      : const Color(0xFF2E7D32))
                                      .withOpacity(0.4),
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  char,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: isAbsent
                                        ? const Color(0xFFE53935)
                                        : const Color(0xFF2E7D32),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showCalendarDialog(BuildContext context) {
    final inputFormat = DateFormat('dd MMM yyyy');
    Map<DateTime, String> statusByDate = {};

    for (var item in widget.groupedByDate) {
      final dateStr = item['date'];
      final status = item['status'];
      if (dateStr != null && status != null) {
        try {
          final parsed = inputFormat.parse(dateStr);
          final normalizedDate =
          DateTime(parsed.year, parsed.month, parsed.day);
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
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1F2E).withOpacity(0.95),
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(
                  color: Colors.white.withOpacity(0.1), width: 1.5),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.subject,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 380,
                  child: TableCalendar(
                    firstDay: DateTime.utc(2023, 1, 1),
                    lastDay: DateTime.utc(2025, 12, 31),
                    focusedDay: DateTime.now(),
                    calendarStyle: CalendarStyle(
                      defaultTextStyle: const TextStyle(color: Colors.white),
                      weekendTextStyle:
                      TextStyle(color: Colors.white.withOpacity(0.6)),
                      outsideTextStyle:
                      TextStyle(color: Colors.white.withOpacity(0.2)),
                      todayTextStyle: const TextStyle(color: Colors.white),
                      disabledTextStyle:
                      TextStyle(color: Colors.white.withOpacity(0.15)),
                      selectedTextStyle: const TextStyle(color: Colors.white),
                      todayDecoration: const BoxDecoration(
                        color: Color(0xFF7B6FF0),
                        shape: BoxShape.circle,
                      ),
                      markerDecoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                      ),
                    ),
                    headerStyle: HeaderStyle(
                      titleTextStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      formatButtonVisible: false,
                      leftChevronIcon: Icon(Icons.chevron_left,
                          color: Colors.white.withOpacity(0.6)),
                      rightChevronIcon: Icon(Icons.chevron_right,
                          color: Colors.white.withOpacity(0.6)),
                    ),
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      weekendStyle: TextStyle(
                        color: Colors.white.withOpacity(0.3),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, date, events) {
                        final normalized =
                        DateTime(date.year, date.month, date.day);
                        final status = statusByDate[normalized];
                        if (status != null && status.isNotEmpty) {
                          List<Widget> dots = status.split('').map((char) {
                            return Container(
                              width: 6,
                              height: 6,
                              margin:
                              const EdgeInsets.symmetric(horizontal: 1),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: char == 'A'
                                    ? const Color(0xFFE53935)
                                    : const Color(0xFF2E7D32),
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