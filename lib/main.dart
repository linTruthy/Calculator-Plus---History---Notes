import 'package:calculator_plus_history_notes/calculator_app.dart';
import 'package:calculator_plus_history_notes/managers/theme_notifier.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart'; // Import the Provider package

import 'services/ad_manager.dart';
import 'services/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize AdManager
  if (!kIsWeb) {
    await AdManager().initialize();
  }

  final themeManager = ThemeNotifier();
  await themeManager.initialize();

  runApp(
    ChangeNotifierProvider(
      create: (context) => themeManager,
      child: ThemeProvider(
        themeManager: themeManager,
        child: CalculatorApp(themeManager: themeManager),
      ),
    ),
  );
}
