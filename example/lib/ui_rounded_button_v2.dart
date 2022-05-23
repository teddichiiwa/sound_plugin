import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';

/// [UIRoundedButtonV2]
class UIRoundedButtonV2 extends StatelessWidget {
  /// button's width
  final double? width;

  /// button's height
  final double? height;

  /// corner radius
  final double cornerRadius;

  /// corner smoothing
  final double cornerSmoothing;

  /// on pressed callback
  final VoidCallback onPressed;

  /// child widget
  final Widget child;

  /// gradient
  final Gradient? gradient;

  /// background color
  final Color? color;

  /// Constructor
  const UIRoundedButtonV2({
    Key? key,
    this.width,
    this.height,
    this.cornerRadius = 4,
    this.cornerSmoothing = 1,
    required this.onPressed,
    required this.child,
    this.color,
    this.gradient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: ShapeDecoration(
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius(
            cornerRadius: cornerRadius,
            cornerSmoothing: cornerSmoothing,
          ),
        ),
        color: color,
        gradient: gradient,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          primary: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: child,
      ),
    );
  }
}
