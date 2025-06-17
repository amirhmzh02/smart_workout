import 'package:flutter/material.dart';
import 'package:fyp/modules/global_import.dart';
import 'package:flutter/gestures.dart';

class WorkoutCard extends StatefulWidget {
  final String name;
  final String muscle;
  final String reps;
  final bool isSelected;
  final VoidCallback onSelectionChanged;

  const WorkoutCard({
    super.key,
    required this.name,
    required this.muscle,
    required this.reps,
    required this.isSelected,
    required this.onSelectionChanged,
  });

  @override
  State<WorkoutCard> createState() => _WorkoutCardState();
}

class _WorkoutCardState extends State<WorkoutCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fillAnimation;
  bool _isHolding = false;
  bool _animationCompleted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 10),
    );
    _fillAnimation = Tween<double>(begin: 0, end: 1).animate(_controller)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animationCompleted = true;
          widget
              .onSelectionChanged(); // Trigger selection when animation completes
        } else if (status == AnimationStatus.dismissed) {
          _animationCompleted = false;
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleLongPressStart() {
    setState(() {
      _isHolding = true;
      _animationCompleted = false;
    });
    _controller.forward();
  }

  void _handleLongPressEnd() {
    if (!_animationCompleted) {
      _controller.reverse();
    }
    setState(() {
      _isHolding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      gestures: {
        CustomLongPressGestureRecognizer: GestureRecognizerFactoryWithHandlers<
            CustomLongPressGestureRecognizer>(
          () => CustomLongPressGestureRecognizer(
              duration: const Duration(milliseconds: 200)),
          (CustomLongPressGestureRecognizer instance) {
            instance.onLongPressStart = (details) => _handleLongPressStart();
            instance.onLongPressEnd = (details) => _handleLongPressEnd();
          },
        ),
      },
      child: Stack(
        children: [
          // Base Card
          Card(
            color: AppColors.lightbackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: widget.isSelected
                  ? const BorderSide(color: AppColors.pink, width: 4)
                  : BorderSide.none,
            ),
            elevation: widget.isSelected ? 4 : 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                          fontFamily: AppFonts.primary,
                        ),
                      ),
                      if (widget.isSelected)
                        const Icon(
                          Icons.check_circle,
                          color: AppColors.pink,
                          size: 20,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.muscle,
                        style: TextStyle(
                          fontSize: 14,
                          color: widget.isSelected
                              ? AppColors.pink.withOpacity(0.8)
                              : AppColors.white.withOpacity(0.7),
                          fontFamily: AppFonts.secondary,
                        ),
                      ),
                      Text(
                        widget.reps,
                        style: TextStyle(
                          fontSize: 14,
                          color: widget.isSelected
                              ? AppColors.pink
                              : AppColors.white,
                          fontFamily: AppFonts.secondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Animated Fill Effect
          if (_isHolding || _animationCompleted)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    // Animated Fill
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: _fillAnimation.value,
                        heightFactor: 1.0,
                        
                      ),
                    ),

                    // Animated Border
                    CustomPaint(
                      painter: _AnimatedBorderPainter(
                        progress: _fillAnimation.value,
                        color: AppColors.pink,
                        isSelected: widget.isSelected,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AnimatedBorderPainter extends CustomPainter {
  final double progress;
  final Color color;
  final bool isSelected;

  _AnimatedBorderPainter({
    required this.progress,
    required this.color,
    required this.isSelected,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!isSelected) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * progress, 0)
      ..lineTo(size.width * progress, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _AnimatedBorderPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        color != oldDelegate.color ||
        isSelected != oldDelegate.isSelected;
  }
}

class CustomLongPressGestureRecognizer extends LongPressGestureRecognizer {
  final Duration duration;

  CustomLongPressGestureRecognizer({
    required this.duration,
  }) : super(duration: duration);
}
