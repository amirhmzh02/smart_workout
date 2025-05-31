class Meal {
  final int id;
  final String mealType;
  final String mealname;
  final List<String> ingredients;
  final List<int> ingredientsid;
  final List<double> quantities;
  final int calories;

  Meal({
    required this.id,
    required this.mealType,
    required this.mealname,
    required this.ingredients,
    required this.ingredientsid,
    required this.quantities,
    required this.calories,
  });



  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['meal_id'],
      mealType: json['meal_type'],
      mealname: json['name'],
      ingredients: List<String>.from(json['ingredients']),
      ingredientsid: List<int>.from(json['ingredients_id']),
      quantities: List<double>.from(
        json['quantities']?.map((q) => q.toDouble()) ?? [],
      ),
      calories: json['calories'],
    );
  }
}


