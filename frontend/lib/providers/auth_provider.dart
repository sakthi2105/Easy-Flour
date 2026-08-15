import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  bool _isLoading = false;
  String? _error;

  String? get token => _token;
  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final Dio _dio = Dio();

  AuthProvider() {
    loadToken();
  }

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _dio.post(
        '${ApiConstants.baseUrl}${ApiConstants.login}',
        data: {'email': email, 'password': password.trim()},
      );

      if (response.statusCode == 200) {
        _token = response.data['token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on DioException catch (e) {
      print('DioError in login: ${e.message}, ${e.response?.data}');
      _error = e.response?.data['message'] ?? 'Login failed';
    } catch (e) {
      print('Unknown error in login: $e');
      _error = 'An unexpected error occurred';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _dio.post(
        '${ApiConstants.baseUrl}/register',
        data: {'name': name, 'email': email, 'password': password.trim()},
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        _token = response.data['token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on DioException catch (e) {
      print('DioError in register: ${e.message}, ${e.response?.data}');
      _error = e.response?.data['message'] ?? 'Registration failed';
    } catch (e) {
      print('Unknown error in register: $e');
      _error = 'An unexpected error occurred';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    notifyListeners();
  }
}
