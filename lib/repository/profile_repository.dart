import 'dart:convert';
import 'dart:io';
import 'package:erp_app/models/login_response.dart';
import 'package:erp_app/models/profile_model.dart';
import 'package:http/http.dart' as http;

Map<String, String> buildHeaders(LoginResponse response) {
  return {
    // 'Cookie':
    //     '_ga_P21KD3ESV2=GS1.1.1717220027.3.0.1717220027.0.0.0; _ga=GA1.2.257840654.1716482344; _gid=GA1.2.287587932.1716482344',
    'Authorization': 'Bearer ${response.accessToken}',
    'Accept': 'application/json',
    'x-wb': '1',
    'sessionid': response.sessionId,
    'x-contextid': '194',
    'x-userid': response.xUserId,
    'x_token': response.xToken,
    'x-rx': '1',
    'User-Agent': 'ERP/1.0'
    //'Cookie': 'sessionid=${response.sessionId}',
  };
}

class ProfileRepository {
  Future<UserProfile> fetchUserProfile(LoginResponse loginResponse) async {
    final headers = buildHeaders(loginResponse);

    final userId = loginResponse.xUserId;
    final url =
        'https://erp.akgec.ac.in/api/User?Id=$userId&val=0&val1=0&val2=0&val3=0';

    final response = await http.get(Uri.parse(url), headers: headers);
    print("RAW x_token: '${loginResponse.xToken}'");

    print(response.headers);

    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");
    print("HEADERS SENT: $headers");

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      print('profile---------');
      print(response.statusCode);
      return UserProfile.fromJson(jsonData);
    } else {
      throw Exception('Failed to fetch profile: ${response.statusCode}');
    }
  }
}
