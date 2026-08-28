import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  // Use 10.0.2.2 for Android Emulator connecting to localhost
  // Or your local IP address for real devices (e.g. 192.168.1.5)
  // Read URL exclusively from .env for better security
  static String get baseUrl {
    final url = dotenv.env['API_BASE_URL'];
    if (url == null) throw Exception('API_BASE_URL not found in .env');
    return url;
  }
  
  static const String login = '/login';
  static const String riceStock = '/rice';
  static const String plantStock = '/plant';
  static const String production = '/production';
  static const String shopSales = '/shopsales';
  static const String otherSales = '/othersales';
  static const String expense = '/expense';
  static const String revenue = '/revenue';
}
