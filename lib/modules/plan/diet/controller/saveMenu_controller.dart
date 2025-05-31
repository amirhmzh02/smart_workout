import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fyp/shared/models/meal_model.dart';
import 'package:fyp/modules/global_import.dart';

class saveMenuController {
  final String apiUrl = 'http://$activeIP/save_diary.php';

  Future<void> submitSelectedMeals(
      String userId, List<Meal> selectedMeals) async {
    try {
      List<Map<String, dynamic>> diaryEntries = [];

      for (var meal in selectedMeals) {
        if (meal.ingredients.length != meal.quantities.length) {
          debugPrint(
              "Skipping meal '${meal.mealname}' due to ingredient-quantity mismatch.");
          continue;
        }

        final ingredientsString = List.generate(
          meal.ingredients.length,
          (i) =>
              '${meal.quantities[i].toStringAsFixed(0)}g ${meal.ingredients[i]}',
        ).join(', ');

        // final calories = int.tryParse(meal.calories) ?? 0;
              debugPrint(jsonEncode({'kcal in controller': meal.calories}));
              debugPrint(jsonEncode({'name in controller': meal.mealname}));


        diaryEntries.add({
          'user_id': userId,
          // 'meal_id': meal.id,
          'meal_type':meal.mealType,
          'meal_name':meal.mealname,
          'ingredients': ingredientsString,
          'calories': meal.calories,
          'date': DateTime.now().toIso8601String().split('T').first,
        });

        // if (calories == 0) {
        //   debugPrint("Warning: Calories is 0 for meal ${meal.name}");
        // }
      }

      debugPrint("Sending diary entries:");
      debugPrint(jsonEncode({'diary_entries': diaryEntries}));

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
