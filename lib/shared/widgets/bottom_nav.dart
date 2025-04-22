import 'package:flutter/material.dart';
import 'package:fyp/modules/global_import.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.lightbackground,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Bottom Bar Content
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Home Button
              _buildNavItem(
                activeIcon: 'assets/icons/home_active.png',
                inactiveIcon: 'assets/icons/home.png',
                isActive: currentIndex == 0,
                index: 0,
                label: 'home',
              ),

              // Plan Button
              _buildNavItem(
                activeIcon: 'assets/icons/plan_active.png',
                inactiveIcon: 'assets/icons/plan.png',
                isActive: currentIndex == 1,
                index: 1,
                label: 'plan',
              ),

              // Empty space for middle button
              const SizedBox(width: 25),

              // Explore Button
              _buildNavItem(
                activeIcon: 'assets/icons/explore_active.png',
                inactiveIcon: 'assets/icons/explore.png',
                isActive: currentIndex == 3,
                index: 3,
                label: 'explore',
              ),

              // Me Button
              _buildNavItem(
                activeIcon: 'assets/icons/me_active.png',
                inactiveIcon: 'assets/icons/me.png',
                isActive: currentIndex == 4,
                index: 4,
                label: 'me',
              ),
            ],
          ),

          // Center Floating Button
          Positioned(
            left: MediaQuery.of(context).size.width / 2 - 30,
            top: -25,
            child: GestureDetector(
              onTap: () => onTap(2),
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: AppColors.pink,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.pink.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: FittedBox(
                  // ← This forces the child to respect constraints
                  fit: BoxFit.scaleDown, // Prevents over-scaling
                  child: SizedBox(
                    width: 60, // Your desired GIF width
                    height: 60, // Your desired GIF height
                    child: Image.asset(
                      'assets/gif/workout.gif',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required String activeIcon,
    required String inactiveIcon,
    required bool isActive,
    required int index,
    required String label, // Add this parameter
  }) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            isActive ? activeIcon : inactiveIcon,
            width: 25,
            height: 24,
            color: isActive ? AppColors.pink : Colors.grey,
          ),
          const SizedBox(height: 4), // Small gap between icon and label
          Text(
            label,
            style: TextStyle(
              fontSize: 10, // Small font size
              color: isActive ? AppColors.pink : Colors.grey,
            ),
          ),
          if (isActive)
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 3,
              width: 20,
              decoration: BoxDecoration(
                color: AppColors.pink,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }
}
