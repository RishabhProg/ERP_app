import 'dart:convert';
import 'package:erp_app/models/final_attendance_model.dart';
import 'package:erp_app/models/sem_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/attendance_model.dart';
//import '../models/semester_model.dart';

class AttendanceRepository {
  final secureStorage = const FlutterSecureStorage();

  Future<Map<String, String>> _getHeaders() async {
    final accessToken = await secureStorage.read(key: 'accessToken');
    final sessionId = await secureStorage.read(key: 'sessionId');
    final userId = await secureStorage.read(key: 'xUserId');
    final xToken = await secureStorage.read(key: 'xToken');

    return {
      'Authorization': 'Bearer $accessToken',
      'x-wb': '1',
      'sessionid': sessionId!,
      'x-contextid': '194',
      'x-userid': userId!,
      'x_token': xToken!,
      'x-rx': '1',
    };
  }

  Future<List<Semester>> fetchSemesters() async {
    final headers = await _getHeaders();
    final userId = headers['x-userid'];
    final response = await http.get(
      Uri.parse('https://erp.akgec.ac.in/api/SubjectAttendance?userFromClient=0&userId=$userId'),
      headers: headers,
    );

    final List<dynamic> data = json.decode(response.body);
    final Set<int> seen = {};
    final List<Semester> semesters = [];

    for (var item in data) {
      final int semester = item['semester'];
      if (!seen.contains(semester)) {
        seen.add(semester);
        semesters.add(Semester(
          id: semester,
          name: 'Semester $semester',
          userId: item['userId'],
        ));
      }
    }

    semesters.sort((a, b) => b.id.compareTo(a.id));
    return semesters;
  }

  Future<List<AttendanceEntry>> fetchAttendance(int userId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('https://erp.akgec.ac.in/api/SubjectAttendance/GetPresentAbsentStudent?isDateWise=false&termId=0&userId=$userId&y=0&'),
      headers: headers,
    );

    final data = json.decode(response.body);
    final List<AttendanceEntry> combined = [];

    final List<Map<String, dynamic>> regular =
        List<Map<String, dynamic>>.from(data['attendanceData'] ?? []);
    final List<Map<String, dynamic>> extra =
        List<Map<String, dynamic>>.from(data['extraLectures'] ?? []);

    final subjectMap = {
      for (var e in regular) e['subjectId']: e['subjectName']
    };

    for (var e in extra) {
      e['subjectName'] ??= subjectMap[e['subjectId']];
    }

    final combinedRaw = [...regular, ...extra];
    for (var entry in combinedRaw) {
      if (entry['subjectName'] != null) {
        combined.add(AttendanceEntry.fromJson(entry));
      }
    }

    return combined;
  }
}
