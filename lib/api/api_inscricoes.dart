import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pint_mobile/models/curso.dart';
import 'package:pint_mobile/models/inscricoes.dart';

class EnrollmentService {
  final String baseUrl = 'https://pint-13nr.onrender.com/api'; 

  Future<List<Enrollment>> getEnrollments() async {
    final response = await http.get(Uri.parse('$baseUrl/inscricoes'));

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

  Future<Enrollment> createEnrollment(int courseId, String workerNumber) async {
    final response = await http.post(
      Uri.parse('$baseUrl/inscricoes/create'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id_curso': courseId,
        'n_trabalhador': workerNumber,
      }),
    );

    if (response.statusCode == 201) {
      try {
        // Tentar decodificar a resposta apenas se o corpo não estiver vazio
        if (response.body.isNotEmpty) {
          final data = jsonDecode(response.body);
          return Enrollment.fromJson(data);
        } else {
          // Se a resposta estiver vazia, criar um objeto Enrollment manualmente
          return Enrollment(
            id: 0, // ID temporário
            courseId: courseId,
            workerNumber: workerNumber,
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
            ),
          );
        }
      } catch (e) {
        throw Exception('Resposta inválida do servidor: $e');
        }
    } else {
      String errorMessage = 'Falha ao criar inscrição';
      if (response.body.isNotEmpty) {
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['error'] ?? errorMessage;
        } catch (_) {
          errorMessage = response.body;
        }
      }
      throw Exception(errorMessage);
    }
  }
}