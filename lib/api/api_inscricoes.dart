import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pint_mobile/models/inscricoes.dart';

class EnrollmentService {
  final String baseUrl = 'https://pint-13nr.onrender.com/api'; // muda conforme necessário

  Future<List<Enrollment>> getEnrollments() async {
    final response = await http.get(Uri.parse('$baseUrl/enrollments'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Enrollment.fromJson(e)).toList();
    } else {
      throw Exception('Erro ao carregar inscrições');
    }
  }

  Future<Enrollment?> getEnrollmentForCourseAndUser(int courseId, String workerNumber) async {
    final enrollments = await getEnrollments();

    try {
      return enrollments.firstWhere(
        (e) => e.courseId == courseId && e.workerNumber == workerNumber,
      );
    } catch (_) {
      return null; // não inscrito
    }
  }
}
