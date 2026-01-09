import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fyp/modules/global_import.dart';

class Exercise {
  final int exerciseId;
  final String muscleGroups;
  final String exerciseName;
  final String description;
  final String tutorial;
  final String tutorialVideo;
  final String equipmentNeed;

  Exercise({
    required this.exerciseId,
    required this.muscleGroups,
    required this.exerciseName,
    required this.description,
    required this.tutorial,
    required this.tutorialVideo,
    required this.equipmentNeed,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      exerciseId: json['exercise_id'] ?? '',
      muscleGroups: json['muscle_groups'] ?? '',
      exerciseName: json['exercise_name'] ?? '',
      description: json['description'] ?? '',
      tutorial: json['tutorial'] ?? '',
      tutorialVideo: json['tutorial_video'] ?? '',
      equipmentNeed: json['equipment_need'] ?? '',
    );
  }
}

class ExploreController {
  Future<List<Exercise>> getExercisesByMuscleGroup(String muscleGroup) async {
    final response = await http.get(
      Uri.parse('http://$activeIP/get_exercises.php?muscle_group=$muscleGroup'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        return (data['data'] as List)
            .map((exercise) => Exercise.fromJson(exercise))
            .toList();
      } else {
        throw Exception(data['message']);
      }
    } else {
      throw Exception('Failed to load exercises');
    }
  }
}