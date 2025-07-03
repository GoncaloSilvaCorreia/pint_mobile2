import 'dart:convert';
import 'package:pint_mobile/models/utilizador.dart';
import 'package:pint_mobile/api/api.dart'; // Importa ApiClient
import 'package:shared_preferences/shared_preferences.dart';

class ApiUtilizador {
  final ApiClient _apiClient = ApiClient();

  /// Busca os dados completos do utilizador pelo workerNumber.
  Future<Utilizador> getUtilizadorByWorkerNumber(String workerNumber) async {
    final response = await _apiClient.get('/users/id/$workerNumber');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Utilizador.fromJson(data['user']);
    } else {
      throw Exception('Erro ao carregar utilizador');
    }
  }

  /// Retorna a lista de cursos do utilizador pelo workerNumber.
  Future<List<Map<String, dynamic>>> getCursosByWorkerNumber(String workerNumber) async {
    final response = await _apiClient.get('/users/id/$workerNumber');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List cursos = data['courses'];
      return cursos.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Erro ao carregar cursos');
    }
  }

  /// Retorna a lista de interesses do utilizador pelo workerNumber.
  Future<List<Map<String, dynamic>>> getInteressesByWorkerNumber(String workerNumber) async {
    final response = await _apiClient.get('/users/id/$workerNumber');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List interesses = data['interests'];
      return interesses.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Erro ao carregar interesses');
    }
  }

  /// Busca o utilizador logado diretamente do SharedPreferences.
  Future<Utilizador?> getUtilizadorLogado() async {
    final prefs = await SharedPreferences.getInstance();
    final workerNumber = prefs.getString('workerNumber');
    if (workerNumber != null) {
      return await getUtilizadorByWorkerNumber(workerNumber);
    }
    return null;
  }
}