import 'package:flutter/material.dart';
import 'package:fyp/modules/global_import.dart';
import 'package:fyp/shared/models/meal_model.dart';

class MealCard extends StatelessWidget {
  final Meal meal;
  
  const MealCard({
    super.key,
    required this.meal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.lightbackground,
        borderRadius: BorderRadius.circular(12),
        
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  meal.mealType.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppFonts.primary,
                  ),
                ),
                Text(
                  meal.calories,
                  style: const TextStyle(
                    color: AppColors.pink,
                    fontSize: 16,
                    fontFamily: AppFonts.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              meal.name,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: AppFonts.secondary,
              ),
            ),
            const SizedBox(height: 8),
            // Bullet point list of ingredients (now using List<String> directly)
            ...meal.ingredients.map((ingredient) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(right: 8, top: 2),
                    child: Text(
                      '•',
                      style: TextStyle(
                        color: AppColors.pink,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      ingredient.trim(),
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 14,
                        fontFamily: AppFonts.secondary,
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }
}