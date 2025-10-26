import 'package:flutter/material.dart';

/// Modern loading indicators with various styles
class ModernLoadingIndicator extends StatefulWidget {
  final LoadingType type;
  final Color? color;
  final double size;
  final String? message;

  const ModernLoadingIndicator({
    super.key,
    this.type = LoadingType.spinner,
    this.color,
    this.size = 24.0,
    this.message,
  });

  @override
  State<ModernLoadingIndicator> createState() => _ModernLoadingIndicatorState();
}

class _ModernLoadingIndicatorState extends State<ModernLoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).primaryColor;

    Widget indicator;
    switch (widget.type) {
      case LoadingType.spinner:
        indicator = _buildSpinner(color);
        break;
      case LoadingType.dots:
        indicator = _buildDots(color);
        break;
      case LoadingType.pulse:
        indicator = _buildPulse(color);
        break;
      case LoadingType.wave:
        indicator = _buildWave(color);
        break;
    }

    if (widget.message != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          indicator,
          const SizedBox(height: 16),
          Text(
            widget.message!,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return indicator;
  }

  Widget _buildSpinner(Color color) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: CircularProgressIndicator(color: color, strokeWidth: 2.5),
    );
  }

  Widget _buildDots(Color color) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final animationValue = (_animation.value - delay).clamp(0.0, 1.0);
            final scale = 0.5 + (0.5 * (1 - (animationValue - 0.5).abs() * 2));

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: widget.size * 0.3,
              height: widget.size * 0.3,
              decoration: BoxDecoration(
                color: color.withValues(alpha: scale),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildPulse(Color color) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * _animation.value),
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 1.0 - _animation.value),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildWave(Color color) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            final delay = index * 0.1;
            final animationValue = (_animation.value - delay).clamp(0.0, 1.0);
            final height =
                widget.size *
                (0.3 + 0.7 * (1 - (animationValue - 0.5).abs() * 2));

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              width: widget.size * 0.15,
              height: height,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      },
    );
  }
}

enum LoadingType { spinner, dots, pulse, wave }

/// Full screen loading overlay
class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? message;
  final LoadingType type;
  final Color? backgroundColor;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.message,
    this.type = LoadingType.spinner,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: backgroundColor ?? Colors.black.withValues(alpha: 0.5),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ModernLoadingIndicator(type: type, message: message),
              ),
            ),
          ),
      ],
    );
  }
}
