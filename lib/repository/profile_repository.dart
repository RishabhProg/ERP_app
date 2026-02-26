import 'dart:convert';
import 'package:erp_app/models/login_response.dart';
import 'package:erp_app/models/profile_model.dart';
import 'package:http/http.dart' as http;

Map<String, String> buildHeaders(LoginResponse response) {
  return {
    'Authorization':'Bearer ${response.accessToken}',
    'Accept': 'application/json',
    'x-wb': '1',
    'sessionid': response.sessionId,
    'x-contextid': '194',
    'x-userid': response.xUserId,
    'x_token': response.xToken,
    'x-rx': '1',
    'User-Agent': 'Postman/Runtime/7.51.1',
  };
}

class ProfileRepository {
  Future<UserProfile> fetchUserProfile(LoginResponse loginResponse) async {
    print('LOGIN RESPONSE USED: ${loginResponse.xUserId}');
    final headers = buildHeaders(loginResponse);
    print('Profile Request Headers: $headers');

    final userId = loginResponse.xUserId;
    final url =
        'https://erp.akgec.ac.in/api/User?Id=$userId&val=0&val1=0&val2=0&val3=0';

    final response = await http.get(Uri.parse(url), headers: headers);
    print('Profile Response Body: ${response.body}');

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      final jsonData = json.decode(response.body);
      print(response.statusCode);
      return UserProfile.fromJson(jsonData);
    } else {
      print('Profile fetch failed with Error Code: ${response.statusCode}');
      throw Exception('Failed to fetch profile. Status code: ${response.statusCode}, Body: ${response.body}');
    }
  }
}
