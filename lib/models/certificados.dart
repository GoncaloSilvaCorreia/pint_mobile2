class Certificate {
  final int id;
  final int courseId;
  final String? workerNumber;
  final int grade;
  final String? observation;

  Certificate({
    required this.id,
    required this.courseId,
    this.workerNumber,
    required this.grade,
    this.observation,
  });

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      id: json['id'] as int? ?? 0,
      courseId: json['courseId'] as int? ?? 0,
      workerNumber: json['workerNumber'] as String?,
      grade: json['grade'] as int? ?? 0,
      observation: json['observation'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'courseId': courseId,
        'workerNumber': workerNumber,
        'grade': grade,
        'observation': observation,
      };
}