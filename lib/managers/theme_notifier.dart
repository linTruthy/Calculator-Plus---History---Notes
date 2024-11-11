import 'package:calculator_plus_history_notes/models/app_theme_config_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends ChangeNotifier {
  static const String _themePreferenceKey = 'selected_theme';
  static const String _isDarkModeKey = 'is_dark_mode';

  late SharedPreferences _prefs;
  bool _isDarkMode = false;
  String _currentThemeId = 'default';

  // Predefined themes
  final Map<String, AppThemeConfig> _themes = {
    'default': const AppThemeConfig(
      id: 'default',
      name: 'Default Light',
      primaryColor: CupertinoColors.systemBlue,
      secondaryColor: CupertinoColors.systemGrey,
      backgroundColor: CupertinoColors.systemBackground,
      textColor: CupertinoColors.black,
      dividerColor: CupertinoColors.separator,
      buttonColor: CupertinoColors.systemGrey6,
      buttonTextColor: CupertinoColors.black,
      displayColor: CupertinoColors.white,
      displayTextColor: CupertinoColors.black,
      historyBackgroundColor: CupertinoColors.systemBackground,
      historyTextColor: CupertinoColors.black,
    ),
    'default_dark': AppThemeConfig(
      id: 'default_dark',
      name: 'Default Dark',
      primaryColor: CupertinoColors.systemBlue,
      secondaryColor: CupertinoColors.systemGrey,
      backgroundColor: CupertinoColors.black,
      textColor: CupertinoColors.white,
      dividerColor: CupertinoColors.separator,
      buttonColor: CupertinoColors.systemGrey6.darkColor,
      buttonTextColor: CupertinoColors.white,
      displayColor: CupertinoColors.black,
      displayTextColor: CupertinoColors.white,
      historyBackgroundColor: CupertinoColors.black,
      historyTextColor: CupertinoColors.white,
    ),
    'blue': AppThemeConfig(
      id: 'blue',
      name: 'Blue Theme',
      primaryColor: CupertinoColors.systemBlue,
      secondaryColor: CupertinoColors.systemIndigo,
      backgroundColor: const Color(0xFFF5F9FF),
      textColor: CupertinoColors.black,
      dividerColor: CupertinoColors.systemBlue.withOpacity(0.2),
      buttonColor: CupertinoColors.white,
      buttonTextColor: CupertinoColors.black,
      displayColor: CupertinoColors.white,
      displayTextColor: CupertinoColors.black,
      historyBackgroundColor: CupertinoColors.white,
      historyTextColor: CupertinoColors.black,
    ),
    'dark_blue': AppThemeConfig(
      id: 'dark_blue',
      name: 'Dark Blue Theme',
      primaryColor: CupertinoColors.systemBlue,
      secondaryColor: CupertinoColors.systemIndigo,
      backgroundColor: const Color(0xFF1A1B1E),
      textColor: CupertinoColors.white,
      dividerColor: CupertinoColors.systemBlue.withOpacity(0.2),
      buttonColor: const Color(0xFF2D2F34),
      buttonTextColor: CupertinoColors.white,
      displayColor: const Color(0xFF2D2F34),
      displayTextColor: CupertinoColors.white,
      historyBackgroundColor: const Color(0xFF2D2F34),
      historyTextColor: CupertinoColors.white,
    ),
  };

  // Singleton pattern
  static final ThemeNotifier _instance = ThemeNotifier._internal();

  factory ThemeNotifier() {
    return _instance;
  }

  ThemeNotifier._internal();

  // Initialize theme manager
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _loadThemePreferences();
  }

  // Load saved theme preferences
  void _loadThemePreferences() {
    _isDarkMode = _prefs.getBool(_isDarkModeKey) ?? false;
    _currentThemeId = _prefs.getString(_themePreferenceKey) ??
        (_isDarkMode ? 'default_dark' : 'default');
    notifyListeners();
  }

  // Get current theme
  AppThemeConfig get currentTheme {
    return _themes[_currentThemeId] ?? _themes['default']!;
  }

  // Get all available themes
  List<AppThemeConfig> get availableThemes {
    return _isDarkMode
        ? _themes.values.where((theme) => theme.id.contains('dark')).toList()
        : _themes.values.where((theme) => !theme.id.contains('dark')).toList();
  }

  // Check if dark mode is enabled
  bool get isDarkMode => _isDarkMode;

  // Toggle dark mode
  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    await _prefs.setBool(_isDarkModeKey, _isDarkMode);

    // Switch to corresponding theme
    if (_isDarkMode && !_currentThemeId.contains('dark')) {
      await setTheme('default_dark');
    } else if (!_isDarkMode && _currentThemeId.contains('dark')) {
      await setTheme('default');
    }

    notifyListeners();
  }

  // Set theme by ID
  Future<void> setTheme(String themeId) async {
    if (_themes.containsKey(themeId)) {
      _currentThemeId = themeId;
      await _prefs.setString(_themePreferenceKey, themeId);
      notifyListeners();
    }
  }

  // Add custom theme
  void addCustomTheme(AppThemeConfig theme) {
    _themes[theme.id] = theme;
    notifyListeners();
  }
}
