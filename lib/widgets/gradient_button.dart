import 'package:flutter/material.dart';
import 'package:pingme/config/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Gradient button with scale animation on tap
class GradientButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Gradient? gradient;
  final IconData? icon;
  final bool isLoading;
  final double? width;

  const GradientButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.gradient,
    this.icon,
    this.isLoading = false,
    this.width,
  }) : super(key: key);

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        if (!widget.isLoading) {
          widget.onPressed();
        }
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: widget.width ?? double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing32,
            vertical: AppTheme.spacing16,
          ),
          decoration: BoxDecoration(
            gradient: widget.gradient ?? AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            boxShadow: AppTheme.elevatedShadow,
          ),
          child: widget.isLoading
              ? const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(
                        widget.icon,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: AppTheme.spacing12),
                    ],
                    Text(
                      widget.text,
                      style: AppTheme.button.copyWith(color: Colors.white),
                    ),
                  ],
                ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0);
  }
}
