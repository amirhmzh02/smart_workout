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
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: Colors.grey.shade800, width: 1)),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Bottom Bar Content
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Home Button
              _buildNavItem(
                label: 'HOME', 
                isActive: currentIndex == 0,
                index: 0,
              ),
              
              // Plan Button
              _buildNavItem(
                label: 'PLAN', 
                isActive: currentIndex == 1,
                index: 1,
              ),
              
              // Empty space for middle button
              const SizedBox(width: 60),
              
              // Explore Button (inactive)
              _buildNavItem(
                label: 'EXPLORE', 
                isActive: false,
                index: 3,
              ),
              
              // Me Button (inactive)
              _buildNavItem(
                label: 'ME', 
                isActive: false,
                index: 4,
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
                height: 60,
                width: 60,
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
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required String label,
    required bool isActive,
    required int index,
  }) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isActive ? AppColors.pink : Colors.grey,
              fontFamily: AppFonts.primary,
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