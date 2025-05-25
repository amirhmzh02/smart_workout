import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fyp/modules/global_import.dart';

class CreateMenuController {
  Future<bool> saveMeal(Map<String, dynamic> mealData) async {
    final url = Uri.parse('http://$activeIP/save_meal.php');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(mealData),
      );
      print('API response code: ${response.statusCode}');
      print('API response body: ${response.body}');

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return result['success'] == true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error saving meal: $e');
      return false;
    }
  }
}
