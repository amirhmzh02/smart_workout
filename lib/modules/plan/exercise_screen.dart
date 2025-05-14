import 'package:flutter/material.dart';
import 'package:fyp/modules/global_import.dart';

class ExerciseScreen extends StatelessWidget {
  const ExerciseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Exercise Screen Content',
        style: TextStyle(
          color: AppColors.white,
          fontSize: 20,
          fontFamily: AppFonts.primary,
        ),
      ),
    );
  }
}