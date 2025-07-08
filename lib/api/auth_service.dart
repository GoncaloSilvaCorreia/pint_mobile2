import 'dart:convert';
import 'package:pint_mobile/models/utilizador.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  /// Faz login do utilizador, guarda o token e o workerNumber no SharedPreferences,
  /// e devolve um objeto Utilizador.
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
      await prefs.setInt('userId', data['user']['id']);

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

  /// Faz logout, removendo token e workerNumber do SharedPreferences.
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('workerNumber');
  }

  /// Retorna o token guardado no SharedPreferences.
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// Retorna o workerNumber guardado no SharedPreferences.
  Future<String?> getWorkerNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('workerNumber');
  }

  Future<Map<String, dynamic>> resetPassword(String email) {
    return _apiClient.resetPassword(email);
  }
}
