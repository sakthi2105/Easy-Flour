class ApiConstants {
  // Use 10.0.2.2 for Android Emulator connecting to localhost
  // Or your local IP address for real devices (e.g. 192.168.1.5)
  static const String baseUrl = 'http://10.0.2.2:5000/api';
  
  static const String login = '/login';
  static const String riceStock = '/rice';
  static const String plantStock = '/plant';
  static const String production = '/production';
  static const String shopSales = '/shopsales';
  static const String otherSales = '/othersales';
  static const String expense = '/expense';
  static const String revenue = '/revenue';
}
