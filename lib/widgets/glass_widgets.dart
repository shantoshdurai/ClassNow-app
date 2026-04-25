import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_test/app_theme.dart';

// ── Aurora background — three radial gradient blobs + dot grid ───────────────
// Used on the dark (Glass) theme for dashboard, settings, and login screens.
class AuroraBackground extends StatelessWidget {
  const AuroraBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Positioned.fill(
      child: RepaintBoundary(
        child: IgnorePointer(
        child: Stack(
          children: [
            if (isDark) ...[
              // Blue blob — top-right
              Positioned(
                top: -150,
                right: -100,
                child: _blob(
                  size: 500,
                  color: AppTheme.glassAccent.withOpacity(0.35),
                  blur: 90,
                ),
              ),
              // Magenta blob — mid-left
              Positioned(
                top: 200,
                left: -200,
                child: _blob(
                  size: 450,
                  color: const Color(0xFFB066FF).withOpacity(0.2),
                  blur: 80,
                ),
              ),
              // Cyan blob — bottom-right
              Positioned(
                bottom: -150,
                right: -100,
                child: _blob(
                  size: 400,
                  color: const Color(0xFF00F0FF).withOpacity(0.15),
                  blur: 70,
                ),
              ),
            ] else ...[
              // Paper mode: Soft warm amber blob
              Positioned(
                top: -100,
                right: -50,
                child: _blob(
                  size: 400,
                  color: AppTheme.paperAccent.withOpacity(0.08),
                  blur: 100,
                ),
              ),
              // Soft peach/cream blob bottom left
              Positioned(
                bottom: -50,
                left: -50,
                child: _blob(
                  size: 350,
                  color: const Color(0xFFF3E9DD).withOpacity(0.5),
                  blur: 80,
                ),
              ),
            ],
            // Subtle dot grid
            Opacity(
              opacity: isDark ? 0.08 : 0.15,
              child: CustomPaint(
                size: Size.infinite,
                painter: _DotGridPainter(color: isDark ? Colors.white : AppTheme.paperMuted),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _blob({required double size, required Color color, required double blur}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, Colors.transparent],
          stops: const [0.0, 0.65],
        ),
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  final Color color;
  _DotGridPainter({this.color = Colors.white});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    const spacing = 20.0;
    const radius = 0.6;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

/// Premium glassmorphism card widget with Apple-inspired design
class GlassCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Border? border;
  final List<BoxShadow>? shadows;

  const GlassCard({
    super.key,
    required this.child,
    this.blur = 10.0,
    this.opacity = 0.1,
    this.borderRadius,
    this.padding,
    this.margin,
    this.color,
    this.border,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Glass tokens for dark; Paper-surface tint for light
    final defaultColor = isDark
        ? Colors.white.withOpacity(opacity.clamp(0.01, 0.06))
        : AppTheme.paperSurface.withOpacity((opacity + 0.45).clamp(0.0, 1.0));

    final borderColor = isDark
        ? AppTheme.glassBorder2.withOpacity(0.12)
        : AppTheme.paperLine.withOpacity(0.6);

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(24),
        boxShadow: shadows ?? [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.45 : 0.06),
            blurRadius: 32,
            offset: const Offset(0, 12),
            spreadRadius: -8,
          ),
          if (!isDark)
            BoxShadow(
              color: AppTheme.paperAccent.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(24),
        child: Builder(
          builder: (context) {
            final content = Container(
              padding: padding ?? const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: color ?? defaultColor,
                borderRadius: borderRadius ?? BorderRadius.circular(24),
                border: border ?? Border.all(color: borderColor, width: 0.8),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          Colors.white.withOpacity(0.08),
                          Colors.white.withOpacity(0.02),
                        ]
                      : [
                          AppTheme.paperSurface.withOpacity(0.9),
                          AppTheme.paperSurface.withOpacity(0.7),
                        ],
                ),
              ),
              child: child,
            );
            if (!isDark) return content;
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
              child: content,
            );
          },
        ),
      ),
    );
  }
}

/// Animated gradient card with shimmer effect
class GradientCard extends StatefulWidget {
  final Widget child;
  final List<Color> gradientColors;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final bool animated;

  const GradientCard({
    super.key,
    required this.child,
    required this.gradientColors,
    this.padding,
    this.margin,
    this.borderRadius,
    this.animated = true,
  });

  @override
  State<GradientCard> createState() => _GradientCardState();
}

class _GradientCardState extends State<GradientCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    if (widget.animated) {
      _controller = AnimationController(
        duration: const Duration(seconds: 3),
        vsync: this,
      )..repeat(reverse: true);
      _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    }
  }

  @override
  void dispose() {
    if (widget.animated) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: widget.gradientColors.first.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
        child: widget.animated
            ? AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Container(
                    padding: widget.padding ?? const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(-1.0 + _animation.value * 2, -1.0),
                        end: Alignment(1.0 - _animation.value * 2, 1.0),
                        colors: widget.gradientColors,
                      ),
                    ),
                    child: widget.child,
                  );
                },
              )
            : Container(
                padding: widget.padding ?? const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: widget.gradientColors,
                  ),
                ),
                child: widget.child,
              ),
      ),
    );
  }
}

/// Neumorphic card with subtle depth
class NeumorphicCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final bool pressed;

  const NeumorphicCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.pressed = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1A1A1A) : const Color(0xFFE0E5EC);

    return Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: borderRadius ?? BorderRadius.circular(20),
        boxShadow: pressed
            ? [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.5)
                      : const Color(0xFFA3B1C6),
                  offset: const Offset(2, 2),
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: isDark ? Colors.white.withOpacity(0.03) : Colors.white,
                  offset: const Offset(-2, -2),
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
              ]
            : [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.5)
                      : const Color(0xFFA3B1C6),
                  offset: const Offset(8, 8),
                  blurRadius: 15,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                  offset: const Offset(-8, -8),
                  blurRadius: 15,
                  spreadRadius: 1,
                ),
              ],
      ),
      child: child,
    );
  }
}

/// Glowing card with luminous border
class GlowingCard extends StatelessWidget {
  final Widget child;
  final Color glowColor;
  final double glowRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;

  const GlowingCard({
    super.key,
    required this.child,
    required this.glowColor,
    this.glowRadius = 20,
    this.padding,
    this.margin,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.5),
            blurRadius: glowRadius,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: glowColor.withOpacity(0.3),
            blurRadius: glowRadius * 2,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: borderRadius ?? BorderRadius.circular(20),
          border: Border.all(color: glowColor.withOpacity(0.5), width: 2),
        ),
        child: child,
      ),
    );
  }
}

/// Premium button with glass effect
class GlassButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const GlassButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.color,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            child: Container(
              padding:
                  padding ??
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: (color ?? Theme.of(context).primaryColor).withOpacity(0.2),
                borderRadius: borderRadius ?? BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.5,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.15),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
