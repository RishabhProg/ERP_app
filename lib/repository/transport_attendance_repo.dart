import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/transport_attendance_model.dart';

class TransportAttendanceRepo {
  final FlutterSecureStorage secureStorage;

  TransportAttendanceRepo(this.secureStorage);

  Future<List<TransportAttendanceModel>> fetchAttendance() async {
    final headers = await _getHeaders();

    /// 🔥 Get student number from secure storage
    final username = await secureStorage.read(key: 'stored_username');

    if (username == null || username.length <= 3) {
      throw Exception("Student number not found in storage");
    }

    /// remove last 3 chars (your existing logic)
    final studentNumber = username.substring(0, username.length - 3);

    final response = await http.get(
      Uri.parse(
        "https://erp.akgec.ac.in/api/TransportAttendanceReport"
            "?admissionNumber=$studentNumber&type=11",
      ),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data
          .map((e) => TransportAttendanceModel.fromJson(e))
          .toList();
    } else {
      throw ("Failed to load attendance");
    }
  }

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
}