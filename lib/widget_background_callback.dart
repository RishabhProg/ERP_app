import 'package:flutter/widgets.dart';
import 'package:home_widget/home_widget.dart';
import 'package:erp_app/repository/final_attendance_repo.dart';

@pragma('vm:entry-point')
Future<void> widgetBackgroundCallback(Uri? uri) async {
  if (uri?.host != 'refresh') return;

  WidgetsFlutterBinding.ensureInitialized();

  try {
    final repo = AttendanceRepository();
    // repo._getHeaders() reads from FlutterSecureStorage automatically

    final semesters = await repo.fetchSemesters();
    if (semesters.isEmpty) return;

    // Use latest semester — same as bloc's _onLoadData
    final selected = semesters.first;
    final attendance = await repo.fetchAttendance(selected.userId);

    final total = attendance.length;
    final present = attendance.where((e) => !e.isAbsent).length;
    final percentAsDouble = total > 0 ? (present / total * 100) : 0.0;
    final percent = percentAsDouble.toStringAsFixed(2);

    await HomeWidget.saveWidgetData<String>('percent', percent);
    await HomeWidget.saveWidgetData<int>('present', present);
    await HomeWidget.saveWidgetData<int>('total', total);
    await HomeWidget.updateWidget(androidName: 'HomeScreenWidgetProvider');
    await HomeWidget.updateWidget(androidName: 'HomeScreenWidgetAltProvider');

    debugPrint('Widget refreshed silently: $percent% $present/$total');

  } catch (e) {
    debugPrint('Widget background refresh error: $e');
  }
}