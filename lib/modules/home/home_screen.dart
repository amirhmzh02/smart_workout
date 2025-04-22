import 'package:flutter/material.dart';
import 'package:fyp/modules/global_import.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Using your defined background color
      body: SafeArea(
        child: Container(
          // Your home screen content will go here
          child: Center(
            child: Text(
              'Home Screen Content',
              style: TextStyle(
                color: AppColors.white, // Using your defined white color
                fontSize: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }

  
}