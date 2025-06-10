import 'package:flutter/material.dart';
import 'package:fyp/modules/global_import.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:fyp/modules/explore/explore_controller.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final Exercise exercise;

  const ExerciseDetailScreen({super.key, required this.exercise});

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  late VideoPlayerController _videoController;
  late ChewieController _chewieController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
  _videoController = VideoPlayerController.asset(
    'assets/video/${widget.exercise.tutorialVideo}',
  );

  await _videoController.initialize();

  _chewieController = ChewieController(
    videoPlayerController: _videoController,
    autoPlay: true,
    looping: true,
    showControls: true,
    materialProgressColors: ChewieProgressColors(
      playedColor: AppColors.pink,
      handleColor: AppColors.pink,
      backgroundColor: AppColors.white.withOpacity(0.3),
      bufferedColor: AppColors.white.withOpacity(0.5),
    ),
  );

  setState(() {
    _isVideoInitialized = true;
  });
}


  @override
  void dispose() {
    _videoController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.exercise.exerciseName,
          style: TextStyle(
            fontFamily: AppFonts.primary,
            fontSize: AppFonts.xLarge,
            color: AppColors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: screenHeight * 0.02),
            
            // Video Player
            Container(
              height: screenHeight * 0.3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.lightbackground,
              ),
              child: _isVideoInitialized
                  ? Chewie(controller: _chewieController)
                  : Center(
                      child: CircularProgressIndicator(
                        color: AppColors.white,
                      ),
                    ),
            ),
            
            SizedBox(height: screenHeight * 0.03),
            
            // Equipment Needed
            _buildInfoRow(
              icon: Icons.fitness_center,
              title: 'Equipment Needed',
              value: widget.exercise.equipmentNeed,
            ),
            
            SizedBox(height: screenHeight * 0.02),
            
            // Target Muscles
            _buildInfoRow(
              icon: Icons.accessibility_new,
              title: 'Target Muscles',
              value: widget.exercise.muscleGroups,
            ),
            
            SizedBox(height: screenHeight * 0.03),
            
            // Description
            Text(
              'Description',
              style: TextStyle(
                fontFamily: AppFonts.primary,
                fontSize: AppFonts.large,
                fontWeight: AppFonts.bold,
                color: AppColors.white,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Text(
              widget.exercise.description,
              style: TextStyle(
                fontFamily: AppFonts.secondary,
                fontSize: AppFonts.medium,
                color: AppColors.white.withOpacity(0.8),
              ),
            ),
            
            SizedBox(height: screenHeight * 0.03),
            
            // How To Do It
            Text(
              'HOW TO DO',
              style: TextStyle(
                fontFamily: AppFonts.primary,
                fontSize: AppFonts.large,
                fontWeight: AppFonts.bold,
                color: AppColors.white,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Text(
              widget.exercise.tutorial,
              style: TextStyle(
                fontFamily: AppFonts.secondary,
                fontSize: AppFonts.medium,
                color: AppColors.white.withOpacity(0.8),
              ),
            ),
            
            SizedBox(height: screenHeight * 0.05),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 24,
          color: AppColors.pink,
        ),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: AppFonts.primary,
                  fontSize: AppFonts.medium,
                  fontWeight: AppFonts.bold,
                  color: AppColors.white,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontFamily: AppFonts.secondary,
                  fontSize: AppFonts.small,
                  color: AppColors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}