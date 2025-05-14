import 'package:flutter/material.dart';
import 'package:fyp/modules/global_import.dart';
import 'package:fyp/modules/plan/diet/screen/menu_screen.dart';

class DietScreen extends StatelessWidget {
  const DietScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: screenHeight * 0.05),
              
    
              
              SizedBox(height: screenHeight * 0.04),
              
              // Calorie Information Container
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(screenWidth * 0.07),
                decoration: BoxDecoration(
                  color: AppColors.lightbackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      'CALORIES INTAKE',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: screenHeight * 0.02,
                        fontFamily: AppFonts.primary,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '1,400-1,800',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: screenHeight * 0.018,
                            fontFamily: AppFonts.secondary,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        Text(
                          'kcal/day',
                          style: TextStyle(
                            color: AppColors.pink,
                            fontSize: screenHeight * 0.018,
                            fontFamily: AppFonts.secondary,
                          ),
                        ),
                      ],
                    ),
                   
                    
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.05),
              
              // View Menu Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MenuScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pink,
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.02,
                      horizontal: screenWidth * 0.1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'View Menu',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: screenHeight * 0.022,
                      fontFamily: AppFonts.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}