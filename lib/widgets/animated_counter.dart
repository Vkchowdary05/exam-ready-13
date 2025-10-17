/// Reusable animated counter widget that counts up to a target value.
/// Includes scale and opacity animations for a polished entrance effect.

import 'package:flutter/material.dart';

class AnimatedCounter extends StatefulWidget {
  final int targetValue;
  final Duration duration;
  final TextStyle? textStyle;
  final String label;
  final TextStyle? labelStyle;

  const AnimatedCounter({
    Key? key,
    required this.targetValue,
    this.duration = const Duration(milliseconds: 1500),
    this.textStyle,
    this.label = '',
    this.labelStyle,
  }) : super(key: key);

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _countAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // Set up animation controller (total duration includes scale/fade-in).
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    // Counter animation: animates from 0 to targetValue over the full duration.
    _countAnimation = IntTween(
      begin: 0,
      end: widget.targetValue,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    // Scale animation: pops in from 0.8 to 1.0 in the first 600ms.
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.elasticOut),
      ),
    );

    // Opacity animation: fades in from 0 to 1 in the first 400ms.
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    // Start animation when widget is built.
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If target value changed, restart animation.
    if (oldWidget.targetValue != widget.targetValue) {
      _controller.reset();
      _countAnimation = IntTween(
        begin: 0,
        end: widget.targetValue,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _countAnimation,
        _scaleAnimation,
        _opacityAnimation,
      ]),
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Large counter number
                Text(
                  '${_countAnimation.value}',
                  style: widget.textStyle ??
                      Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                  semanticsLabel: '${_countAnimation.value} exam papers posted',
                ),
                if (widget.label.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    widget.label,
                    style: widget.labelStyle ??
                        Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}