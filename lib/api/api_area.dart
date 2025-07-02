import 'dart:convert';
import 'package:pint_mobile/api/api.dart';
import 'package:pint_mobile/models/area.dart';

class AreaService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Area>> getAreas() async {
    final response = await _apiClient.get('/areas');
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => Area.fromJson(item)).toList();
    } else {
      throw Exception('Falha ao carregar áreas');
    }
  }
}