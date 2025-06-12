import 'package:flutter/material.dart';
import 'package:fyp/modules/global_import.dart';

class WorkoutCard extends StatelessWidget {
  final String name;
  final String duration;
  final String muscle;
  final String reps;

  const WorkoutCard({
    super.key,
    required this.name,
    required this.duration,
    required this.muscle,
    required this.reps,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.lightbackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise title and duration
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                    fontFamily: AppFonts.primary,
                  ),
                ),
                Text(
                  duration,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.pink,
                    fontFamily: AppFonts.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Muscle group and reps
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  muscle,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.white.withOpacity(0.7),
                    fontFamily: AppFonts.secondary,
                  ),
                ),
                Text(
                  reps,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.white,
                    fontFamily: AppFonts.secondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
