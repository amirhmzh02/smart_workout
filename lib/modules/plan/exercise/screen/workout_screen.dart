import 'package:flutter/material.dart';
import 'package:fyp/modules/global_import.dart';
import 'package:fyp/modules/plan/exercise/controller/workout_setup_controller.dart';
import 'package:fyp/shared/widgets/workout_card.dart';
import 'package:flutter/cupertino.dart';

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({super.key});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  String _selectedLocation = 'home'; // Default to home
  final List<Map<String, dynamic>> _exercises = [
    {
      'name': 'PUSH UP',
      'duration': '3 sec.',
      'muscle': 'chest',
      'sets': 3,
      'reps': 12,
    },
    {
      'name': 'PIKE PUSH-UPS',
      'duration': '3 sec.',
      'muscle': 'shoulder',
      'sets': 3,
      'reps': 12,
    },
    {
      'name': 'TRICEP DIPS',
      'duration': '4 sec.',
      'muscle': 'triceps',
      'sets': 3,
      'reps': 12,
    },
    {
      'name': 'INCLINE PUSH-UPS',
      'duration': '4 sec.',
      'muscle': 'chest',
      'sets': 3,
      'reps': 12,
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WorkoutSetupController.checkUser(context).then((result) {
        if (result == 1) {
          // User has a plan, continue normal flow...
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: screenHeight * 0.03,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Center(
                child: Text(
                  'TARGET',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                    fontFamily: AppFonts.primary,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Center(
                child: Text(
                  'Chest, Shoulder, Triceps',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.white.withOpacity(0.7),
                    fontFamily: AppFonts.secondary,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),

              // Location Toggle
              Center(
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.lightbackground,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildLocationButton('home'),
                      _buildLocationButton('gym'),
                    ],
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),

              // Exercises List
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _exercises.length,
                separatorBuilder: (context, index) =>
                    SizedBox(height: screenHeight * 0.02),
                itemBuilder: (context, index) {
                  final exercise = _exercises[index];
                  return GestureDetector(
                    onTap: () => _showSetRepPicker(index),
                    child: WorkoutCard(
                      name: exercise['name'],
                      duration: exercise['duration'],
                      muscle: exercise['muscle'],
                      reps:
                          '${exercise['sets']} Sets • ${exercise['reps']} Reps',
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

  Widget _buildLocationButton(String location) {
    final isSelected = _selectedLocation == location;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLocation = location;
          // You can filter exercises based on location here
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.pink : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          location.toUpperCase(),
          style: TextStyle(
            color:
                isSelected ? AppColors.white : AppColors.white.withOpacity(0.7),
            fontWeight: FontWeight.bold,
            fontFamily: AppFonts.primary,
          ),
        ),
      ),
    );
  }

  void _showSetRepPicker(int index) {
    int selectedSet = _exercises[index]['sets'];
    int selectedRep = _exercises[index]['reps'];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(child: SizedBox(
          height: 500,
          child: Column(
            children: [
              SizedBox(height: 16),
              Text(
                _exercises[index]['name'],
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppFonts.primary,
                ),
              ),
              SizedBox(
                height: 300, // or any suitable height
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // SET PICKER
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Sets', style: TextStyle(color: AppColors.white)),
                        SizedBox(
                          height: 120,
                          width: 60,
                          child: CupertinoPicker(
                            scrollController: FixedExtentScrollController(
                                initialItem: selectedSet - 1),
                            backgroundColor: Colors.transparent,
                            itemExtent: 40,
                            onSelectedItemChanged: (value) {
                              selectedSet = value + 1;
                            },
                            children: List.generate(5, (index) {
                              return Center(
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                      color: AppColors.white, fontSize: 18),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),

                    // REPS PICKER
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Reps', style: TextStyle(color: AppColors.white)),
                        SizedBox(
                          height: 120,
                          width: 60,
                          child: CupertinoPicker(
                            scrollController: FixedExtentScrollController(
                                initialItem: selectedRep - 1),
                            backgroundColor: Colors.transparent,
                            itemExtent: 40,
                            onSelectedItemChanged: (value) {
                              selectedRep = value + 1;
                            },
                            children: List.generate(30, (index) {
                              return Center(
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                      color: AppColors.white, fontSize: 18),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Done Button
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pink,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: () {
                    setState(() {
                      _exercises[index]['sets'] = selectedSet;
                      _exercises[index]['reps'] = selectedRep;
                    });
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Done',
                    style: TextStyle(
                      color: AppColors.white,
                      fontFamily: AppFonts.primary,
                      fontSize: 16,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),);
        
      },
    );
  }
}
