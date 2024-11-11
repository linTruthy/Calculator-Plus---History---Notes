import 'package:flutter/cupertino.dart';

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
      historyBackgroundColor:
          historyBackgroundColor ?? this.historyBackgroundColor,
      historyTextColor: historyTextColor ?? this.historyTextColor,
    );
  }
}
