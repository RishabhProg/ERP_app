import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthRepository {
  Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse('https://erp.akgec.ac.in/Token');
    print('login, initiated');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: 'grant_type=password&username=$username&password=$password',
    );

    print(response.headers);

    if (response.statusCode == 200) {

      print('login ----------------');
      print(response.statusCode);
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }
}
