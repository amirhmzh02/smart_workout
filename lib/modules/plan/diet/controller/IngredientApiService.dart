import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fyp/shared/models/ingredients_model.dart';
import 'package:fyp/modules/global_import.dart';

class IngredientApiService {
  final String baseUrl;

  IngredientApiService(
      {this.baseUrl = 'http://$activeIP/search_ingredients.php'});

  Future<List<Ingredient>> searchIngredients(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl?search=$query'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List)
              .map((ingredient) => Ingredient.fromJson(ingredient))
              .toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to load ingredients');
        }
      } else {
        throw Exception('Failed to load ingredients: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to search ingredients: $e');
    }
  }
}
