import 'package:flutter/cupertino.dart';

import 'package:myapp/screens/calculator_page.dart';

import 'managers/theme_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeManager = ThemeManager();
  await themeManager.initialize();

  runApp(CalculatorApp(themeManager: themeManager));
}

class CalculatorApp extends StatelessWidget {
  final ThemeManager themeManager;

  const CalculatorApp({super.key, required this.themeManager});

  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
      themeManager: themeManager,
      child: CupertinoApp(
        theme: CupertinoThemeData(
          brightness:
              themeManager.isDarkMode ? Brightness.dark : Brightness.light,
          primaryColor: themeManager.currentTheme.primaryColor,
        ),
        home: const CalculatorPage(),
      ),
    );
  }
}
