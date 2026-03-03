import '../../models/transport_attendance_model.dart';

abstract class TransportAttendanceState {}

class TransportAttendanceInitial extends TransportAttendanceState {}

class TransportAttendanceLoading extends TransportAttendanceState {}

class TransportAttendanceLoaded extends TransportAttendanceState {
  final List<TransportAttendanceModel> attendance;

  TransportAttendanceLoaded(this.attendance);
}

class TransportAttendanceError extends TransportAttendanceState {
  final String message;

  TransportAttendanceError(this.message);
}