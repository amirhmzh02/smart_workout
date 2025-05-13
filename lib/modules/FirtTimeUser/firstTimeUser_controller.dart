import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fyp/modules/FirtTimeUser/result_screen.dart';
import 'package:fyp/modules/FirtTimeUser/model_bmiResult.dart';

class FirstTimeUserController {
  static const String _apiUrl = 'https://walkerz.pythonanywhere.com/bmi';

  static Future<BmiResult> submitUserData({
  required String name,
  required String age,
  required String weight,
  required String height,
  required String gender,
  required int activityLevel,
  String goal = 'loss',
}) async {
  try {
    final int genderValue = gender.toLowerCase() == 'male' ? 1 : 0;
    final int goalValue = goal.toLowerCase() == 'loss' ? -1 : goal.toLowerCase() == 'gain' ? 1 : 0;

    final Map<String, dynamic> body = {
      "weight": double.tryParse(weight) ?? 0,
      "height": double.tryParse(height) ?? 0,
      "age": int.tryParse(age) ?? 0,
      "gender": genderValue,
      "goal": goalValue,
      "activity_level": activityLevel,
    };

    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> result = jsonDecode(response.body);
      if (result['success'] == true) {
        return BmiResult.fromJson(result);
      } else {
        throw Exception("API error: ${result['message'] ?? 'Unknown error'}");
      }
    } else {
      throw Exception("HTTP ${response.statusCode}: ${response.body}");
    }
  } catch (e) {
    throw Exception("Failed to submit user data: $e");
  }
}

}
