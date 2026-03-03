class UserProfile {
  final String fullName;
  final String contactNumber;
  final String rollNumber;
  final String semester;
  final String section;
  final String dob;
  final String address;
  final String fatherName;
  final String motherName;
  final String parentMobileNumber;
  final String collegeEmail;

  UserProfile({
    required this.fullName,
    required this.contactNumber,
    required this.rollNumber,
    required this.semester,
    required this.section,
    required this.dob,
    required this.address,
    required this.fatherName,
    required this.motherName,
    required this.parentMobileNumber,
    required this.collegeEmail,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    try {
      return UserProfile(
        fullName: [
          json['firstName'],
          json['middleName'],
          json['lastName'],
        ].where((part) => part != null && part.toString().isNotEmpty)
            .join(' '),
        contactNumber: json['smsMobileNumber']?.toString() ?? '',
        rollNumber: json['rollNumber']?.toString() ?? '',
        semester: json['semester']?.toString() ?? '',
        section: json['sectionName']?.toString() ?? '',
        dob: json['dob']?.toString().split("T")[0] ?? '',
        address: json['address']?.toString() ?? '',
        fatherName: json['fatherName']?.toString() ?? '',
        motherName: json['motherName']?.toString() ?? '',
        parentMobileNumber: json['parentMobileNumber']?.toString() ?? '',
        collegeEmail: json['email']?.toString() ?? '',
      );
    } catch (e) {
      throw 'Failed to read profile data. Please try again';
    }
  }
}
