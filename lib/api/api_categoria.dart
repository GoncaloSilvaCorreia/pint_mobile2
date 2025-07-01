import 'dart:convert';
import 'package:pint_mobile/models/categoria.dart';
import 'api.dart';

class CategoryService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Category>> getCategories() async {
    final response = await _apiClient.get('/categorias');
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((dynamic item) => Category.fromJson(item)).toList();
    } else {
      throw Exception('Falha ao carregar categorias');
    }
  }
}