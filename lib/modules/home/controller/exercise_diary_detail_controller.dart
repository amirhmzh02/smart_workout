import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fyp/modules/global_import.dart';
import 'package:fyp/shared/models/WorkoutEntry.dart';

class ExerciseDiaryController {
  final String baseUrl = "http://$activeIP/get_workout_by_date.php"; // Adjust if needed

  Future<List<WorkoutEntry>> fetchWorkoutEntries({
  required String userId,
  required String date,
}) async {
  try {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"}, // Important!
      body: jsonEncode({
        'user_id': userId,
        'date': date,
      }),
    );

    print('userid ; $userId');
    print('date ; $date');
    print('this is the body: ${response.body}');

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);

      if (decoded['success'] == true && decoded['data'] != null) {
        final List<dynamic> jsonData = decoded['data'];
        return jsonData.map((item) => WorkoutEntry.fromJson(item)).toList();
      } else {
        return [];
      }
    } else {
      throw Exception('Failed to load workout data. Status: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error fetching workout entries: $e');
  }
}

}
