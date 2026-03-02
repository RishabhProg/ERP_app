
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
    return LoginResponse(
      accessToken: json['access_token'],
      sessionId: json['SessionId'],
      xUserId: json['X-UserId'],
      xToken: json['X_Token'],
      expiresIn: json['expires_in'] ?? 172799,
    );
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
