import 'dart:async';
import 'dart:convert';
import 'dart:io';
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
      'Accept': 'application/json',
      'x-wb': '1',
      'sessionid': sessionId!,
      'x-contextid': '194',
      'x-userid': userId!,
      'x_token': xToken!,
      'x-rx': '1',
      'User-Agent': 'ERP/1.0'
    };
  }

  Future<List<Semester>> fetchSemesters() async {
    try {
      final headers = await _getHeaders();
      final userId = headers['x-userid'];

      final response = await http
          .get(
        Uri.parse('https://erp.akgec.ac.in/api/SubjectAttendance?userFromClient=0&userId=$userId'),
        headers: headers,
      )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 401) {
        throw ('Session expired. Please login again');
      } else if (response.statusCode != 200) {
        throw ('Server error: ${response.statusCode}');
      }

      final List<dynamic> data = json.decode(response.body);
      final Set<int> seen = {};
      final List<Semester> semesters = [];

      for (var item in data) {
        final semester = item['semester'];
        final userId = item['userId'];

        if (semester == null || userId == null) continue; // skip bad entries

        final int semesterId = semester is int ? semester : int.tryParse(semester.toString()) ?? 0;
        final int semesterUserId = userId is int ? userId : int.tryParse(userId.toString()) ?? 0;

        if (semesterId == 0 || semesterUserId == 0) continue; // skip invalid

        if (!seen.contains(semesterId)) {
          seen.add(semesterId);
          semesters.add(Semester(
            id: semesterId,
            name: 'Semester $semesterId',
            userId: semesterUserId,
            courseName: item['courseName']?.toString() ?? '',
            batchName: item['batchName']?.toString() ?? '',
          ));
        }
      }

      semesters.sort((a, b) => b.id.compareTo(a.id));
      return semesters;
    } on SocketException {
      throw ('No internet connection');
    } on TimeoutException {
      throw ('Request timed out. Please try again');
    }
  }

  Future<List<AttendanceEntry>> fetchAttendance(int userId) async {
    try {
      final headers = await _getHeaders();

      final response = await http
          .get(
        Uri.parse('https://erp.akgec.ac.in/api/SubjectAttendance/GetPresentAbsentStudent?isDateWise=false&termId=0&userId=$userId&y=0'),
        headers: headers,
      )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 401) {
        throw ('Session expired. Please login again');
      } else if (response.statusCode != 200) {
        throw ('Server error: ${response.statusCode}');
      }

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
    } on SocketException {
      throw ('No internet connection');
    } on TimeoutException {
      throw ('Request timed out. Please try again');
    }
  }
}
