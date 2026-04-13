import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'background_config.dart';


class BackgroundManager extends StatefulWidget {
  final BackgroundConfig config;
  final Widget child;

  const BackgroundManager({
    super.key,
    required this.config,
    required this.child
  });

  @override
  State<BackgroundManager> createState() => _BackgroundManagerState();
}

class _BackgroundManagerState extends State<BackgroundManager>
    with SingleTickerProviderStateMixin{
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  BackgroundConfig? _oldConfig;

  @override
  void initState(){
    super.initState();
    _fadeController = AnimationController(
        vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fadeAnimation = CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeInOut
    );
  }

  @override
  void didUpdateWidget(BackgroundManager old){
    super.didUpdateWidget(old);
    if(old.config != widget.config){
      _oldConfig = old.config;
      _fadeController.forward(from: 0);
    }
  }

  @override
  void dispose(){
    _fadeController.dispose();
    super.dispose();
  }

  Widget _buildBg(BackgroundConfig config){
    switch (config.type){
      case BackgroundType.lottie:
        return Lottie.asset(
          config.lottiePath!,
          fit: config.fit,
          repeat: true,
          width: double.infinity,
          height: double.infinity
        );
      case BackgroundType.gradient:
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: config.gradientColors!,
              stops: config.gradientStops
            )
          ),
        );
      case BackgroundType.image:
        return Image.asset(
          config.imagePath!,
          fit: config.fit,
          width: double.infinity,
          height: double.infinity,
        );
    }
  }

  Widget _buildBgWithDim(BackgroundConfig config) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _buildBg(config),
        if (config.dimAmount > 0)
          Container(color: Colors.black.withOpacity(config.dimAmount)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if(_oldConfig != null)
          Positioned.fill(child: _buildBg(_oldConfig!),),

        Positioned.fill(
            child: FadeTransition(
              opacity: _fadeAnimation,
                child: _buildBgWithDim(widget.config),
            )
        ),
        widget.child
      ],
    );
  }
}
