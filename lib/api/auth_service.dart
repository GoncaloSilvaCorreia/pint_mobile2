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
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);

      await prefs.setString('workerNumber', data['user']['workerNumber']);
      await prefs.setInt('userId', data['user']['id']);

      return Utilizador.fromJson({
        ...data['user'],
        'token': data['token'],
      });
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Falha no login');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('workerNumber');
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<String?> getWorkerNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('workerNumber');
  }

  Future<Map<String, dynamic>> resetPassword(String email) {
    return _apiClient.resetPassword(email);
  }
}
