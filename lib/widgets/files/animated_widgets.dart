// ========================================
// ANIMATED WIDGETS & COMPONENTS
// ========================================
// Reusable animated components for smooth UI

import 'package:flutter/material.dart';
import 'dart:math' as math;

// ========================================
// 1. SHIMMER LOADING EFFECT
// ========================================
class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  final Color? baseColor;
  final Color? highlightColor;
  
  const ShimmerLoading({
    super.key,
    required this.child,
    this.isLoading = true,
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return widget.child;
    }

    final theme = Theme.of(context);
    final baseColor = widget.baseColor ?? theme.cardColor;
    final highlightColor = widget.highlightColor ?? 
        theme.cardColor.withOpacity(0.7);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [
                math.max(0, _controller.value - 0.3),
                _controller.value,
                math.min(_controller.value + 0.3, 1),
              ],
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
    );
  }
}

// ========================================
// 2. STAGGERED ANIMATION BUILDER
// ========================================
class StaggeredAnimation extends StatelessWidget {
  final int index;
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Curve curve;
  final Offset? slideFrom;
  
  const StaggeredAnimation({
    super.key,
    required this.index,
    required this.child,
    this.delay = const Duration(milliseconds: 50),
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeOutCubic,
    this.slideFrom,
  });

  @override
  Widget build(BuildContext context) {
    final itemDelay = delay * index;
    
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0.0, end: 1.0),
      curve: curve,
      builder: (context, value, child) {
        final delayedValue = (value - (itemDelay.inMilliseconds / duration.inMilliseconds))
            .clamp(0.0, 1.0);
        
        return Transform.translate(
          offset: slideFrom != null
              ? Offset(
                  slideFrom!.dx * (1 - delayedValue),
                  slideFrom!.dy * (1 - delayedValue),
                )
              : Offset(0, 20 * (1 - delayedValue)),
          child: Opacity(
            opacity: delayedValue,
            child: this.child,
          ),
        );
      },
      child: child,
    );
  }
}

// ========================================
// 3. ANIMATED CLASS CARD
// ========================================
class AnimatedClassCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isCurrentClass;
  
  const AnimatedClassCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.isCurrentClass = false,
  });

  @override
  State<AnimatedClassCard> createState() => _AnimatedClassCardState();
}

class _AnimatedClassCardState extends State<AnimatedClassCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onLongPress: widget.onLongPress,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: widget.isCurrentClass
                    ? [
                        BoxShadow(
                          color: theme.primaryColor.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}

// ========================================
// 4. PULSING DOT INDICATOR
// ========================================
class PulsingDot extends StatefulWidget {
  final Color color;
  final double size;
  
  const PulsingDot({
    super.key,
    this.color = Colors.red,
    this.size = 8.0,
  });

  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.color.withOpacity(_animation.value),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.5 * _animation.value),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        );
      },
    );
  }
}

// ========================================
// 5. ANIMATED PROGRESS BAR
// ========================================
class AnimatedProgressBar extends StatefulWidget {
  final double value;
  final Color? color;
  final Color? backgroundColor;
  final double height;
  final BorderRadius? borderRadius;
  final Duration duration;
  
  const AnimatedProgressBar({
    super.key,
    required this.value,
    this.color,
    this.backgroundColor,
    this.height = 6.0,
    this.borderRadius,
    this.duration = const Duration(milliseconds: 500),
  });

  @override
  State<AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _previousValue = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = Tween<double>(begin: 0.0, end: widget.value).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _previousValue = oldWidget.value;
      _animation = Tween<double>(
        begin: _previousValue,
        end: widget.value,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? 
                theme.primaryColor.withOpacity(0.1),
            borderRadius: widget.borderRadius ?? 
                BorderRadius.circular(widget.height / 2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _animation.value.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: widget.color ?? theme.primaryColor,
                borderRadius: widget.borderRadius ?? 
                    BorderRadius.circular(widget.height / 2),
                boxShadow: [
                  BoxShadow(
                    color: (widget.color ?? theme.primaryColor)
                        .withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ========================================
// 6. BOUNCE IN ANIMATION
// ========================================
class BounceIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  
  const BounceIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  State<BounceIn> createState() => _BounceInState();
}

class _BounceInState extends State<BounceIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.1), weight: 0.6),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 0.95), weight: 0.2),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.0), weight: 0.2),
    ]).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: widget.child,
          ),
        );
      },
    );
  }
}

// ========================================
// 7. SLIDE FADE TRANSITION
// ========================================
class SlideFade extends StatefulWidget {
  final Widget child;
  final Offset begin;
  final Duration delay;
  final Duration duration;
  final Curve curve;
  
  const SlideFade({
    super.key,
    required this.child,
    this.begin = const Offset(0, 0.5),
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<SlideFade> createState() => _SlideFadeState();
}

class _SlideFadeState extends State<SlideFade>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    
    _slideAnimation = Tween<Offset>(
      begin: widget.begin,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: widget.child,
      ),
    );
  }
}

// ========================================
// 8. RIPPLE EFFECT CONTAINER
// ========================================
class RippleContainer extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? rippleColor;
  final BorderRadius? borderRadius;
  
  const RippleContainer({
    super.key,
    required this.child,
    this.onTap,
    this.rippleColor,
    this.borderRadius,
  });

  @override
  State<RippleContainer> createState() => _RippleContainerState();
}

class _RippleContainerState extends State<RippleContainer> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
        splashColor: widget.rippleColor?.withOpacity(0.3) ?? 
            Theme.of(context).primaryColor.withOpacity(0.2),
        highlightColor: widget.rippleColor?.withOpacity(0.1) ?? 
            Theme.of(context).primaryColor.withOpacity(0.1),
        child: widget.child,
      ),
    );
  }
}

// ========================================
// 9. ANIMATED BADGE
// ========================================
class AnimatedBadge extends StatefulWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  
  const AnimatedBadge({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.icon,
  });

  @override
  State<AnimatedBadge> createState() => _AnimatedBadgeState();
}

class _AnimatedBadgeState extends State<AnimatedBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.2), weight: 0.6),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 0.4),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? theme.primaryColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (widget.backgroundColor ?? theme.primaryColor)
                  .withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.icon != null) ...[
              Icon(
                widget.icon,
                size: 14,
                color: widget.textColor ?? theme.primaryColor,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
                color: widget.textColor ?? theme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ========================================
// 10. FLOATING ANIMATION
// ========================================
class FloatingAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double distance;
  
  const FloatingAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 2),
    this.distance = 10.0,
  });

  @override
  State<FloatingAnimation> createState() => _FloatingAnimationState();
}

class _FloatingAnimationState extends State<FloatingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 0.0, end: widget.distance).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -_animation.value),
          child: widget.child,
        );
      },
    );
  }
}
