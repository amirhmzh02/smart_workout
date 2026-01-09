import 'package:flutter/material.dart';
import 'package:fyp/modules/global_import.dart';
import 'package:fyp/modules/authentication/screen/login_screen.dart';
import 'package:fyp/modules/authentication/screen/update_screen.dart';
import 'package:fyp/modules/profile/workout_service.dart';
import 'package:fyp/modules/plan/exercise/screen/workoutSetup_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<Map<String, dynamic>?>? _statsFuture;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _statsFuture = WorkoutService.getMonthlyStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'THIS MONTH',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppFonts.primary,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Stats Row with FutureBuilder
              FutureBuilder<Map<String, dynamic>?>(
                future: _statsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError || !snapshot.hasData) {
                    return const Text('Failed to load stats');
                  }

                  final data = snapshot.data!;
                  if (data['success'] != true) {
                    return Text(data['message'] ?? 'No data available');
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatCard(
                        iconPath: 'assets/icons/fire.png',
                        value: '${data['total_calories'] ?? 0}',
                        label: 'kcal',
                      ),
                      _buildStatCard(
                        iconPath: 'assets/icons/explore_active.png',
                        value: '${data['workout_days'] ?? 0}',
                        label: 'DAYS',
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 100),

              // Rest of your UI remains the same
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
                    child: Text(
                      'Manage',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: AppFonts.primary,
                      ),
                    ),
                  ),
                  _buildMenuButton('Account', onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UpdateScreen()),
                    );
                  }),
                  const SizedBox(height: 15),
                  _buildMenuButton('Equipment', onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => WorkoutSetupScreen()),
                    );
                  }),
                  const SizedBox(height: 30),
                  Center(
                    child: _buildLogoutButton(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
      {required String iconPath,
      required String value,
      required String label}) {
    return Column(
      children: [
        Image.asset(
          iconPath,
          width: 40,
          height: 40,
        ),
        const SizedBox(height: 10),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: AppFonts.primary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontFamily: AppFonts.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuButton(String text, {VoidCallback? onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lightbackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: AppFonts.secondary,
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.pink,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      onPressed: () => _showLogoutConfirmation(context),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Text(
          'LOG OUT',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: AppFonts.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          title: const Text("Confirm Logout",
              style: TextStyle(
                fontFamily: AppFonts.secondary,
                fontWeight: AppFonts.bold,
              )),
          content: const Text("Are you sure you want to logout?",
              style: TextStyle(
                fontFamily: AppFonts.secondary,
              )),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel",
                  style: TextStyle(
                      color: AppColors.pink,
                      fontFamily: AppFonts.secondary,
                      fontWeight: AppFonts.bold)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await _logoutUser();
              },
              child: const Text("Logout",
                  style: TextStyle(
                      color: Colors.red, fontFamily: AppFonts.secondary)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logoutUser() async {
    await UserController.clearUserData();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }
}
