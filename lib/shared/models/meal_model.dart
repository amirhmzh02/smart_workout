class Meal {
  final int id;
  final String mealType;
  final String name;
  final List<String> ingredients;
  final List<int> ingredientsid;
  final String calories;

  Meal({
    required this.id,
    required this.mealType,
    required this.name,
    required this.ingredients,
    required this.ingredientsid,
    required this.calories,
  });

 factory Meal.fromJson(Map<String, dynamic> json) {
  return Meal(
    id: json['meal_id'],
    mealType: json['meal_type'],
    name: json['name'],
    ingredients: List<String>.from(json['ingredients']),
    ingredientsid: List<int>.from(json['ingredients_id']),
    calories: json['calories'],
  );
}


  
}
