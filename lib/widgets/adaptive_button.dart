import 'package:calculator_plus_history_notes/widgets/bouncing_button.dart';
import 'package:flutter/cupertino.dart';

/// AdaptiveButton provides a consistent button design
class AdaptiveButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsets padding;
  final double borderRadius;
  final bool isDestructive;
  final bool isLoading;

  const AdaptiveButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    this.borderRadius = 12,
    this.isDestructive = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    
    final baseColor = backgroundColor ?? 
      (isDestructive ? CupertinoColors.systemRed : theme.primaryColor);
    
    final buttonTextColor = textColor ?? 
      (backgroundColor != null ? theme.primaryContrastingColor : CupertinoColors.white);

    return BouncingButton(
      onPressed: isLoading ? () {} : onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: isLoading ? baseColor.withOpacity(0.6) : baseColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: padding,
        child: Center(
          child: isLoading
              ? const CupertinoActivityIndicator(color: CupertinoColors.white)
              : Text(
                  text,
                  style: TextStyle(
                    color: buttonTextColor,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}
