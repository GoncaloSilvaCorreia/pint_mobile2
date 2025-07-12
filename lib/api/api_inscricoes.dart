import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pint_mobile/models/curso.dart';
import 'package:pint_mobile/models/inscricoes.dart';

class EnrollmentService {
  final String baseUrl = 'https://pint2.onrender.com/api'; 

  Future<List<Enrollment>> getEnrollments() async {
    final response = await http.get(Uri.parse('$baseUrl/enrollments'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Enrollment.fromJson(e)).toList();
    } else {
      throw Exception('Erro ao carregar inscrições');
    }
  }

  Future<Enrollment?> getEnrollmentForCourseAndUser(int courseId, int userId) async {
    final enrollments = await getEnrollments();

    try {
      return enrollments.firstWhere(
        (e) => e.courseId == courseId && e.userId == userId,
      );
    } catch (_) {
      return null; // não inscrito
    }
  }

  Future<Enrollment> createEnrollment(int courseId, int userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/enrollments/create'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'courseId': courseId,
        'userId': userId,
      }),
    );

    if (response.statusCode == 201) {
      try {
        final data = jsonDecode(response.body);
        return Enrollment.fromJson(data);
      } catch (e) {
        return Enrollment(
          id: 0,
          courseId: courseId,
          userId: userId,
          enrollmentDate: DateTime.now(),
          status: "Pendente",
          rating: null,
          course: Course(
            id: courseId,
            title: "",
            type: false,
            description: "",
            instructor: "",
            createdAt: DateTime.now(),
            status: false,
            visible: false,
            topicId: 0,
            level: "",
            startDate: DateTime.now(),
            endDate: DateTime.now(),
            enrollmentsOpen: false,
            sections: [],
          ),
        );
      }
    } else {
      String errorMessage = 'Falha ao criar inscrição';
      if (response.body.isNotEmpty) {
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['error'] ?? errorData['message'] ?? errorMessage;
        } catch (_) {
          errorMessage = response.body;
        }
      }
      throw Exception(errorMessage);
    }
  }
}