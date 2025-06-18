import 'package:flutter/material.dart';
import 'package:fyp/modules/global_import.dart';
import 'package:fyp/modules/home/home_screen.dart';
import 'package:fyp/modules/plan/plan_screen.dart';
import 'package:fyp/modules/profile/user_profile.dart';
import 'package:fyp/modules/explore/explore_screen.dart';
import 'package:fyp/modules/chatbot/chatbot_screen.dart';

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
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const ChatbotScreen(),
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
