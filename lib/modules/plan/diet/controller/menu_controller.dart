import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fyp/shared/models/meal_model.dart';
import 'package:fyp/modules/global_import.dart';

class menuController {
  Future<List<Meal>> getMealPlan(String userId) async {
    final response = await http.get(
      Uri.parse('http://$activeIP/get_meal_plan.php?user_id=$userId'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        return (data['data'] as List)
            .map((meal) => Meal.fromJson(meal))
            .toList();
      } else {
        throw Exception(data['message']);
      }
    } else {
      throw Exception('Failed to load meal plan');
    }
  }
}
