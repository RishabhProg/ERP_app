import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../widget_launcher.dart';
import 'background_config.dart';
import 'background_manager.dart';
import 'background_storage.dart';
import 'app_backgrounds.dart'; // ← centralized list

class BackgroundSelectorScreen extends StatefulWidget {

  final void Function(int index) onSelected;

  const BackgroundSelectorScreen({
    super.key,
    required this.onSelected,
  });

  @override
  State<BackgroundSelectorScreen> createState() =>
      _BackgroundSelectorScreenState();
}

class _BackgroundSelectorScreenState extends State<BackgroundSelectorScreen> {
  int _selectedIndex = 0;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final index = await BackgroundStorage.loadIndex();
    setState(() {
      _selectedIndex = index;
      _isLoaded = true;
    });
  }

  Future<void> _select(int index) async {
    setState(() => _selectedIndex = index);
    await BackgroundStorage.saveIndex(index);
    widget.onSelected(index); // ← notify MainShell immediately
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      extendBodyBehindAppBar: true,
      body: BackgroundManager(
        config: AppBackgrounds.all[_selectedIndex],
        child: SafeArea(

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── App bar ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.08),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.white.withOpacity(0.12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Customize",
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),


              //const Spacer(),
              SizedBox(height:30,),

              const Padding(
                padding: EdgeInsets.only( left:20, top: 16, bottom: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Themes",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 3,),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ],
                ),
              ),

              SizedBox(height:20,),
              SizedBox(
                height: 130,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: AppBackgrounds.all.length,
                  itemBuilder: (context, index) {
                    final isSelected = _selectedIndex == index;
                    return GestureDetector(
                      onTap: () => _select(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.all(8),
                        width: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? Colors.blue
                                : Colors.white24,
                            width: isSelected ? 3 : 1.5,
                          ),
                          boxShadow: isSelected
                              ? [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.4),
                              blurRadius: 12,
                              spreadRadius: 1,
                            )
                          ]
                              : [],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: _buildPreview(AppBackgrounds.all[index]),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),

              // Replace the entire Widgets Padding block with this:
              const Padding(
                padding: EdgeInsets.only(left: 20, top: 16, bottom: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Widgets",
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 3),
                    Icon(Icons.chevron_right_rounded, color: Colors.white, size: 24),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: (){
                          WidgetLauncher.showWidgetPicker(context, 'widget2');
                        },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF1A1A2E), Color(0xFF0D0D1A)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white.withOpacity(0.12), width: 1.5),
                            ),
                            child: const Text("Solid", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14), textAlign: TextAlign.center,),
                          ),
                        ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: (){
                          WidgetLauncher.showWidgetPicker(context, 'widget1');
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white.withOpacity(0.12), width: 1.5),
                              ),
                              child: const Text("Glass", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14), textAlign: TextAlign.center,),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreview(BackgroundConfig config) {
    switch (config.type) {
      case BackgroundType.image:
        return Image.asset(
          config.imagePath!,
          fit: BoxFit.cover,
        );

      case BackgroundType.lottie:
        return Lottie.asset(
          config.lottiePath!,
          fit: BoxFit.cover,
        );

      case BackgroundType.gradient:
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: config.gradientColors!,
              stops: config.gradientStops,
            ),
          ),
        );
    }
  }
}