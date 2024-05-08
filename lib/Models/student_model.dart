class Student {
  final String name;
  final String entryNumber;
  int totalAttendance = 0;
  bool isPresent = false;
  Map<String, dynamic> marks;

  Student(
      {this.name = "",
      required this.entryNumber,
      this.totalAttendance = 0,
      this.isPresent = false,
      this.marks = const {'No Marks': ''}});
}