class Meal {
  final int id;
  final String mealType;
  final String name;
  final List<String> ingredients;
  final List<int> ingredientsid;
  final List<double> quantities;
  final String calories;

  Meal({
    required this.id,
    required this.mealType,
    required this.name,
    required this.ingredients,
    required this.ingredientsid,
    required this.quantities,
    required this.calories,
  });

  // int get calorie {
  //   return int.tryParse(calories.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  // }

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['meal_id'],
      mealType: json['meal_type'],
      name: json['name'],
      ingredients: List<String>.from(json['ingredients']),
      ingredientsid: List<int>.from(json['ingredients_id']),
      quantities: List<double>.from(
        json['quantities']?.map((q) => q.toDouble()) ?? [],
      ),
      calories: json['calories'],
    );
  }
}
