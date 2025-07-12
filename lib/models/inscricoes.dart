import 'package:pint_mobile/models/curso.dart';

class Enrollment {
  final int id;
  final int courseId;
  final int userId;
  final DateTime enrollmentDate;
  final String status;
  final double? rating;
  final Course course;

  Enrollment({
    required this.id,
    required this.courseId,
    required this.userId,
    required this.enrollmentDate,
    required this.status,
    this.rating,
    required this.course,
  });

  factory Enrollment.fromJson(Map<String, dynamic> json) {
    return Enrollment(
      id: json['id'] as int? ?? 0,
      courseId: json['courseId'] as int? ?? json['id_curso'] as int? ?? 0,
      userId: json['userId'] as int? ?? json['id_utilizador'] as int? ?? 0,
      enrollmentDate: DateTime.parse(json['enrollmentDate'] as String? ?? DateTime.now().toIso8601String()),
      status: json['status'] as String? ?? 'Pendente',
      rating: json['rating'] != null ? double.parse(json['rating'].toString()) : null,
      course: Course.fromJson(json['course']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'courseId': courseId,
        'id_utilizador': userId,
        'enrollmentDate': enrollmentDate.toIso8601String(),
        'status': status,
        'rating': rating,
        'course': course.toJson(),
      };
}