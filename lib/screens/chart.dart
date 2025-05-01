import 'package:flutter/material.dart';

class AnimatedCircularChart extends StatefulWidget {
  final double present;  // Number of present days
  final double total;    // Total number of classes

  AnimatedCircularChart({required this.present, required this.total});

  @override
  _AnimatedCircularChartState createState() => _AnimatedCircularChartState();
}

class _AnimatedCircularChartState extends State<AnimatedCircularChart> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    // Ensure non-zero total value to prevent division by zero errors
    if (widget.total == 0) {
      throw Exception("Total number of classes cannot be zero");
    }

    // Create AnimationController
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2), // Duration of the animation
    );

    // Create Tweens for animating the progress percentage
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: (widget.present / widget.total),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut, // Animation curve
    ));

    // Start the animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double percentage = (widget.present / widget.total) * 100;

    return Center(
     
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: _progressAnimation.value,
              strokeWidth: 6,  // Thin ring
              valueColor: AlwaysStoppedAnimation<Color>(Colors.purple), // Color for the progress
            ),
            Text(
              '${percentage.toStringAsFixed(1)}%',  // Show percentage
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      
    );
  }
}
