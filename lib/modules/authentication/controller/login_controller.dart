import 'package:fyp/modules/global_import.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// import 'package:crypto/crypto.dart';

class LoginController {
  
  static const _storage = FlutterSecureStorage();
  static const _apiUrl =
      'http://192.168.0.26/Bolt-API/login.php'; // Special IP for Android emulator

  Future<(bool success, String message)> login({
    required String email,
    required String password,
  }) async {
         print("di controller");

    try {
      // Input validation
      if (email.isEmpty || password.isEmpty) {
        return (false, 'Please fill all fields');
      }

      final response = await http.post(
        Uri.parse(_apiUrl),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        await _storage.write(key: 'userId', value: data['user_id'].toString());
        await _storage.write(
            key: 'authToken', value: data['token']); // If using tokens
        return (true, 'Login successful');
      } else {
        return (false, data['message']?.toString() ?? 'Login failed');
      }
    } catch (e) {
      return (false, 'Connection error: ${e.toString()}');
    }
  }

  static Future<void> logout() async {
    await _storage.deleteAll(); // Clear all stored data
  }

  static Future<String?> getUserId() async {
    return await _storage.read(key: 'userId');
  }
}
