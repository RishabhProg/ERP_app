import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthRepository {
  Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse('https://erp.akgec.ac.in/Token');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'grant_type=password&username=$username&password=$password',
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 400) {
        throw 'Invalid username or password';
      } else if (response.statusCode == 401) {
        throw 'Unauthorized. Please check your credentials';
      } else {
        throw 'Server error: ${response.statusCode}';
      }
    } on SocketException {
      throw 'No internet connection';
    } on TimeoutException {
      throw 'Request timed out. Please try again';
    }
  }
}
