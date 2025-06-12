import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fyp/modules/global_import.dart';
import 'package:fyp/modules/plan/exercise/screen/workoutSetup_screen.dart';

class WorkoutSetupController {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<bool> saveWorkoutPlan({
    required int daysPerWeek,
    required List<String> equipmentList,
  }) async {
    final userId = await _storage.read(key: 'userId');
    if (userId == null) throw Exception('User ID not found');

    try {
      final response = await http.post(
        Uri.parse('http://$activeIP/save_workout_plan.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'days_per_week': daysPerWeek,
          'equipment_have': equipmentList,
        }),
      );

      final data = jsonDecode(response.body);
      return data['success'] == true;
    } catch (e) {
      throw Exception('Failed to save workout plan: $e');
    }
  }

  Future<Map<String, dynamic>> getWorkoutPlan() async {
    final userId = await _storage.read(key: 'userId');
    if (userId == null) throw Exception('User ID not found');

    try {
      final response = await http.get(
        Uri.parse('http://$activeIP/get_workout_plan.php?user_id=$userId'),
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return {
          'days_per_week': data['data']['day_per_week'],
          'equipment_have':
              List<String>.from(jsonDecode(data['data']['equipment_have'])),
        };
      } else {
        throw Exception('No workout plan found');
      }
    } catch (e) {
      throw Exception('Failed to fetch workout plan: $e');
    }
  }

  static Future<int> checkUser(BuildContext context) async {
    final FlutterSecureStorage _storage = const FlutterSecureStorage();
    final userId = await _storage.read(key: 'userId');

    if (userId == null) throw Exception('User ID not found');

    try {
      final response = await http.post(
        Uri.parse('http://$activeIP/check_workout_plan.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId}),
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true && data['hasPlan'] == true) {
        return 1;
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const WorkoutSetupScreen(),
          ),
        );
        return 0;
      }
    } catch (e) {
      throw Exception('Failed to check workout plan: $e');
    }
  }
}
