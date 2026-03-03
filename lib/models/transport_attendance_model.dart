class TransportAttendanceModel {
  final DateTime attendanceDate;
  final bool isInAbsent;
  final String? remarks;

  TransportAttendanceModel({
    required this.attendanceDate,
    required this.isInAbsent,
    this.remarks,
  });

  factory TransportAttendanceModel.fromJson(Map<String, dynamic> json) {
    return TransportAttendanceModel(
      attendanceDate: DateTime.parse(json['attendanceDate']),
      isInAbsent: json['isInAbsent'] ?? false,
      remarks: json['remarks'],
    );
  }
}