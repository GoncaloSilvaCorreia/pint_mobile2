import 'dart:convert';
import 'package:pint_mobile/models/topico.dart';
import 'api.dart';

class TopicService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Topic>> getTopics() async {
    final response = await _apiClient.get('/topicos');
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Topic.fromJson(item)).toList();
    } else {
      throw Exception('Falha ao carregar tópicos');
    }
  }
}