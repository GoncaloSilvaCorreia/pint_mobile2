import 'dart:convert';
import 'package:pint_mobile/api/api.dart';
import 'package:pint_mobile/models/curso.dart';

class CourseService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Course>> getCoursesByTopic(int topicId) async {
    final response = await _apiClient.get('/cursos?topicId=$topicId');
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => Course.fromJson(item)).toList();
    } else {
      throw Exception('Falha ao carregar cursos');
    }
  }

  Future<List<Course>> getAllVisibleCourses() async {
    final response = await _apiClient.get('/cursos');
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => Course.fromJson(item))
                 .where((course) => course.visible)
                 .toList();
    } else {
      throw Exception('Falha ao carregar cursos');
    }
  }
}