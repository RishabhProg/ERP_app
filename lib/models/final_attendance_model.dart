class AttendanceEntry {
  final String subjectName;
  final bool isAbsent;
  final String? absentDate;

  AttendanceEntry({
    required this.subjectName,
    required this.isAbsent,
    this.absentDate,
  });

  factory AttendanceEntry.fromJson(Map<String, dynamic> json) {
    try {
      return AttendanceEntry(
        subjectName: json['subjectName']?.toString() ?? 'Unknown Subject',
        isAbsent: json['isAbsent'] == true,
        absentDate: json['absentDate']?.toString(),
      );
    } catch (e) {
      throw 'Failed to read attendance data. Please try again';
    }
  }
}
