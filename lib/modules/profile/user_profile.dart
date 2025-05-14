import 'package:flutter/material.dart';
import 'package:fyp/modules/global_import.dart'; // assumes this includes UserSecureStorage & navigation
import 'package:fyp/modules/authentication/screen/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ElevatedButton(
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
            ),
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
    // Clear user data
    await UserController
        .clearUserData(); // Make sure this function exists and clears from secure storage

    // Navigate to login screen
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }
}
