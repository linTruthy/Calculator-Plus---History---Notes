import 'package:calculator_plus_history_notes/screens/calculator_page.dart';
import 'package:calculator_plus_history_notes/managers/theme_notifier.dart';
import 'package:flutter/cupertino.dart';

class CalculatorApp extends StatelessWidget {
  final ThemeNotifier themeManager;

  const CalculatorApp({super.key, required this.themeManager});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      theme: CupertinoThemeData(
        brightness:
            themeManager.isDarkMode ? Brightness.dark : Brightness.light,
        primaryColor: themeManager.currentTheme.primaryColor,
      ),
      home: const CalculatorPage(),
    );
  }
}
