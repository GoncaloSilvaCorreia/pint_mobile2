import 'dart:convert';
import 'package:pint_mobile/models/utilizador.dart';
import 'package:pint_mobile/api/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pint_mobile/models/certificados.dart';

class ApiUtilizador {
  final ApiClient _apiClient = ApiClient();

  Future<Utilizador> getUtilizadorByWorkerNumber(String workerNumber) async {
    final response = await _apiClient.get('/users/id/$workerNumber');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      
      final userData = data['user'] as Map<String, dynamic>;
      final combinedData = {
        ...userData,
        'interests': data['interests'],
        'token': token,  // adiciona o token
      };
      
      return Utilizador.fromJson(combinedData);
    } else {
      throw Exception('Erro ao carregar utilizador');
    }
  }

  Future<List<Map<String, dynamic>>> getCursosByWorkerNumber(String workerNumber) async {
    final response = await _apiClient.get('/users/id/$workerNumber');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      List cursos = (data['courses'] ?? []) as List;
      return cursos.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Erro ao carregar cursos');
    }
  }

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

  Future<Utilizador?> getUtilizadorLogado() async {
    final prefs = await SharedPreferences.getInstance();
    final workerNumber = prefs.getString('workerNumber');
    if (workerNumber != null) {
      return await getUtilizadorByWorkerNumber(workerNumber);
    }
    return null;
  }

  Future<List<Certificate>> getCertificadosByWorkerNumber(String workerNumber) async {
    final response = await _apiClient.get('/users/id/$workerNumber');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
     
      List certificates = (data['certificates'] ?? []) as List;
      return certificates.map<Certificate>((json) => Certificate.fromJson(json)).toList();
    } else {
      throw Exception('Erro ao carregar certificados');
    }
  }
}