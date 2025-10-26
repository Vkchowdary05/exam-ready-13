import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Enhanced animated button with scale, haptic feedback, and accessibility
class AnimatedScaleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Duration duration;
  final double scaleFactor;
  final bool enableHapticFeedback;
  final String? semanticLabel;

  const AnimatedScaleButton({
    super.key,
    required this.child,
    this.onPressed,
    this.isLoading = false,
    this.duration = const Duration(milliseconds: 150),
    this.scaleFactor = 0.95,
    this.enableHapticFeedback = true,
    this.semanticLabel,
  });

  @override
  State<AnimatedScaleButton> createState() => _AnimatedScaleButtonState();
}

class _AnimatedScaleButtonState extends State<AnimatedScaleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleFactor,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() {
        _isPressed = true;
      });
      _controller.forward();

      if (widget.enableHapticFeedback) {
        HapticFeedback.lightImpact();
      }
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _handleTapEnd();
  }

  void _handleTapCancel() {
    _handleTapEnd();
  }

  void _handleTapEnd() {
    if (_isPressed) {
      setState(() {
        _isPressed = false;
      });
      _controller.reverse();

      if (widget.onPressed != null && !widget.isLoading) {
        widget.onPressed!();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.semanticLabel,
      button: true,
      enabled: widget.onPressed != null && !widget.isLoading,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: widget.isLoading ? 0.7 : 1.0,
                child: widget.child,
              ),
            );
          },
        ),
      ),
    );
  }
}
