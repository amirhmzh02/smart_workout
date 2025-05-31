import 'meal_model.dart';

class Diary {
  final List<Meal> meals;

  Diary({required this.meals});

factory Diary.fromJson(Map<String, dynamic> json) {
  final rawMeals = json['meals'] as List;

  List<Meal> parsedMeals = rawMeals.map((mealJson) {
    mealJson['meal_id'] ??= 0;
    mealJson['meal_type'] ??= '';
    mealJson['meal_name'] ??= '';
    mealJson['calories'] ??= 0;

    // Normalize to match Meal.fromJson
    mealJson['name'] = mealJson['meal_name']; 

    // Ingredients
    final ingredientsRaw = mealJson['ingredients'];
    mealJson['ingredients'] = ingredientsRaw is String
        ? ingredientsRaw.split(',').map((e) => e.trim()).toList()
        : (ingredientsRaw ?? <String>[]);

    // Ingredients ID
    final ingredientsIdRaw = mealJson['ingredients_id'];
    mealJson['ingredients_id'] = ingredientsIdRaw is String
        ? ingredientsIdRaw
            .split(',')
            .map((e) => int.tryParse(e.trim()) ?? 0)
            .toList()
        : (ingredientsIdRaw ?? <int>[]);

    // Quantities
    final quantitiesRaw = mealJson['quantities'];
    mealJson['quantities'] = quantitiesRaw is String
        ? quantitiesRaw
            .split(',')
            .map((e) => double.tryParse(e.trim()) ?? 0.0)
            .toList()
        : (quantitiesRaw ?? <double>[]);

    return Meal.fromJson(mealJson);
  }).toList();

  return Diary(meals: parsedMeals);
}

}
