class Certificate {
  final int id;
  final int courseId;
  final String? workerNumber;
  final int grade;
  final String? observation;
  final String? pdfUrl;

  Certificate({
    required this.id,
    required this.courseId,
    this.workerNumber,
    required this.grade,
    this.observation,
    this.pdfUrl,
  });

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      id: json['id'] as int? ?? 0,
      courseId: json['courseId'] as int? ?? 0,
      workerNumber: json['workerNumber'] as String?,
      grade: json['grade'] as int? ?? 0,
      observation: json['observation'] as String?,
      pdfUrl: json['pdfUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'courseId': courseId,
        'workerNumber': workerNumber,
        'grade': grade,
        'observation': observation,
        'pdfUrl': pdfUrl,
      };
}