// workout_controller.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fyp/modules/global_import.dart';

class WorkoutController {
  static const String apiUrl = 'http://$activeIP/workout_done.php';
  static final _storage = FlutterSecureStorage();

  static Future<void> sendWorkoutDone(List<Map<String, dynamic>> exercises) async {
    final userId = await _storage.read(key: 'userId');
    if (userId == null) return;

    final today = DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD

    final payload = exercises.map((e) => {
      "user_id": userId,
      "exercise_id": e['id'],
      "sets": e['sets'],
      "reps": e['reps'],
      "date": today,
    }).toList();

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'data': payload}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Workout logged: ${data['message']}');
      } else {
        print('Failed to log workout');
      }
    } catch (e) {
      print('Error sending workout: $e');
    }
  }
}
