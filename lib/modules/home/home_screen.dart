import 'package:flutter/material.dart';
import 'package:fyp/modules/global_import.dart';
import 'package:fyp/modules/home/screen/diary_screen.dart';
import 'package:fyp/modules/home/screen/ExerciseDiary_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = 'USER';
  String _weeklyCalories = "Loading...";
  String _weeklyDays = "0 days";

  @override
  void initState() {
    super.initState();
    _loadUserName();
    loadWeeklySummary();
  }

  Future<void> _loadUserName() async {
    final name = await UserController.getUsername();
    setState(() {
      userName = name ?? 'User'; // Default to 'User' if no name is found
    });
  }

  Future<void> loadWeeklySummary() async {
    final summary = await fetchWeeklyExerciseSummary();
    setState(() {
      _weeklyCalories =
          summary != null ? "${summary['total_calories'] ?? 0} kcal" : "0 kcal";
      _weeklyDays =
          summary != null ? "${summary['total_days'] ?? 0} days" : "0 days";
    });
  }

  Future<Map<String, dynamic>?> fetchWeeklyExerciseSummary() async {
    const apiUrl = 'http://$activeIP/get_weekly_exercise_summary.php';
    final _storage = const FlutterSecureStorage();
    final userId = await _storage.read(key: 'userId');

    if (userId == null) return null;

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': userId}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> resData = jsonDecode(response.body);
      if (resData['success'] == true) {
        return resData['data'];
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome + Icon Row
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Text on the right
                  RichText(
                    textAlign: TextAlign.right,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'welcome\n',
                          style: TextStyle(
                            color: AppColors.white,
                            fontFamily: AppFonts.primary,
                            fontSize: 40,
                            fontWeight: AppFonts.regular,
                          ),
                        ),
                        TextSpan(
                          text: userName,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontFamily: AppFonts.primary,
                            fontSize: 20,
                            fontWeight: AppFonts.regular,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Add gap

                  // Logo on the far right
                  Image.asset(
                    'assets/images/logo-nobg.png',
                    height: screenHeight * 0.15,
                    width: screenHeight * 0.10,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Day Count
              Row(
                children: const [
                  Text("Day ",
                      style: TextStyle(
                          color: AppColors.white,
                          fontFamily: AppFonts.primary,
                          fontSize: 18)),
                  Text("1",
                      style: TextStyle(
                          color: AppColors.pink,
                          fontFamily: AppFonts.primary,
                          fontSize: 18)),
                ],
              ),

              const SizedBox(height: 10),
              Container(height: 3, color: AppColors.pink),

              const SizedBox(height: 20),

              // 2 Small Boxes Row
              Row(
                children: [
                  // Make EXERCISE DONE tappable
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ExerciseDiaryScreen(),
                          ),
                        );
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          exerciseSummaryBox("$_weeklyDays", "$_weeklyCalories")
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 15),
                  // Diet plan card
                  Container(
                    width: screenWidth * 0.3,
                    height: screenHeight * 0.15,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const DiaryScreen()),
                        );
                      },
                      child: Container(
                        width: screenWidth * 0.3,
                        height: screenHeight * 0.15,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Diet',
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontFamily: AppFonts.primary,
                                      fontWeight: AppFonts.regular,
                                      color: AppColors.pink)),
                              Text('plan',
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontFamily: AppFonts.primary,
                                      fontWeight: AppFonts.regular,
                                      color: Colors.black)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // Large Task Box
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(20),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Padding for "Today"
                      const Padding(
                        padding: EdgeInsets.only(left: 45, top: 0, bottom: 0),
                        child: Text(
                          "Today",
                          style: TextStyle(
                            fontSize: 32,
                            fontFamily: AppFonts.primary,
                            fontWeight: AppFonts.regular,
                            color: AppColors.background,
                          ),
                        ),
                      ),
                      // Padding for "Task"
                      const Padding(
                        padding: EdgeInsets.only(right: 50),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              "Task",
                              style: TextStyle(
                                fontSize: 32,
                                fontFamily: AppFonts.primary,
                                fontWeight: FontWeight.w500,
                                color: AppColors.pink,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.background,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                            child: Text(
                              "BEGIN",
                              style: TextStyle(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: AppFonts.primary,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget exerciseSummaryBox(String days, String cal) {
    return Container(
      height: 140,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _exerciseRow("EXERCISE\nDONE", days),
          const Divider(height: 1, color: Colors.pink, thickness: 2),
          _exerciseRow("CALORIE\nBURN", cal),
        ],
      ),
    );
  }

  Widget _exerciseRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.background,
            fontFamily:
                AppFonts.primary, // Optional: use a futuristic font like Orbitron
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  color: AppColors.background,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppFonts.secondary,
                ),
              ),
            ),
            
            
          ],
        ),
      ],
    );
  }
}
