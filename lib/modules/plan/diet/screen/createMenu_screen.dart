import 'package:flutter/material.dart';
import 'package:fyp/modules/global_import.dart';
import 'package:fyp/shared/models/meal_model.dart';
import 'package:fyp/modules/plan/diet/controller/IngredientApiService.dart';
import 'package:fyp/modules/plan/diet/controller/createMenu_controller.dart';
import 'package:fyp/shared/models/ingredients_model.dart';
import 'dart:async';

class CreateMenuScreen extends StatefulWidget {
  final Meal? meal;
  final menuindex;
  const CreateMenuScreen({super.key, this.meal, this.menuindex});

  @override
  State<CreateMenuScreen> createState() => _CreateMenuScreenState();
}

class _CreateMenuScreenState extends State<CreateMenuScreen> {
  final TextEditingController _mealNameController = TextEditingController();
  TextEditingController _searchController = TextEditingController();
  final IngredientApiService _ingredientApiService = IngredientApiService();
  List<Ingredient> _allIngredients = [];
  List<Ingredient> _filteredIngredients = [];
  List<Ingredient> _selectedIngredients = [];
  final storage = FlutterSecureStorage();

  Timer? _debounceTimer;
  bool _isLoading = false;
  String _errorMessage = '';
  double _totalCalories = 0;

  @override
  void initState() {
    super.initState();
    _initializeData();
    // _loadInitialIngredients();
    _searchController = TextEditingController();
  }

  void _initializeData() {
    if (widget.meal != null) {
      _mealNameController.text = widget.meal!.mealname;
      // Initialize with existing meal ingredients if editing
      // You'll need to adapt this based on your Meal model structure
    }
  }

  Future<void> _loadInitialIngredients() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final ingredients = await _ingredientApiService.searchIngredients('');
      setState(() {
        _allIngredients = ingredients;
        _filteredIngredients = ingredients;
      });
    } catch (e) {
      setState(
          () => _errorMessage = 'Failed to load ingredients: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged(String query) {
    query = query.trim();

    if (query.length >= 3) {
      // Call API to fetch filtered ingredients
      _searchIngredientsFromApi(query);
    } else if (query.isEmpty) {
      // Show all ingredients (or clear filtered list if you want)
      setState(() {
        _filteredIngredients = [];
      });
    } else {
      // If less than 3 chars but not empty, clear filtered list
      setState(() {
        _filteredIngredients = [];
      });
    }
  }

  Future<void> _searchIngredientsFromApi(String query) async {
    setState(() => _isLoading = true);

    try {
      final results = await _ingredientApiService.searchIngredients(query);
      setState(() {
        _filteredIngredients = results;
        _errorMessage = '';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to search ingredients: $e';
        _filteredIngredients = [];
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterIngredients(String query) {
    final filtered = _allIngredients.where((ingredient) {
      return ingredient.name.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      _filteredIngredients = filtered;
    });
  }

  void _toggleIngredientSelection(Ingredient ingredient) {
    setState(() {
      if (_selectedIngredients.any((i) => i.id == ingredient.id)) {
        _selectedIngredients.removeWhere((i) => i.id == ingredient.id);
      } else {
        _selectedIngredients.add(Ingredient(
          id: ingredient.id,
          name: ingredient.name,
          calories: ingredient.calories,
          quantity: 100.0, // Default quantity when first added
        ));
      }
      _calculateNutrition();
    });
  }

  void _calculateNutrition() {
    double calories = 0;

    for (var ingredient in _selectedIngredients) {
      calories += ingredient.calculatedCalories;
    }

    setState(() {
      _totalCalories = calories;
    });
  }

  Future<void> _saveMeal() async {
    if (_mealNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a meal name')),
      );
      return;
    }

    if (_selectedIngredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one ingredient')),
      );
      return;
    }

    try {
      setState(() => _isLoading = true);
      final userId = await storage.read(key: 'userId');

      final mealData = {
        'name': _mealNameController.text,
        'meal_type': 'custom',
        'calories': _totalCalories.round(), // <- total kcal for full meal
        'ingredients': _selectedIngredients.map((ingredient) {
          return {
            'ingredient_id': ingredient.id,
            'quantity': ingredient.quantity, // <- in grams per ingredient ✅
          };
        }).toList(),
        'is_custom': userId,
        
      };
      print("this is meal data ");
      print(mealData);
      final success = await CreateMenuController().saveMeal(mealData);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Meal saved successfully!')),
        );

        final updatedMeal = Meal(
          id: widget.meal?.id ?? 0,
          mealType: 'custom',
          mealname: _mealNameController.text,
          ingredients: _selectedIngredients.map((i) => i.name).toList(),
          ingredientsid: _selectedIngredients.map((i) => i.id).toList(),
          quantities: _selectedIngredients
              .map((i) => i.quantity)
              .toList(), // pass quantities
          calories: _totalCalories.round(),
        );

        Navigator.pop(context, {
          'success': true,
          'meal': updatedMeal,
          'index': widget.menuindex,
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save meal')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _mealNameController.dispose();
    _searchController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.meal != null ? 'EDIT MEAL' : 'CREATE MEAL',
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: AppFonts.primary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable section
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- MEAL NAME ---
                    Text('MEAL NAME',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: AppFonts.primary,
                        )),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _mealNameController,
                      style: const TextStyle(color: AppColors.lightbackground),
                      decoration: InputDecoration(
                        hintText: 'MEAL NAME',
                        hintStyle:
                            TextStyle(color: AppColors.white.withOpacity(0.6)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppColors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // --- INGREDIENTS SEARCH ---
                    Text('INGREDIENTS',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: AppFonts.primary,
                        )),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      style: const TextStyle(color: AppColors.lightbackground),
                      decoration: InputDecoration(
                        hintText: 'Search Ingredients...',
                        hintStyle: TextStyle(
                            color: AppColors.lightbackground.withOpacity(0.6)),
                        prefixIcon: const Icon(Icons.search,
                            color: AppColors.lightbackground),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppColors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Text(
                        'Note: Nutritional values are per 100g',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // --- SELECTED INGREDIENTS CHIPS ---
                    if (_selectedIngredients.isNotEmpty) ...[
                      Text('SELECTED INGREDIENTS',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: AppFonts.primary,
                          )),
                      const SizedBox(height: 10),
                      ListView.builder(
                        itemCount: _selectedIngredients.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final ingredient = _selectedIngredients[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          ingredient.name,
                                          style: const TextStyle(
                                            color: AppColors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '${ingredient.calculatedCalories.round()} kcal (${ingredient.calories}kcal/100g)',
                                          style: const TextStyle(
                                            color: AppColors.lightbackground,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 100,
                                    child: TextFormField(
                                      initialValue: ingredient.quantity
                                          .toStringAsFixed(0),
                                      keyboardType: TextInputType.number,
                                      style: const TextStyle(
                                          color: AppColors.white),
                                      decoration: InputDecoration(
                                        hintText: 'grams',
                                        hintStyle: TextStyle(
                                            color: AppColors.white
                                                .withOpacity(0.5)),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide.none,
                                        ),
                                        filled: true,
                                        fillColor: AppColors.background,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 12),
                                        suffixText: 'g',
                                        suffixStyle: const TextStyle(
                                            color: AppColors.white),
                                      ),
                                      onChanged: (value) {
                                        final newQuantity =
                                            double.tryParse(value) ?? 0;
                                        if (newQuantity > 0) {
                                          setState(() {
                                            _selectedIngredients[index]
                                                .quantity = newQuantity;
                                            _calculateNutrition(); // recalculate _totalCalories
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close,
                                        color: AppColors.pink),
                                    onPressed: () {
                                      setState(() {
                                        _selectedIngredients.removeAt(index);
                                        _calculateNutrition();
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                    // --- INGREDIENT LIST ---
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _errorMessage.isNotEmpty
                            ? Center(
                                child: Text(
                                  _errorMessage,
                                  style:
                                      const TextStyle(color: AppColors.white),
                                ),
                              )
                            : ListView.builder(
                                itemCount: _filteredIngredients.length,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  final ingredient =
                                      _filteredIngredients[index];
                                  final isSelected = _selectedIngredients
                                      .any((i) => i.id == ingredient.id);
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    decoration: BoxDecoration(
                                      color: AppColors.background,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ListTile(
                                      title: Text(
                                        ingredient.name,
                                        style: const TextStyle(
                                            color: AppColors.white),
                                      ),
                                      subtitle: Text(
                                        '${ingredient.calories.round()} kcal',
                                        style: const TextStyle(
                                            color: AppColors.white),
                                      ),
                                      trailing: IconButton(
                                        icon: Icon(
                                          isSelected
                                              ? Icons.remove_circle
                                              : Icons.add_circle,
                                          color: isSelected
                                              ? AppColors.pink
                                              : AppColors.white,
                                        ),
                                        onPressed: () =>
                                            _toggleIngredientSelection(
                                                ingredient),
                                      ),
                                    ),
                                  );
                                },
                              ),
                  ],
                ),
              ),
            ),

            // --- BOTTOM SECTION (NOT SCROLLABLE) ---
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'NUTRITION SUMMARY',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildNutritionItem(
                                'CALORIES', '${_totalCalories.round()} kcal'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveMeal,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.pink,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor:
                            AppColors.pink.withOpacity(0.5),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: AppColors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              widget.meal != null ? 'UPDATE MEAL' : 'SAVE MEAL',
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 16,
                                fontFamily: AppFonts.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
