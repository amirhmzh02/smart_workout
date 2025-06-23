import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fyp/modules/global_import.dart';

class WorkoutService {
  static const String _baseUrl = 'http://$activeIP/user_workout_stats.php';
  static const _storage = FlutterSecureStorage();

  static Future<Map<String, dynamic>?> getMonthlyStats() async {
    try {
      final userId = await _storage.read(key: 'userId');
      if (userId == null) return null;

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'user_id': userId}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}