import 'package:calculator_plus_history_notes/managers/theme_notifier.dart';
import 'package:flutter/cupertino.dart';

class ThemeProvider extends StatelessWidget {
  final Widget child;
  final ThemeNotifier themeManager;

  const ThemeProvider({
    super.key,
    required this.child,
    required this.themeManager,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeManager,
      builder: (context, _) {
        return CupertinoTheme(
          data: CupertinoThemeData(
            brightness:
                themeManager.isDarkMode ? Brightness.dark : Brightness.light,
            primaryColor: themeManager.currentTheme.primaryColor,
            scaffoldBackgroundColor: themeManager.currentTheme.backgroundColor,
            textTheme: CupertinoTextThemeData(
              primaryColor: themeManager.currentTheme.textColor,
            ),
          ),
          child: child,
        );
      },
    );
  }
}
