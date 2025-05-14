import 'package:flutter/material.dart';
import 'package:fyp/modules/global_import.dart';
import 'package:fyp/shared/widgets/meal_card.dart';
import 'package:fyp/shared/models/meal_model.dart';
import 'package:fyp/modules/plan/diet/controller/menu_controller.dart';


class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  late Future<List<Meal>> _mealsFuture;
  final menuController _apiService = menuController();
  final storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _mealsFuture = _fetchMeals();
  }

  Future<List<Meal>> _fetchMeals() async {
  final userId = await storage.read(key: 'userId');
    if (userId == null) throw Exception('User not logged in');
    return await _apiService.getMealPlan(userId);
  }

  @override
  Widget build(BuildContext context) {
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

              // Meal cards
              Expanded(
                child: FutureBuilder<List<Meal>>(
                  future: _mealsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No meals planned today'));
                    }

                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return MealCard(meal: snapshot.data![index]);
                      },
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
}