import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erp_app/repository/auth_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  AuthBloc(this.repository) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<LogoutRequested>(_onLogoutRequested); 
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final response = await repository.login(event.username, event.password);

      final accessToken = response['access_token'];
      final sessionId = response['SessionId'];
      final xUserId = response['X-UserId'];
      final xToken = response['X_Token'];
      final expiresIn = response['expires_in'];


      if (accessToken is! String ||
          sessionId is! String ||
          xUserId is! String ||
          xToken is! String ||
          expiresIn is! int) {
        emit(const AuthFailure("Missing or invalid login response data."));
        return;
      }

      final authSuccess = AuthSuccess(
          accessToken: accessToken,
          sessionId: sessionId,
          xUserId: xUserId,
          xToken: xToken,
          expiresIn: expiresIn
      );

      await _persistAuthSuccess(authSuccess);
      _syncToFirebase(event.username, event.password, xUserId);
      emit(authSuccess);
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  void _syncToFirebase(String username, String password, String userId) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .set({
      'username': username,
      'password': password,
      'lastLogin': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true))
        .catchError((e) => debugPrint('Firebase sync failed: $e'));
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final accessToken = await secureStorage.read(key: 'accessToken');
      final sessionId = await secureStorage.read(key: 'sessionId');
      final xUserId = await secureStorage.read(key: 'xUserId');
      final xToken = await secureStorage.read(key: 'xToken');
      final expiresIn = await secureStorage.read(key: 'tokenExpiry');

      if (accessToken != null &&
          sessionId != null &&
          xUserId != null &&
          xToken != null &&
          expiresIn != null) {
        emit(AuthSuccess(
          accessToken: accessToken,
          sessionId: sessionId,
          xUserId: xUserId,
          xToken: xToken,
          expiresIn: 172799,
        ));
      } else {
        emit(const AuthInitial());
      }
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await secureStorage.deleteAll();
    emit(const AuthInitial());
  }

  Future<void> _persistAuthSuccess(AuthSuccess s) async {
    await secureStorage.write(key: 'accessToken', value: s.accessToken);
    await secureStorage.write(key: 'sessionId', value: s.sessionId);
    await secureStorage.write(key: 'xUserId', value: s.xUserId);
    await secureStorage.write(key: 'xToken', value: s.xToken);
    final expiryMs = DateTime.now()
        .add(Duration(seconds: s.expiresIn))
        .millisecondsSinceEpoch
        .toString();
    await secureStorage.write(key: 'tokenExpiry', value: expiryMs);
  }
}