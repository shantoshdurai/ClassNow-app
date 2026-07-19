import 'dart:ui';
import 'package:flutter/material.dart';

class MorphicNavigationBar extends StatefulWidget {
  final bool hasUnreadAnnouncements;
  final VoidCallback onAnnouncementTap;
  final VoidCallback onAITap;

  const MorphicNavigationBar({
    Key? key,
    required this.hasUnreadAnnouncements,
    required this.onAnnouncementTap,
    required this.onAITap,
  }) : super(key: key);

  @override
  State<MorphicNavigationBar> createState() => _MorphicNavigationBarState();
}

class _MorphicNavigationBarState extends State<MorphicNavigationBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Colors matching the design handoff
    final pillBg = isDark
        ? [const Color(0xCF1C1E26), const Color(0xD10E1016)]
        : [const Color(0xEBF6F2EA), const Color(0xE1F8F3E8)]; // paper light
    final pillBorder = isDark ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.06);
    final pillBorderTop = isDark ? Colors.white.withOpacity(0.22) : Colors.white.withOpacity(0.9);
    final shadowColor = isDark ? Colors.black.withOpacity(0.65) : const Color.fromARGB(82, 40, 30, 20);
    
    final fabBg = isDark 
        ? [Colors.white, const Color(0xFFF0F0F2)] 
        : [const Color(0xFF1B1916), const Color(0xFF0E0D0B)];
    final fabRing = isDark ? Colors.white.withOpacity(0.18) : Colors.white.withOpacity(0.18);
    final fabIconColor = isDark ? const Color(0xFF0E1016) : const Color(0xFFFBF8F1);
    
    // Remove ugly brown/amber glow in light mode
    final fabHalo = isDark ? const Color(0x8C65B0FF) : Colors.transparent;
    
    final iconColor = isDark ? const Color(0xFFD7D9E0) : const Color(0xFF3C382F);

    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: 280, // Restrict width to avoid taking up full bottom
          margin: const EdgeInsets.only(bottom: 20),
          height: 64,
          child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Pill Container
            ClipRRect(
              borderRadius: BorderRadius.circular(36),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(36),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: pillBg,
                    ),
                    border: Border(
                      top: BorderSide(color: pillBorderTop),
                      bottom: BorderSide(color: pillBorder),
                      left: BorderSide(color: pillBorder),
                      right: BorderSide(color: pillBorder),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: shadowColor,
                        blurRadius: 36,
                        spreadRadius: -10,
                        offset: const Offset(0, 18),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      // Left: Announcements
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: const BorderRadius.horizontal(left: Radius.circular(36)),
                            onTap: widget.onAnnouncementTap,
                            child: Center(
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Icon(Icons.campaign_rounded, color: iconColor, size: 26),
                                  if (widget.hasUnreadAnnouncements)
                                    Positioned(
                                      right: -2,
                                      top: -2,
                                      child: Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: isDark ? const Color(0xFFE84C3D) : const Color(0xFFD94536),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isDark ? const Color(0xFF15171F) : const Color(0xFFFBF8F1),
                                            width: 1.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      // Space for Center FAB
                      const Expanded(child: SizedBox()),

                      // Right: AI Assistant
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: const BorderRadius.horizontal(right: Radius.circular(36)),
                            onTap: widget.onAITap,
                            child: Center(
                              child: Icon(Icons.auto_awesome_rounded, color: iconColor, size: 24),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Center FAB (Home)
            Positioned(
              left: 0,
              right: 0,
              top: -16, // Elevated
              child: GestureDetector(
                onTap: () {
                  // Home is already active on Dashboard
                },
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Aurora halo pulse
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 1.0 + (_pulseController.value * 0.08),
                            child: Opacity(
                              opacity: 0.55 + (_pulseController.value * 0.35),
                              child: Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: fabHalo,
                                      blurRadius: 16,
                                      spreadRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      
                      // FAB Button
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: fabBg,
                          ),
                          border: Border.all(color: fabRing, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: isDark ? const Color(0x66000000) : const Color(0x33000000),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.home_rounded,
                            color: fabIconColor,
                            size: 28,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
