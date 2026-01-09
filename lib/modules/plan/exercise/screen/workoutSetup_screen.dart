import 'package:flutter/material.dart';
import 'package:fyp/modules/global_import.dart';
import 'package:fyp/modules/plan/exercise/controller/workout_setup_controller.dart';
import 'package:fyp/modules/plan/exercise/screen/workout_screen.dart';

class WorkoutSetupScreen extends StatefulWidget {
  const WorkoutSetupScreen({super.key});

  @override
  State<WorkoutSetupScreen> createState() => _WorkoutSetupScreenState();
}

class _WorkoutSetupScreenState extends State<WorkoutSetupScreen> {
  double _workoutDays = 4; // Default to 4 days
  final List<String> _equipment = [
    'Dumbbell',
    'Pull Up Bar',
    'Bench',
    'Barbell',
    'Kettlebells',
    'Ab Wheel',
    'Jump Rope',
    'Stepper',
    'Treadmill',
    'Stationary Bike',
  ];
  final List<String> _selectedEquipment = [];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.08,
            vertical: screenHeight * 0.05,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "LET'S SETUP",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: AppFonts.primary,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      'your exercise plan',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.7),
                        fontFamily: AppFonts.secondary,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: screenHeight * 0.05),

              // Days per week slider
              _buildLabel('How many days per week?'),
              SizedBox(height: screenHeight * 0.02),

              // Slider for 3-5 days
              Slider(
                value: _workoutDays,
                min: 3,
                max: 5,
                divisions: 2, // This will give us 3, 4, and 5
                activeColor: AppColors.pink,
                inactiveColor: Colors.grey[700],
                label: _workoutDays.round().toString(),
                onChanged: (value) {
                  setState(() {
                    _workoutDays = value;
                  });
                },
              ),
              Center(
                child: Text(
                  '${_workoutDays.round()} days',
                  style: TextStyle(
                    color: AppColors.pink,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.05),

              // Rest of your content...
              _buildLabel('What equipment you have'),
              SizedBox(height: screenHeight * 0.02),

              // Equipment chips
              Wrap(
                spacing: screenWidth * 0.03,
                runSpacing: screenHeight * 0.02,
                children: _equipment.map((item) {
                  final isSelected = _selectedEquipment.contains(item);
                  return FilterChip(
                    label: Text(
                      item,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withOpacity(0.7),
                        fontFamily: AppFonts.secondary,
                      ),
                    ),
                    selected: isSelected,
                    backgroundColor: Colors.grey[800],
                    selectedColor: AppColors.pink,
                    shape: StadiumBorder(),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedEquipment.add(item);
                        } else {
                          _selectedEquipment.remove(item);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: screenHeight * 0.08),

              // Next Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final controller = WorkoutSetupController();
                    final success = await controller.saveWorkoutPlan(
                      daysPerWeek: _workoutDays.round(),
                      equipmentList: _selectedEquipment,
                    );

                    if (success) {
                      // Navigate to next screen if saved successfully
                      Navigator.pop(context, 'setup_complete');

                    } else {
                      // Optional: Show error if saving failed
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to save workout plan')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pink,
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.02,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'NEXT',
                    style: TextStyle(
                      fontFamily: AppFonts.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        fontFamily: AppFonts.secondary,
      ),
    );
  }
}
