class WorkoutEntry {
  final int wkid;
  final int exerciseId;
  final String exerciseName;
  final String description;
  final int sets;
  final int reps;
  final double calcBurn;

  WorkoutEntry({
    required this.wkid,
    required this.exerciseId,
    required this.exerciseName,
    required this.description,
    required this.sets,
    required this.reps,
    required this.calcBurn,
  });

  factory WorkoutEntry.fromJson(Map<String, dynamic> json) {
    return WorkoutEntry(
      wkid: int.parse(json['wkid'].toString()),
      exerciseId: int.parse(json['exercise_id'].toString()),
      exerciseName: json['exercise_name'] ?? 'Unknown Exercise',
      description: json['description'] ?? '',
      sets: int.parse(json['set'].toString()),
      reps: int.parse(json['rep'].toString()),
      calcBurn: double.parse(json['calc_burn'].toString()),
    );
  }
}
