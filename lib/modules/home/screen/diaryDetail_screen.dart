import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fyp/modules/global_import.dart';
import 'package:fyp/shared/models/meal_model.dart';
import 'package:fyp/modules/home/controller/diary_controller.dart';

class DiaryDetailScreen extends StatefulWidget {
  final String selectedDate;
  final String date;

  const DiaryDetailScreen(
      {super.key, required this.selectedDate, required this.date});

  @override
  State<DiaryDetailScreen> createState() => _DiaryDetailScreenState();
}

class _DiaryDetailScreenState extends State<DiaryDetailScreen> {
  final DiaryController _diaryController = DiaryController();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  List<Meal> _meals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMealsForDate();
  }

  Future<void> _fetchMealsForDate() async {
    try {
      final userId = await _storage.read(key: 'userId');

      if (userId == null) {
        throw Exception('User not logged in');
      }

      final meals = await _diaryController.fetchMealsForDate(
        userId: userId,
        date: widget.selectedDate,
      );

      setState(() {
        _meals = meals;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching meals: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button and title
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    widget.date.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppFonts.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Total calories for the day
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.lightbackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'TOTAL CALORIES',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontFamily: AppFonts.primary,
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: _calculateTotalCalories().toString(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontFamily: AppFonts.primary,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                            ),
                          ),
                          const TextSpan(
                            text: ' KCAL',
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: AppFonts.primary,
                              fontWeight: FontWeight.normal,
                              color: AppColors.pink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Meal cards
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _meals.isEmpty
                        ? const Center(
                            child: Text(
                              'No meals recorded for this day',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 18,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _meals.length,
                            itemBuilder: (context, index) {
                              final meal = _meals[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                child: _buildMealCard(meal),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMealCard(Meal meal) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightbackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Meal type and name
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                meal.mealType.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.pink,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppFonts.primary,
                ),
              ),
              Text(
                meal.mealname.isNotEmpty ? meal.mealname : '(No name)',
                style: const TextStyle(
                  color: AppColors.pink,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppFonts.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Ingredients
          if (meal.ingredients.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ingredients:',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                    fontFamily: AppFonts.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatIngredients(meal),
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                    fontFamily: AppFonts.secondary,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 12),

          // Calories
          Align(
            alignment: Alignment.centerRight,
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: meal.calories.toString(), // No need to remove ' kcal'
                    style: const TextStyle(
                      fontSize: 18,
                      fontFamily: AppFonts.primary,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                  const TextSpan(
                    text: ' KCAL',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: AppFonts.primary,
                      fontWeight: FontWeight.normal,
                      color: AppColors.pink,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatIngredients(Meal meal) {
    if (meal.ingredients.length == meal.quantities.length) {
      return List.generate(
        meal.ingredients.length,
        (i) =>
            '• ${meal.quantities[i].toStringAsFixed(0)}g ${meal.ingredients[i]}',
      ).join('\n');
    }
    return meal.ingredients.map((ingredient) => '• $ingredient').join('\n');
  }

  int _calculateTotalCalories() {
    return _meals.fold(0, (sum, meal) => sum + (meal.calories ?? 0));
  }
}
