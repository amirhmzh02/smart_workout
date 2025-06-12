import 'package:flutter/material.dart';
import 'package:fyp/modules/global_import.dart';
import 'package:fyp/modules/plan/diet/screen/diet_screen.dart';
import 'package:fyp/modules/plan/exercise/screen/workout_screen.dart';

class PlanTabWidget extends StatefulWidget {
  const PlanTabWidget({super.key});

  @override
  State<PlanTabWidget> createState() => _PlanTabWidgetState();
}

class _PlanTabWidgetState extends State<PlanTabWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab Bar
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            // Removed the border.all completely
          ),
          child: TabBar(
            controller: _tabController,
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(
                width: 3.0, // Thickness of the underline
                color: AppColors.pink, // Color of the underline
              ),
              insets: EdgeInsets.only(
                  bottom: 8), // Space between text and underline
            ),
            indicatorSize:
                TabBarIndicatorSize.label, // Underline matches text width
            labelColor: AppColors.white, // Active tab text color
            unselectedLabelColor: AppColors.white, // Inactive tab text color
            labelStyle: TextStyle(
              fontFamily: AppFonts.primary,
              fontWeight: AppFonts.regular,
              fontSize: 16, // Added font size for consistency
            ),
            unselectedLabelStyle: TextStyle(
              fontFamily: AppFonts.primary,
              fontWeight: AppFonts.regular,
              fontSize: 16, // Added font size for consistency
            ),
            tabs: const [
              Tab(text: 'EXERCISE'),
              Tab(text: 'DIET'),
            ],
          ),
        ),

        // Tab Bar View - Just renders the screens
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              ExerciseScreen(),
              DietScreen(),
            ],
          ),
        ),
      ],
    );
  }
}
