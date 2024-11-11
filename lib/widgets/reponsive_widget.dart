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
            final itemWidth =
                (width - (spacing * (crossAxisCount - 1))) / crossAxisCount;
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

