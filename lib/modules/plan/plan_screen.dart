import 'package:flutter/material.dart';
import 'package:fyp/modules/global_import.dart';
import 'package:fyp/shared/widgets/bottom_nav.dart';

class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Using your defined background color
      body: SafeArea(
        child: Container(
          // Your home screen content will go here
          child: Center(
            child: Text(
              'Plan Screen Content',
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