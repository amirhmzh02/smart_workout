import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fyp/shared/models/meal_model.dart';
import 'package:fyp/modules/global_import.dart';

class saveMenuController {
  final String apiUrl = 'http://$activeIP/save_diary.php'; 

  Future<void> submitSelectedMeals(String userId, List<Meal> selectedMeals) async {
    try {
      List<Map<String, dynamic>> diaryEntries = [];

      for (var meal in selectedMeals) {
        for (var ingredientId in meal.ingredientsid) {
          diaryEntries.add({
            'user_id': userId,
            'meal_id': meal.id,
            'ingredient_id': ingredientId,
            'date': DateTime.now().toIso8601String().split('T').first,
          });
        }
      }

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'diary_entries': diaryEntries}),
      );

      if (response.statusCode == 200) {
        print('Diary entries submitted successfully');
        print('Response: ${response.body}');
      } else {
        print('Failed to submit diary entries. Status: ${response.statusCode}');
        print('Body: ${response.body}');
      }
    } catch (e) {
      print('Error submitting diary entries: $e');
    }
  }
}
