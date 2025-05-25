import 'package:flutter/material.dart';
import 'package:fyp/modules/global_import.dart';
import 'package:fyp/shared/widgets/meal_card.dart';
import 'package:fyp/shared/models/meal_model.dart';
import 'package:fyp/modules/plan/diet/controller/menu_controller.dart';
import 'package:fyp/modules/plan/diet/controller/saveMenu_controller.dart';

import 'package:fyp/modules/plan/diet/screen/createMenu_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  late Future<List<Meal>> _mealsFuture;
  final menuController _apiService = menuController();
  final storage = FlutterSecureStorage();
  List<bool> _selectedMeals = [];

  @override
  void initState() {
    super.initState();
    _mealsFuture = _fetchMeals();
  }

  Future<List<Meal>> _fetchMeals() async {
    final userId = await storage.read(key: 'userId');
    if (userId == null) throw Exception('User not logged in');

    final meals = await _apiService.getMealPlan(userId);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _selectedMeals = List<bool>.filled(meals.length, false);
        });
      }
    });

    return meals;
  }

  void _onEditMeal(Meal meal, int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateMenuScreen(meal: meal, menuindex: index),
      ),
    );

    if (result != null && result['success'] == true) {
      final Meal updatedMeal = result['meal'];
      final int updatedIndex = result['index'];

      setState(() {
        _mealsFuture = _mealsFuture.then((meals) {
          meals[updatedIndex] = updatedMeal;
          return meals;
        });
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
                  const Text(
                    "TODAY'S MENU",
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppFonts.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Meal cards with swipe to edit and selectable by tapping
              Expanded(
                child: FutureBuilder<List<Meal>>(
                  future: _mealsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                          child: Text('No meals planned today'));
                    }

                    final meals = snapshot.data!;
                    return ListView.builder(
                      itemCount: meals.length,
                      itemBuilder: (context, index) {
                        final meal = meals[index];
                        final isSelected = index < _selectedMeals.length &&
                            _selectedMeals[index];

                        return Dismissible(
                          key: ValueKey(meal.id ?? index),
                          direction:
                              DismissDirection.endToStart, // swipe left only
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            color: AppColors.background,
                            child: const Icon(Icons.edit, color: Colors.white),
                          ),
                          confirmDismiss: (direction) async {
                            if (direction == DismissDirection.endToStart) {
                              _onEditMeal(meal, index);
                              return false; // prevent dismissal, only trigger edit
                            }
                            return false;
                          },
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                if (index < _selectedMeals.length) {
                                  _selectedMeals[index] =
                                      !_selectedMeals[index];
                                }
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.pink
                                    : AppColors.background,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.pink
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: MealCard(meal: meal),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final snapshot = await _mealsFuture;
                    final selectedMeals = _selectedMeals
                        .asMap()
                        .entries
                        .where((e) => e.value)
                        .map((e) => snapshot[e.key])
                        .toList();

                    if (selectedMeals.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Please select at least one meal")),
                      );
                      return;
                    }

                    for (var meal in selectedMeals) {
                      debugPrint("Selected Meal:");
                      debugPrint("Name: ${meal.name}");
                      debugPrint("Type: ${meal.mealType}");
                      debugPrint(
                          "Ingredients id: ${meal.ingredientsid.join(', ')}");
                      debugPrint("Ingredients: ${meal.ingredients.join(', ')}");
                      debugPrint("Calories: ${meal.calories}");
                    }

                    // Later: Send to controller/api here
                    final userId = await storage.read(key: 'userId');

                    if (userId != null) {
                      await saveMenuController()
                          .submitSelectedMeals(userId, selectedMeals);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Meals submitted to diary!")),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text("User ID not found in secure storage.")),
                      );
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Meals submitted to diary!")),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pink,
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.02,
                      horizontal: screenWidth * 0.1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Confirm',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: screenHeight * 0.022,
                      fontFamily: AppFonts.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
