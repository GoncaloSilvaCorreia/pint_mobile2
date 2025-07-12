import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static const String baseUrl = 'https://pint2.onrender.com/api';

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
        final responseBody = json.decode(response.body);

        if (responseBody['success'] == true) {
          return responseBody;
        } else {
          throw Exception(responseBody['message']);
        }
      } else {
        throw Exception('Erro inesperado ao tentar resetar a senha');
      }
    } catch (e) {
      throw Exception('Erro de rede: $e');
    }
  }

  Future<Map<String, dynamic>> sendContactForm(
    String workerNumber,
    String name,
    String email,
    String subject,
    String message,
  ) async {
    final Uri url = Uri.parse('$baseUrl/requests/create');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'workerNumber': workerNumber,
        'name': name,
        'email': email,
        'subject': subject,
        'message': message,
      }),
    );

    final responseBody = json.decode(response.body);
    
    return responseBody;
  }
}