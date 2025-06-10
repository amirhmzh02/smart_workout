import 'package:flutter/material.dart';
import 'package:fyp/modules/global_import.dart';
import 'package:fyp/modules/explore/explore_controller.dart';
import 'package:fyp/modules/explore/explore_detail_screem.dart';


class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final ExploreController _controller = ExploreController();
  List<Exercise> _exercises = [];
  bool _isLoading = false;
  String? _selectedMuscleGroup;

  // List of muscle groups
  final List<String> muscleGroups = [
    'shoulder',
    'chest',
    'tricep',
    'bicep',
    'core',
    'leg'
  ];

  Future<void> _fetchExercises(String muscleGroup) async {
    setState(() {
      _isLoading = true;
      _selectedMuscleGroup = muscleGroup;
    });

    try {
      final exercises =
          await _controller.getExercisesByMuscleGroup(muscleGroup);
      setState(() {
        _exercises = exercises;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() {
        _isLoading = false;
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
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.03),

              // Header with title
              Center(
                child: Text(
                  'EXPLORE',
                  style: TextStyle(
                    fontFamily: AppFonts.primary,
                    fontSize: 40,
                    fontWeight: AppFonts.regular,
                    color: AppColors.white,
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.03),

              // Horizontal scrollable muscle groups
              SizedBox(
                height: screenHeight * 0.063,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: muscleGroups.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                      child: ElevatedButton(
                        onPressed: () => _fetchExercises(muscleGroups[index]),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _selectedMuscleGroup == muscleGroups[index]
                                  ? AppColors.pink // Highlight selected button
                                  : AppColors.lightbackground,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.06,
                            vertical: screenHeight * 0.02,
                          ),
                        ),
                        child: Text(
                          muscleGroups[index],
                          style: TextStyle(
                            fontFamily: AppFonts.secondary,
                            fontSize: AppFonts.medium,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: screenHeight * 0.05),

              // Loading indicator or exercises list
              _isLoading
    ? Center(
        child: CircularProgressIndicator(color: AppColors.white),
      )
    : ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _exercises.length,
        itemBuilder: (context, index) {
          final exercise = _exercises[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ExerciseDetailScreen(exercise: exercise),
                ),
              );
            },
            child: Card(
              margin: EdgeInsets.only(bottom: screenHeight * 0.02),
              color: AppColors.lightbackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.exerciseName,
                      style: TextStyle(
                        fontFamily: AppFonts.primary,
                        fontSize: AppFonts.large,
                        fontWeight: AppFonts.bold,
                        color: AppColors.white,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.005),
                    Row(
                      children: [
                        Image.asset(
                          'assets/icons/explore_active.png',
                          width: 16,
                          height: 16,
                          color: AppColors.white.withOpacity(0.7),
                        ),
                        SizedBox(width: 10),
                        Text(
                          exercise.equipmentNeed,
                          style: TextStyle(
                            fontFamily: AppFonts.secondary,
                            fontSize: AppFonts.small,
                            color: AppColors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
            ],
          ),
        ),
      ),
    );
  }
}
