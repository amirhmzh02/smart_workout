import 'package:fyp/modules/global_import.dart';
import 'package:fyp/modules/plan/exercise/controller/workout_setup_controller.dart';
import 'package:fyp/shared/widgets/workout_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({super.key});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  String _selectedLocation = 'home';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final List<Map<String, dynamic>> _exercises = [];
  final List<bool> _selectedExercises = [];
  final List<int> _selectedIndices = [];
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final result = await WorkoutSetupController.checkUser(context);
      _selectedExercises.addAll(List.filled(_exercises.length, false));
      if (result == 1) {
        await fetchExercises(_selectedLocation);
      }
    });
  }

  Future<void> fetchExercises(String location) async {
    final userId = await _storage.read(key: 'userId');
    if (userId == null) return;

    try {
      final response = await http.get(Uri.parse(
        'http://$activeIP/get_exercise.php?user_id=$userId&location=$location',
      ));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          setState(() {
            _exercises.clear();
            for (var item in data['exercises']) {
              _exercises.add({
                'name': item['exercise_name'],
                'muscle': item['muscle_groups'],
                'sets': 3,
                'reps': 12,
              });
            }
            // Initialize selection list AFTER exercises are loaded
            _selectedExercises.clear();
            _selectedExercises.addAll(List.filled(_exercises.length, false));
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching exercises: $e');
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    
                    Container(
                      padding: const EdgeInsets.all(4),
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
                    const SizedBox(
                        width: 8), // Spacing between icon and buttons
                    Tooltip(
                      message:
                          'hold excersice to select, tap to edit rep/set',
                      child: Icon(
                        Icons.info_outline,
                        size: 18,
                        color: AppColors.white.withOpacity(0.7),
                      ),
                    ),
                    
                  ],
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
                  final isSelected = _selectedIndices.contains(index);

                  return GestureDetector(
                    onTap: () {
                      if (_isSelectionMode) {
                        // In selection mode - toggle selection
                        setState(() {
                          if (isSelected) {
                            _selectedIndices.remove(index);
                            if (_selectedIndices.isEmpty) {
                              _isSelectionMode = false;
                            }
                          } else {
                            _selectedIndices.add(index);
                          }
                        });
                      } else {
                        // Normal mode - show set/reps picker
                        _showSetRepPicker(index);
                      }
                    },
                    onLongPress: () {
                      setState(() {
                        _isSelectionMode = true;
                        if (isSelected) {
                          _selectedIndices.remove(index);
                        } else {
                          _selectedIndices.add(index);
                        }
                      });
                    },
                    child: WorkoutCard(
                      name: exercise['name'],
                      muscle: exercise['muscle'],
                      reps:
                          '${exercise['sets']} Sets • ${exercise['reps']} Reps',
                      isSelected: _selectedIndices
                          .contains(index), // Use one selection method
                      onSelectionChanged: () {
                        setState(() {
                          if (_selectedIndices.contains(index)) {
                            _selectedIndices.remove(index);
                          } else {
                            _selectedIndices.add(index);
                          }
                          _isSelectionMode = _selectedIndices.isNotEmpty;
                        });
                      },
                    ),
                  );
                },
              ),
              if (_isSelectionMode)
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Perform action on selected items
                          debugPrint('Selected indices: $_selectedIndices');
                          // Here you could delete, share, etc.

                          // Exit selection mode
                          setState(() {
                            _selectedIndices.clear();
                            _isSelectionMode = false;
                          });
                        },
                        child: Text('Delete Selected'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.pink,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedIndices.clear();
                            _isSelectionMode = false;
                          });
                        },
                        child: Text('Cancel'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lightbackground,
                        ),
                      ),
                    ],
                  ),
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
      onTap: () async {
        setState(() {
          _selectedLocation = location;
        });
        await fetchExercises(location);
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
        return SafeArea(
          child: SizedBox(
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
                          Text('Sets',
                              style: TextStyle(color: AppColors.white)),
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
                          Text('Reps',
                              style: TextStyle(color: AppColors.white)),
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
          ),
        );
      },
    );
  }
}
