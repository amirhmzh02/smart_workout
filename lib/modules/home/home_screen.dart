import 'package:flutter/material.dart';
import 'package:fyp/modules/global_import.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
                    text: const TextSpan(
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
                          text: 'USER',
                          style: TextStyle(
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

              // Placeholder for DateWidget
              const Placeholder(
                fallbackHeight: 60,
                color: AppColors.pink,
              ),

              const SizedBox(height: 20),

              // 2 Small Boxes Row
              Row(
                children: [
                  Expanded(
                    child: _infoBox("EXERCISE DONE", "0 sec"),
                  ),
                  const SizedBox(width: 15),
                  Container(
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
                  )
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

  Widget _infoBox(String title, String value, {bool isButton = false}) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(12),
      child: Center(
        child: isButton
            ? Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.pink,
                  fontWeight: FontWeight.bold,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(value,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
      ),
    );
  }
}
