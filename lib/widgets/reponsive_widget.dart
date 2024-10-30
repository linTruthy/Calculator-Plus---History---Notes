import 'package:flutter/cupertino.dart';
import 'dart:math' as math;

/// ResponsiveLayout provides adaptive sizing based on screen dimensions
class ResponsiveLayout extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final bool safeArea;

  const ResponsiveLayout({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.safeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    final height = mediaQuery.size.height;
    
    Widget content = ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: math.min(width, 800), // Max width for large screens
        maxHeight: height,
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );

    if (safeArea) {
      content = SafeArea(child: content);
    }

    return Center(child: content);
  }
}

/// CustomPageRoute provides a customizable page transition
class CustomPageRoute extends CupertinoPageRoute {
  final bool slideUp;

  CustomPageRoute({
    required Widget child,
    this.slideUp = false,
  }) : super(
    builder: (context) => child,
    fullscreenDialog: slideUp,
  );
}

/// AdaptiveCard provides a consistent card design across the app
class AdaptiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;
  final Color? backgroundColor;
  final List<BoxShadow>? boxShadow;

  const AdaptiveCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 12,
    this.backgroundColor,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? (isDark ? CupertinoColors.systemGrey6.darkColor : CupertinoColors.white),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: boxShadow ?? [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: padding,
      child: child,
    );
  }
}

/// BouncingButton provides a physical button press animation
class BouncingButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final Duration duration;
  final double scale;

  const BouncingButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.duration = const Duration(milliseconds: 150),
    this.scale = 0.95,
  });

  @override
  State<BouncingButton> createState() => _BouncingButtonState();
}

class _BouncingButtonState extends State<BouncingButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scale,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(_) {
    _controller.forward();
  }

  void _handleTapUp(_) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onPressed,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}

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
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}

/// ResponsiveGrid provides a responsive grid layout
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final int minCrossAxisCount;
  final int maxCrossAxisCount;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 16,
    this.runSpacing = 16,
    this.minCrossAxisCount = 2,
    this.maxCrossAxisCount = 6,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = math.min(
          math.max(
            (width / 150).floor(), // Minimum item width of 150
            minCrossAxisCount,
          ),
          maxCrossAxisCount,
        );

        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: children.map((child) {
            final itemWidth = (width - (spacing * (crossAxisCount - 1))) / crossAxisCount;
            return SizedBox(
              width: itemWidth,
              child: child,
            );
          }).toList(),
        );
      },
    );
  }
}

/// SpringScrollConfiguration provides iOS-style scrolling
class SpringScrollConfiguration extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics();
  }
}

/// AdaptiveSegmentedControl provides a themed segmented control
class AdaptiveSegmentedControl extends StatelessWidget {
  final Map<int, Widget> children;
  final int groupValue;
  final ValueChanged<int> onValueChanged;

  const AdaptiveSegmentedControl({
    super.key,
    required this.children,
    required this.groupValue,
    required this.onValueChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoSegmentedControl<int>(
      children: children,
      groupValue: groupValue,
      onValueChanged: onValueChanged,
      padding: EdgeInsets.zero,
    );
  }
}