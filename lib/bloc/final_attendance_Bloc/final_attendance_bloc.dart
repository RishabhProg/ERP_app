import 'package:bloc/bloc.dart';

import '../../repository/final_attendance_repo.dart';
import 'final_attendance_event.dart';
import 'final_attendance_state.dart';

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
    try {
      emit(state.copyWith(isLoading: true));

      final semesters = await repository.fetchSemesters();

      if (semesters.isEmpty) {
        emit(state.copyWith(isLoading: false));
        return;
      }

      final selected = semesters.first;
      final attendance =
      await repository.fetchAttendance(selected.userId);

      emit(state.copyWith(
        isLoading: false,
        semesters: semesters,
        selectedSemesterId: selected.id,
        attendance: attendance,
      ));
    } catch (e, stack) {
      print('❌ LOAD DATA ERROR: $e');
      print(stack);

      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _onChangeSemester(
      ChangeSemester event,
      Emitter<AttendanceState> emit,
      ) async {
    try {
      emit(state.copyWith(isLoading: true));

      final selected =
      state.semesters.firstWhere((s) => s.id == event.semesterId);

      final attendance =
      await repository.fetchAttendance(selected.userId);

      emit(state.copyWith(
        selectedSemesterId: event.semesterId,
        attendance: attendance,
        isLoading: false,
      ));
    } catch (e, stack) {
      print('❌ CHANGE SEM ERROR: $e');
      print(stack);

      emit(state.copyWith(isLoading: false));
    }
  }
}