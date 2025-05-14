import 'package:flutter/material.dart';
import 'package:fyp/modules/global_import.dart';

class ResultsScreen extends StatefulWidget {
  final double bmi;
  final String category;
  final String goal; // "loss", "maintain", "gain"

  const ResultsScreen({
    super.key,
    required this.bmi,
    required this.category,
    required this.goal,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  late String _selectedGoal;

  // Mapping goal key to readable label
  final Map<String, String> goalMap = {
    'loss': 'LOSE WEIGHT',
    'maintain': 'MAINTAIN / BUILD MUSCLE',
    'gain': 'GAIN WEIGHT',
  };

  @override
  void initState() {
    super.initState();
    _selectedGoal =
        goalMap[widget.goal.toLowerCase()] ?? 'MAINTAIN //n BUILD MUSCLE';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // BMI Card
              _buildBMICard(screenWidth),
              const SizedBox(height: 20),
              // Goal Card
              _buildGoalCard(screenWidth),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBMICard(double screenWidth) {
    return Card(
      color: AppColors.lightbackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          children: [
            Text("We've calculated your BMI", style: _secondaryStyle()),
            const SizedBox(height: 8),
            Text(widget.bmi.toStringAsFixed(1), style: _primaryValueStyle()),
            const SizedBox(height: 20),
            _buildBMIScale(),
            Text("Category: ${widget.category}", style: _secondaryStyle()),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard(double screenWidth) {
    return Card(
      color: AppColors.lightbackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          children: [
            Text("Determine your", style: _secondaryStyle()),
            Text("GOAL", style: _primaryValueStyle()),
            Text("Recommended based on your BMI", style: _secondaryStyle()),
            const SizedBox(height: 15),
            ...goalMap.values.map((goalLabel) => _buildGoalOption(goalLabel)),
            const SizedBox(height: 15),
            SizedBox(
              height: 40,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _saveResults(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.pink,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("DONE",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalOption(String goalLabel) {
    bool isSelected = _selectedGoal == goalLabel;
    bool isRecommended = goalLabel == goalMap[widget.goal.toLowerCase()];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: ListTile(
        tileColor: AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: isSelected ? AppColors.pink : Colors.transparent,
            width: 2,
          ),
        ),
        title: Text(goalLabel, style: _goalStyle()),
        trailing: isSelected ? Icon(Icons.check, color: AppColors.pink) : null,
        onTap: () {
          if (isRecommended) {
            setState(() {
              _selectedGoal = goalLabel;
            });
          } else {
            _showInfoDialog(
                goalMap[widget.goal.toLowerCase()] ?? 'a recommended goal');
          }
        },
      ),
    );
  }

  void _showInfoDialog(String recommendedGoal) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Goal Locked"),
          content: Text(
            "For now, your recommended goal is \"$recommendedGoal\" based on your BMI. "
            "You’ll be able to change your goal based on your progress later.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBMIScale() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            Container(
              height: 10,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: const LinearGradient(
                  colors: [
                    Colors.blue,
                    Colors.green,
                    Colors.orange,
                    Colors.red
                  ],
                  stops: [0.0, 0.25, 0.75, 1.0],
                ),
              ),
            ),
            Align(
              alignment: _getBMIIndicatorPosition(widget.bmi),
              child: const Icon(Icons.arrow_drop_up,
                  size: 32, color: Colors.white),
            ),
          ],
        ),
      ],
    );
  }

  Alignment _getBMIIndicatorPosition(double bmi) {
    double minBMI = 12;
    double maxBMI = 40;
    double normalized = ((bmi - minBMI) / (maxBMI - minBMI)) * 2 - 1;
    return Alignment(normalized.clamp(-1.0, 1.0), 0);
  }

  Future<void> _saveResults() async {
    print("User selected goal: $_selectedGoal");

    try {
      await UserController().fetchAndStoreUserData();
    } catch (e) {
      print(e);
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainNav()),
    );
  }

  TextStyle _secondaryStyle() => TextStyle(
        fontSize: 16,
        color: AppColors.white,
        fontFamily: AppFonts.secondary,
      );

  TextStyle _primaryValueStyle() => TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: AppColors.white,
        fontFamily: AppFonts.primary,
      );

  TextStyle _goalStyle() => TextStyle(
        color: AppColors.white,
        fontFamily: AppFonts.primary,
        fontSize: 16,
      );
}
