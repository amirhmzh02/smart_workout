class WorkoutStats {
  final int totalCalories;
  final int workoutDays;

  WorkoutStats({
    required this.totalCalories,
    required this.workoutDays,
  });

  factory WorkoutStats.fromJson(Map<String, dynamic> json) {
    return WorkoutStats(
      totalCalories: json['total_calories'] ?? 0,
      workoutDays: json['workout_days'] ?? 0,
    );
  }
}