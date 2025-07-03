import 'dart:convert';
import 'package:pint_mobile/models/utilizador.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  Future<Utilizador> login(String email, String password) async {
    final response = await _apiClient.post(
      '/auth/login',
      body: {'email': email, 'password': password},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      // Salvar token no SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);

      // Salvar workerNumber no SharedPreferences
      await prefs.setString('workerNumber', data['user']['workerNumber']);

      // Retornar o utilizador logado com token incluído
      return Utilizador.fromJson({
        ...data['user'],
        'token': data['token'],
      });
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Falha no login');
    }
  }

  Future<String> getTrainerName(String trainerId) async {
    final response = await _apiClient.get('/users');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // data é uma lista de users
      final user = (data as List).firstWhere(
        (u) => u['workerNumber'] == trainerId,
        orElse: () => null,
      );
      if (user != null) {
        return user['name'] ?? 'Desconhecido';
      } else {
        return 'Desconhecido';
      }
    } else {
      throw Exception('Erro ao carregar formador');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('workerNumber'); // Remove também o workerNumber no logout
  }
}
