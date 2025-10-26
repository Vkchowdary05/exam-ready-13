import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import 'animated_scale_button.dart';

class GradientButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Gradient? gradient;
  final double? width;
  final double height;
  final IconData? icon;
  final bool enableHapticFeedback;
  final String? semanticLabel;

  const GradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.gradient,
    this.width,
    this.height = 56,
    this.icon,
    this.enableHapticFeedback = true,
    this.semanticLabel,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  void _handleTap() {
    if (widget.onPressed != null && !widget.isLoading) {
      if (widget.enableHapticFeedback) {
        HapticFeedback.lightImpact();
      }
      widget.onPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScaleButton(
      onPressed: widget.onPressed != null && !widget.isLoading
          ? _handleTap
          : null,
      isLoading: widget.isLoading,
      enableHapticFeedback: widget.enableHapticFeedback,
      semanticLabel: widget.semanticLabel,
      child: Container(
        width: widget.width ?? double.infinity,
        height: widget.height,
        decoration: BoxDecoration(
          gradient: widget.gradient ?? AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.buttonShadow,
        ),
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, color: Colors.white, size: 22),
                        const SizedBox(width: 8),
                      ],
                      Text(widget.text, style: AppTheme.buttonTextStyle),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
