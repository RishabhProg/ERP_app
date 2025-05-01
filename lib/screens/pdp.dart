import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as secure_Storage;

class Pdp extends StatefulWidget {
  const Pdp({super.key});

  @override
  State<Pdp> createState() => _PdpState();
}

class _PdpState extends State<Pdp> {
  late Future<Map<String, List<TransportAttendance>>> groupedAttendance;

  @override
  void initState() {
    super.initState();
    groupedAttendance = fetchAndGroupAttendance();
  }

  Future<String> fetchAdmissionNumber() async {
    final storage = secure_Storage.FlutterSecureStorage();
    final accessToken = await storage.read(key: 'accessToken');
    final sessionId = await storage.read(key: 'sessionId');
    final userId = await storage.read(key: 'xUserId');
    final xToken = await storage.read(key: 'xToken');

    if (accessToken == null || sessionId == null || userId == null || xToken == null) {
      throw Exception("Missing authentication headers.");
    }

    final url = Uri.parse('https://erp.akgec.ac.in/api/User/GetByUserId/$userId?y=0');
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'x_token': xToken,
      'x-userid': userId,
      'sessionid': sessionId,
      'x-contextid': '194',
      'x-wb': '1',
      'Content-Type': 'application/json',
      'Accept': 'application/json, text/plain, */*',
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200 && response.body.isNotEmpty && response.body != 'null') {
      final data = jsonDecode(response.body);
      if (data['admissionNumber'] != null) {
        return data['admissionNumber'];
      } else {
        throw Exception("admissionNumber not found.");
      }
    } else {
      throw Exception('Failed to fetch user info.');
    }
  }

  Future<Map<String, List<TransportAttendance>>> fetchAndGroupAttendance() async {
    final admissionNumber = await fetchAdmissionNumber();
    final storage = secure_Storage.FlutterSecureStorage();
    final accessToken = await storage.read(key: 'accessToken');
    final sessionId = await storage.read(key: 'sessionId');
    final userId = await storage.read(key: 'xUserId');
    final xToken = await storage.read(key: 'xToken');

    final url = Uri.parse(
      'https://erp.akgec.ac.in/api/TransportAttendanceReport?admissionNumber=$admissionNumber&type=7',
    );

    final headers = {
      'Authorization': 'Bearer $accessToken',
      'x_token': xToken ?? '',
      'x-userid': userId ?? '',
      'sessionid': sessionId ?? '',
      'x-contextid': '194',
      'x-wb': '1',
      'Content-Type': 'application/json',
      'Accept': 'application/json, text/plain, */*',
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      final List<TransportAttendance> parsedList =
          data.map((json) => TransportAttendance.fromJson(json)).toList();
      return _groupByDate(parsedList);
    } else {
      throw Exception('Failed to load attendance.');
    }
  }

  Map<String, List<TransportAttendance>> _groupByDate(List<TransportAttendance> list) {
    Map<String, List<TransportAttendance>> grouped = {};
    for (var item in list) {
      String dateKey = item.attendanceDate.toIso8601String().substring(0, 10);
      grouped.putIfAbsent(dateKey, () => []).add(item);
    }
    return grouped;
  }

  String _getStatus(List<TransportAttendance> records) {
    return records.map((r) => r.isInAbsent == false ? 'P' : 'A').join();
  }

  Color _statusColor(String status) {
    return status.contains('A') ? Colors.redAccent : Colors.greenAccent;
  }

  int _countTotalPresent(Map<String, List<TransportAttendance>> grouped) {
    return grouped.values.expand((list) => list).where((r) => r.isInAbsent == false).length;
  }

  int _countTotalClasses(Map<String, List<TransportAttendance>> grouped) {
    return grouped.values.expand((list) => list).length;
  }

  double _calculatePercentage(int present, int total) {
    if (total == 0) return 0.0;
    return (present / total) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        cardColor: Colors.grey[900],
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
          titleLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text("PDP Attendance", style: TextStyle(color: Colors.white, fontSize: 22)),
          backgroundColor: Colors.black,
        ),
        body: FutureBuilder<Map<String, List<TransportAttendance>>>(
          future: groupedAttendance,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            final grouped = snapshot.data!;
            if (grouped.isEmpty) {
              return const Center(child: Text("No attendance data"));
            }

            final totalPresent = _countTotalPresent(grouped);
            final totalClasses = _countTotalClasses(grouped);
            final percentage = _calculatePercentage(totalPresent, totalClasses);

            final sortedEntries = grouped.entries.toList()
              ..sort((a, b) => b.key.compareTo(a.key)); // sort by date descending

            return ListView(
              padding: const EdgeInsets.all(8),
              children: [
                Card(
                  color: Colors.grey[850],
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Total Classes: $totalClasses", style: TextStyle(fontSize: 16)),
                        const SizedBox(height: 4),
                        Text("Total Present: $totalPresent", style: TextStyle(fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(
                          "Overall Attendance: ${percentage.toStringAsFixed(2)}%",
                          style: TextStyle(
                            fontSize: 20,
                            color: percentage > 75 ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ...sortedEntries.map((entry) {
                  final status = _getStatus(entry.value);
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      title: Text("Date: ${entry.key}", style: Theme.of(context).textTheme.titleLarge),
                      subtitle: Text(
                        "Status: $status",
                        style: TextStyle(
                          color: _statusColor(status),
                          fontSize: 16,
                        ),
                      ),
                      leading: Icon(
                        status.contains('A') ? Icons.close : Icons.check,
                        color: _statusColor(status),
                      ),
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }
}

class TransportAttendance {
  final DateTime attendanceDate;
  final bool? isInAbsent;

  TransportAttendance({required this.attendanceDate, required this.isInAbsent});

  factory TransportAttendance.fromJson(Map<String, dynamic> json) {
    return TransportAttendance(
      attendanceDate: DateTime.parse(json['attendanceDate']),
      isInAbsent: json['isInAbsent'],
    );
  }
}
