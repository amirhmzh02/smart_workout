import 'package:flutter/material.dart';
import 'package:fyp/modules/global_import.dart';
import 'package:fyp/modules/home/home_screen.dart';
import 'package:fyp/modules/plan/plan_screen.dart';
import 'package:fyp/modules/profile/user_profile.dart';
import 'package:fyp/modules/explore/explore_screen.dart';

class MainNav extends StatefulWidget {
  const MainNav({super.key});

  @override
  State<MainNav> createState() => _MainNavState();
}

class _MainNavState extends State<MainNav> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const PlanScreen(),
    Container(),
    const ExploreScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: CustomBottomNav(
          currentIndex: _currentIndex,
          onTap: (index) {
            if (index == 2) {
              // Center button
              _showStartWorkoutDialog();
            } else  {
              setState(() => _currentIndex = index);
            }
          }),
    );
  }

  void _showStartWorkoutDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 200,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              "Start New Workout",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 20),
            // Add your workout starting content here
          ],
        ),
      ),
    );
  }
}

// Placeholder widget for inactive tabs
class PlaceholderWidget extends StatelessWidget {
  final String label;
  const PlaceholderWidget({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        label,
        style: TextStyle(
          fontSize: 18,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }
}
