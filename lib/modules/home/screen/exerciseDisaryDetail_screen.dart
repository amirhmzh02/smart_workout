import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fyp/modules/global_import.dart';
import 'package:fyp/shared/models/WorkoutEntry.dart';
import 'package:fyp/modules/home/controller/exercise_diary_detail_controller.dart';

class ExerciseDiaryDetailScreen extends StatefulWidget {
  final String selectedDate;
  final String date;

  const ExerciseDiaryDetailScreen({
    super.key,
    required this.selectedDate,
    required this.date,
  });

  @override
  State<ExerciseDiaryDetailScreen> createState() =>
      _ExerciseDiaryDetailScreenState();
}

class _ExerciseDiaryDetailScreenState extends State<ExerciseDiaryDetailScreen> {
  final ExerciseDiaryController _controller = ExerciseDiaryController();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  List<WorkoutEntry> _workouts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWorkouts();
  }

  Future<void> _fetchWorkouts() async {
    try {
      final userId = await _storage.read(key: 'userId');

      if (userId == null) {
        throw Exception('User not logged in');
      }

      final workouts = await _controller.fetchWorkoutEntries(
        userId: userId,
        date: widget.selectedDate,
      );

      setState(() {
        _workouts = workouts;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching workouts: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back and title
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    widget.date.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppFonts.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Total calories
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.lightbackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'TOTAL BURNED',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 15,
                        fontFamily: AppFonts.primary,
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: _calculateTotalBurn().toString(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontFamily: AppFonts.primary,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                            ),
                          ),
                          const TextSpan(
                            text: ' KCAL',
                            style: TextStyle(
                              fontSize: 10,
                              fontFamily: AppFonts.primary,
                              fontWeight: FontWeight.normal,
                              color: AppColors.pink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Workout cards
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _workouts.isEmpty
                        ? const Center(
                            child: Text(
                              'No workouts recorded for this day',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 18,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _workouts.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                child: _buildWorkoutCard(_workouts[index]),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutCard(WorkoutEntry workout) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightbackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise name and burn
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                workout.exerciseName,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppFonts.secondary,
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: workout.calcBurn.toStringAsFixed(0),
                      style: const TextStyle(
                        fontSize: 18,
                        fontFamily: AppFonts.primary,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                    const TextSpan(
                      text: ' KCAL',
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: AppFonts.primary,
                        fontWeight: FontWeight.normal,
                        color: AppColors.pink,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${workout.sets} sets x ${workout.reps} reps',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 14,
              fontFamily: AppFonts.secondary,
            ),
          ),
         
        ],
      ),
    );
  }

  int _calculateTotalBurn() {
    return _workouts.fold(0, (sum, item) => sum + item.calcBurn.toInt());
  }
}
