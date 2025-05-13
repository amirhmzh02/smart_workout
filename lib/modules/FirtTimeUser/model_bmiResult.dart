class BmiResult {
  final double bmi;
  final String category;
  final String goal;

  BmiResult({
    required this.bmi,
    required this.category,
    required this.goal,
  });

  factory BmiResult.fromJson(Map<String, dynamic> json) {
    return BmiResult(
      bmi: (json['bmi'] as num).toDouble(),
      category: json['category'] ?? 'Unknown',
      goal: json['metrics']['goal'] ?? 'Unknown',
    );
  }
}
