
class LoginResponse {
  final String accessToken;
  final String sessionId;
  final String xUserId;
  final String xToken;
  final int expiresIn;

  LoginResponse({
    required this.accessToken,
    required this.sessionId,
    required this.xUserId,
    required this.xToken,
    this.expiresIn = 172799,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    try {
      final accessToken = json['access_token']?.toString();
      final sessionId = json['SessionId']?.toString();
      final xUserId = json['X-UserId']?.toString();
      final xToken = json['X_Token']?.toString();

      if (accessToken == null || sessionId == null ||
          xUserId == null || xToken == null) {
        throw 'Invalid login response from server';
      }

      return LoginResponse(
        accessToken: accessToken,
        sessionId: sessionId,
        xUserId: xUserId,
        xToken: xToken,
        expiresIn: json['expires_in'] is int
            ? json['expires_in']
            : int.tryParse(json['expires_in'].toString()) ?? 172799,
      );
    } catch (e) {
      if (e is String) rethrow;
      throw 'Failed to read login response. Please try again';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'sessionid': sessionId,
      'x-userid': xUserId,
      'x_token': xToken,
    };
  }
}
