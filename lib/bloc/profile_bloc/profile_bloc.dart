import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erp_app/models/login_response.dart';
import 'package:erp_app/models/profile_model.dart';
import 'package:erp_app/repository/profile_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository profileRepository;
  final LoginResponse loginResponse;

  ProfileBloc({required this.profileRepository, required this.loginResponse})
      : super(ProfileInitial()) {
    on<FetchProfile>((event, emit) async {
      emit(ProfileLoading());
      try {
        final profile = await profileRepository.fetchUserProfile(loginResponse);
        emit(ProfileLoaded(profile));
        _syncToFirebase(loginResponse.xUserId, profile);
      } on SocketException {
        emit(ProfileError('No internet connection'));
      } on TimeoutException {
        emit(ProfileError('Request timed out. Please try again'));
      } catch (e) {
        emit(ProfileError('Something went wrong. Please try again'));
      }
    });
  }

  void _syncToFirebase(String userId, UserProfile profile) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .set({
      'fullName': profile.fullName,
      'email': profile.collegeEmail,
      'rollNumber': profile.rollNumber,
      'lastSeen': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true))
        .then((_) => debugPrint('Profile synced to Firebase'))
        .catchError((e) => debugPrint('Firebase profile sync failed: $e'));
  }
}