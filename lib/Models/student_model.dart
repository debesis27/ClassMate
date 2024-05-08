class Student {
  final String name;
  final String entryNumber;
  bool isPresent;
  int totalAttendance = 0;

  Student(
      {this.name = "",
      required this.entryNumber,
      this.isPresent = false,
      this.totalAttendance = 0});
}