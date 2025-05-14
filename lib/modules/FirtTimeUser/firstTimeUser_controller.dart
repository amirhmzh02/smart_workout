import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fyp/modules/global_import.dart';
import 'package:fyp/shared/models/model_bmiResult.dart';

class FirstTimeUserController {
  static const String _apiUrl = 'https://walkerz.pythonanywhere.com/bmi';

  static Future<BmiResult> submitUserData({
    required String name,
    required String age,
    required String weight,
    required String height,
    required String gender,
    required String minCalories,
    required String maxCalories,
    required int activityLevel,
    String goal = 'loss',
  }) async {
    try {
      final storage = FlutterSecureStorage();
      final String? userId = await storage.read(key: 'userId');
      if (userId == null)
        throw Exception("User ID not found in secure storage");

      final int genderValue = gender.toLowerCase() == 'male' ? 1 : 0;

      // PythonAnywhere request body
      final Map<String, dynamic> pythonAnywhereBody = {
        "weight": double.tryParse(weight) ?? 0,
        "height": double.tryParse(height) ?? 0,
        "age": int.tryParse(age) ?? 0,
        "gender": genderValue,
        "goal": goal.toLowerCase() == 'loss'
            ? -1
            : goal.toLowerCase() == 'gain'
                ? 1
                : 0,
        "activity_level": activityLevel,
      };

      // Call PythonAnywhere API
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(pythonAnywhereBody),
      );

      if (response.statusCode != 200) {
        throw Exception("HTTP ${response.statusCode}: ${response.body}");
      }

      final Map<String, dynamic> result = jsonDecode(response.body);
      if (result['success'] != true) {
        throw Exception(
            "PythonAnywhere error: ${result['message'] ?? 'Unknown error'}");
      }

      // Extract the recommended goal from PythonAnywhere response
      final String recommendedGoal = result['metrics']['goal'] ?? goal;
      final List<dynamic> calorieRange = result['calories']['range'];
      final String minCalories = calorieRange[0].toString();
      final String maxCalories = calorieRange[1].toString();

      // Now include recommended goal in local API body
      final Map<String, dynamic> localApiBody = {
        "user_id": userId,
        "name": name,
        "age": age,
        "weight": weight,
        "height": height,
        "gender": gender,
        "fitness_goal": recommendedGoal, // Use the updated goal value
        "min_calories": minCalories,
        "max_calories": maxCalories,
      };

      // Call local PHP API (10.0.2.2 if using Android emulator)
      final secResponse = await http.post(
        Uri.parse('http://$activeIP/sent_userInfo.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(localApiBody),
      );

      final secResult = jsonDecode(secResponse.body);
      if (secResult['success'] != true) {
        throw Exception("Local API error: ${secResult['message']}");
      }

      // Return BmiResult
      return BmiResult.fromJson(result);
    } catch (e) {
      throw Exception("Failed to submit user data: $e");
    }
  }
}
