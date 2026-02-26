import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthSuccess extends AuthState {
  final String accessToken;
  final String sessionId;
  final String xUserId;
  final String xToken;

  const AuthSuccess({
    required this.accessToken,
    required this.sessionId,
    required this.xUserId,
    required this.xToken,
  });

  AuthSuccess copyWith({
    String? accessToken,
    String? sessionId,
    String? xUserId,
    String? xToken,
}) {
    return AuthSuccess(
        accessToken: accessToken ?? this.accessToken,
        sessionId: sessionId ?? this.sessionId,
        xUserId: xUserId ?? this.xUserId,
        xToken: xToken ?? this.xToken,
    );
  }
  @override
  List<Object> get props => [accessToken, sessionId, xUserId, xToken];
  
}

class AuthFailure extends AuthState {
  final String errorMessage;

  const AuthFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}