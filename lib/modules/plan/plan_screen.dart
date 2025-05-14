import 'package:flutter/material.dart';
import 'package:fyp/modules/global_import.dart';
import 'package:fyp/shared/widgets/plan_tab_widget.dart';

class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Main content with tabs
              Expanded(
                child: Container(
                  
                  child: const Padding(
                    padding: EdgeInsets.all(2.0),
                    child: PlanTabWidget(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}