import 'dart:async';
import 'dart:io';
import 'package:erp_app/bloc/final_attendance_Bloc/final_attendance_event.dart';
import 'package:erp_app/bloc/final_attendance_Bloc/final_attendance_state.dart';
import 'package:erp_app/repository/final_attendance_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import "package:home_widget/home_widget.dart";

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final AttendanceRepository repository;

  AttendanceBloc(this.repository) : super(AttendanceState(isLoading: true)) {
    on<LoadSemestersAndAttendance>(_onLoadData);
    on<ChangeSemester>(_onChangeSemester);
  }

  Future<void> _onLoadData(
      LoadSemestersAndAttendance event,
      Emitter<AttendanceState> emit,
      ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final semesters = await repository.fetchSemesters();
      final selected = semesters.first;
      final attendance = await repository.fetchAttendance(selected.userId);
      emit(state.copyWith(
        isLoading: false,
        semesters: semesters,
        selectedSemesterId: selected.id,
        attendance: attendance,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onChangeSemester(
      ChangeSemester event,
      Emitter<AttendanceState> emit,
      ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final selected = state.semesters.firstWhere((s) => s.id == event.semesterId);
      final attendance = await repository.fetchAttendance(selected.userId);
      emit(state.copyWith(
        selectedSemesterId: event.semesterId,
        attendance: attendance,
        isLoading: false,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  void updateAndroidWidget() async{
    await HomeWidget.saveWidgetData<String>('title', 'Attendance');
    await HomeWidget.saveWidgetData('status', '85% present');

    await HomeWidget.updateWidget(
      name: 'HomeScreenWidgetProvider',
      androidName: 'HomeScreenWidgetProvider'
    );
  }
}