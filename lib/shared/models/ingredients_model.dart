class Ingredient {
  final int id;
  final String name;
  final int calories; // per 100g
  double quantity; // in grams

  Ingredient({
    required this.id,
    required this.name,
    required this.calories,
    this.quantity = 100.0, // Default to 100g
  });

  // Helper method to calculate actual calories
  double get calculatedCalories => (calories * quantity) / 100;

  // For JSON serialization
  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['ingredient_id'] ?? 0,
      name: json['ingredient_name'] ?? '',
      calories: json['calories'] ?? 0,
      quantity: (json['quantity'] ?? 100.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ingredient_id': id,
      'ingredient_name': name,
      'calories': calories,
      'quantity': quantity,
    };
  }
}