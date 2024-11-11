import 'package:calculator_plus_history_notes/calculator_app.dart';
import 'package:calculator_plus_history_notes/managers/theme_notifier.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart'; // Import the Provider package

import 'services/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeManager = ThemeNotifier();
  await themeManager.initialize();

  runApp(
    ChangeNotifierProvider( // Wrap your app with ChangeNotifierProvider
      create: (context) => themeManager, // Provide the themeManager instance
      child: ThemeProvider(
        themeManager: themeManager,
        child: CalculatorApp(themeManager: themeManager),
      ),
    ),
  );
}
