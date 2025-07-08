import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static const String baseUrl = 'https://pint-13nr.onrender.com/api';

  Future<Map<String, String>> getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return http.get(url, headers: await getHeaders());
  }

  Future<http.Response> post(String endpoint, {Object? body}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return http.post(
      url,
      headers: await getHeaders(),
      body: body != null ? jsonEncode(body) : null,
    );
  }

  Future<http.Response> put(String endpoint, {Object? body}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return http.put(
      url,
      headers: await getHeaders(),
      body: body != null ? jsonEncode(body) : null,
    );
  }

  Future<http.Response> delete(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return http.delete(url, headers: await getHeaders());
  }

  Future<Map<String, dynamic>> resetPassword(String email) async {
    final Uri url = Uri.parse('$baseUrl/users/password-reset-request');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception('Erro na resposta: ${errorData['message']}');
      }
    } catch (e) {
      print('Erro ao solicitar reset de senha: $e'); // Adicionando log para erro
      throw Exception('Erro de rede: $e');
    }
  }

  Future<Map<String, dynamic>> sendContactForm(
    String workerNumber,
    String fullName,
    String email,
    String subject,
    String message,
  ) async {
    final Uri url = Uri.parse('$baseUrl/requests/create');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'workerNumber': workerNumber,
          'fullName': fullName,
          'email': email,
          'subject': subject,
          'message': message,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erro ao enviar o formulário: ${response.body}');
      }
    } catch (e) {
      throw Exception('Erro de rede: $e');
    }
  }
}