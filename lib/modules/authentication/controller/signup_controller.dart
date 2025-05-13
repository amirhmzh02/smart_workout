import 'package:fyp/modules/global_import.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignUpController {
  static const _apiUrl = 'http://$activeIP/signup.php';

  Future<(bool success, String message)> signUp({
    required String email,
    required String password,
  }) async {
    try {
      // Input validation
      if (email.isEmpty || password.isEmpty) {
        return (false, 'Please fill all fields');
      }

      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        return (false, 'Invalid email format');
      }

      if (password.length < 6) {
        return (false, 'Password must be at least 6 characters');
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

      if (response.statusCode == 201 && data['success']) {
        return (true, data['message']?.toString() ?? 'Signup successful');
      } else {
        return (false, data['message']?.toString() ?? 'Signup failed');
      }
    } catch (e) {
      return (false, 'Connection error: ${e.toString()}');
    }
  }
}
