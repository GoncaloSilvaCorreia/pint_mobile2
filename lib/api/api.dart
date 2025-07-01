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
}