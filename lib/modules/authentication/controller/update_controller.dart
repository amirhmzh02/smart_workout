import 'package:fyp/modules/global_import.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UpdatePasswordController {
  static const _apiUrl = 'http://$activeIP/update_password.php';

  /// Updates the user's password
  /// Returns a tuple: (success, message)
  Future<(bool, String)> updatePassword({
    required int userId,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      // Input validation
      if (oldPassword.isEmpty || newPassword.isEmpty) {
        return (false, 'Please fill all fields');
      }

      if (newPassword.length < 6) {
        return (false, 'Password must be at least 6 characters');
      }

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'old_password': oldPassword,
          'new_password': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return (true, data['message']?.toString() ?? 'Password updated successfully');
        } else {
          return (false, data['message']?.toString() ?? 'Update failed');
        }
      } else {
        return (false, 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      return (false, 'Connection error: ${e.toString()}');
    }
  }
}
