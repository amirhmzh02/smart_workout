class Ingredient {
  final int id;
  final String name;
  final int calories;

  Ingredient({
    required this.id,
    required this.name,
    required this.calories,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: json['ingredient_id'] ?? 0,
      name: json['ingredient_name'] ?? '',
      calories: json['calories'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ingredient_id': id,
      'ingredient_name': name,
      'calories': calories,
    };
  }
}
