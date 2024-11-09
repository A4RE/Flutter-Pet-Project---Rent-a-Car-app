import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NetworkService {
  final String baseUrl = 'http://localhost:8080';
  String? _cachedSessionId;

  // Получение sessionId с кэшированием для оптимизации
  Future<String?> _getSessionId() async {
    if (_cachedSessionId == null) {
      final prefs = await SharedPreferences.getInstance();
      _cachedSessionId = prefs.getString('sessionId');
    }
    return _cachedSessionId;
  }

  Future<Map<String, dynamic>> autoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    final password = prefs.getString('password');

    if (email != null && password != null) {
      return await login(email, password);
    } else {
      return {'success': false, 'error': 'No saved credentials'};
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final cookies = response.headers['set-cookie'];
        final sessionId = _extractSessionId(cookies);
        if (sessionId != null) {
          await _saveSessionData(sessionId, email, password); // Сохраняем данные
        }

        final responseData = jsonDecode(response.body);

        return {
          'success': true,
          'message': responseData['message'],
          'userId': responseData['userId'],
          'fullName': responseData['fullName'],
          'sessionId': sessionId,
        };
      } else {
        return _handleErrorResponse(response);
      }
    } catch (e) {
      return {'success': false, 'error': 'Something went wrong. Please try again later.'};
    }
  }

  String? _extractSessionId(String? cookies) {
    if (cookies == null) return null;
    return cookies.split(';').firstWhere((part) => part.trim().startsWith('sessionId=')).split('=')[1];
  }

  Future<void> _saveSessionData(String sessionId, String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    _cachedSessionId = sessionId; // Кэшируем sessionId
    await prefs.setString('sessionId', sessionId);
    await prefs.setString('email', email);
    await prefs.setString('password', password);
  }

  Future<Map<String, dynamic>> register(String fullName, String email, String password, String confirmPassword) async {
    final url = Uri.parse('$baseUrl/register');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'fullName': fullName,
          'email': email,
          'password': password,
          'confirmPassword': confirmPassword,
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'message': responseData['message'],
          'userId': responseData['userId'],
        };
      } else {
        return _handleErrorResponse(response);
      }
    } catch (e) {
      return {'success': false, 'error': 'Something went wrong. Please try again later.'};
    }
  }

  Future<List<Map<String, dynamic>>> getPopularCars() async {
    return _getWithSession('$baseUrl/cars/popular');
  }

  Future<List<Map<String, dynamic>>> getAllCars() async {
    return _getWithSession('$baseUrl/cars');
  }

  Future<List<Map<String, dynamic>>> getPromotions() async {
    return _getWithSession('$baseUrl/promotions');
  }

  Future<List<Map<String, dynamic>>> _getWithSession(String url) async {
    final sessionId = await _getSessionId();
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (sessionId != null) 'Cookie': 'sessionId=$sessionId',
        },
      );

      if (response.statusCode == 200) {
        return (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Map<String, dynamic> _handleErrorResponse(http.Response response) {
    final errorData = jsonDecode(response.body);
    return {'success': false, 'error': errorData['error'] ?? 'Request failed'};
  }
}
