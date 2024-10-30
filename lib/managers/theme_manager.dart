import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';



// Theme configuration class
class AppThemeConfig {
  final String id;
  final String name;
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final Color textColor;
  final Color dividerColor;
  final Color buttonColor;
  final Color buttonTextColor;
  final Color displayColor;
  final Color displayTextColor;
  final Color historyBackgroundColor;
  final Color historyTextColor;

  const AppThemeConfig({
    required this.id,
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.textColor,
    required this.dividerColor,
    required this.buttonColor,
    required this.buttonTextColor,
    required this.displayColor,
    required this.displayTextColor,
    required this.historyBackgroundColor,
    required this.historyTextColor,
  });

  // Convert theme to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'primaryColor': primaryColor.value,
      'secondaryColor': secondaryColor.value,
      'backgroundColor': backgroundColor.value,
      'textColor': textColor.value,
      'dividerColor': dividerColor.value,
      'buttonColor': buttonColor.value,
      'buttonTextColor': buttonTextColor.value,
      'displayColor': displayColor.value,
      'displayTextColor': displayTextColor.value,
      'historyBackgroundColor': historyBackgroundColor.value,
      'historyTextColor': historyTextColor.value,
    };
  }

  // Create theme from JSON
  factory AppThemeConfig.fromJson(Map<String, dynamic> json) {
    return AppThemeConfig(
      id: json['id'],
      name: json['name'],
      primaryColor: Color(json['primaryColor']),
      secondaryColor: Color(json['secondaryColor']),
      backgroundColor: Color(json['backgroundColor']),
      textColor: Color(json['textColor']),
      dividerColor: Color(json['dividerColor']),
      buttonColor: Color(json['buttonColor']),
      buttonTextColor: Color(json['buttonTextColor']),
      displayColor: Color(json['displayColor']),
      displayTextColor: Color(json['displayTextColor']),
      historyBackgroundColor: Color(json['historyBackgroundColor']),
      historyTextColor: Color(json['historyTextColor']),
    );
  }

  // Create a copy of theme with modifications
  AppThemeConfig copyWith({
    String? id,
    String? name,
    Color? primaryColor,
    Color? secondaryColor,
    Color? backgroundColor,
    Color? textColor,
    Color? dividerColor,
    Color? buttonColor,
    Color? buttonTextColor,
    Color? displayColor,
    Color? displayTextColor,
    Color? historyBackgroundColor,
    Color? historyTextColor,
  }) {
    return AppThemeConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      dividerColor: dividerColor ?? this.dividerColor,
      buttonColor: buttonColor ?? this.buttonColor,
      buttonTextColor: buttonTextColor ?? this.buttonTextColor,
      displayColor: displayColor ?? this.displayColor,
      displayTextColor: displayTextColor ?? this.displayTextColor,
      historyBackgroundColor: historyBackgroundColor ?? this.historyBackgroundColor,
      historyTextColor: historyTextColor ?? this.historyTextColor,
    );
  }
}

// Theme Manager
class ThemeManager extends ChangeNotifier {
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
  static final ThemeManager _instance = ThemeManager._internal();
  
  factory ThemeManager() {
    return _instance;
  }
  
  ThemeManager._internal();

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

// Theme Provider
class ThemeProvider extends StatelessWidget {
  final Widget child;
  final ThemeManager themeManager;

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
            brightness: themeManager.isDarkMode ? Brightness.dark : Brightness.light,
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
