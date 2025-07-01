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
  }
}