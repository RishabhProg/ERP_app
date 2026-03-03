class Semester {
  final int id;
  final String name;
  final int userId;
  final String courseName;
  final String batchName;

  Semester({
    required this.id,
    required this.name,
    required this.userId,
    this.courseName = '',
    this.batchName = '',
  });
}