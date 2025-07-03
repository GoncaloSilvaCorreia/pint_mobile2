class Enrollment {
  final int id;
  final int courseId;
  final String workerNumber;
  final DateTime enrollmentDate;
  final String status;
  final double? rating;

  Enrollment({
    required this.id,
    required this.courseId,
    required this.workerNumber,
    required this.enrollmentDate,
    required this.status,
    this.rating,
  });

  factory Enrollment.fromJson(Map<String, dynamic> json) {
    return Enrollment(
      id: json['id'] as int? ?? 0,
      courseId: json['courseId'] as int? ?? json['id_curso'] as int? ?? 0,
      workerNumber: json['workerNumber'] as String? ?? json['n_trabalhador'] as String? ?? '',
      enrollmentDate: DateTime.parse(json['enrollmentDate'] as String? ?? DateTime.now().toIso8601String()),
      status: json['status'] as String? ?? 'Pendente',
      rating: json['rating'] != null ? double.parse(json['rating'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'courseId': courseId,
        'workerNumber': workerNumber,
        'enrollmentDate': enrollmentDate.toIso8601String(),
        'status': status,
        'rating': rating,
      };
}