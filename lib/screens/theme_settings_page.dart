import 'package:calculator_plus_history_notes/managers/theme_notifier.dart';
import 'package:calculator_plus_history_notes/widgets/adaptive_card.dart';
import 'package:calculator_plus_history_notes/widgets/bouncing_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/app_theme_config_model.dart';
import '../widgets/reponsive_widget.dart';

class ThemeSettingsPage extends StatefulWidget {
  const ThemeSettingsPage({super.key});

  @override
  State<ThemeSettingsPage> createState() => _ThemeSettingsPageState();
}

class _ThemeSettingsPageState extends State<ThemeSettingsPage> {
  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeNotifier();
    final theme = themeManager.currentTheme;

    return CupertinoPageScaffold(
      backgroundColor: theme.backgroundColor,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: theme.backgroundColor.withOpacity(0.9),
        middle: Text(
          'Theme Settings',
          style: TextStyle(color: theme.textColor),
        ),
        border: null,
      ),
      child: ResponsiveLayout(
        padding: EdgeInsets.zero,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _buildContent(themeManager, theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ThemeNotifier themeManager, AppThemeConfig theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderSection(theme),
          const SizedBox(height: 24),
          _buildAppearanceSection(themeManager, theme),
          const SizedBox(height: 24),
          _buildThemesSection(themeManager, theme),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(AppThemeConfig theme) {
    return AdaptiveCard(
      padding: const EdgeInsets.all(20),
      backgroundColor: theme.displayColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.paintbrush,
                color: theme.primaryColor,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Personalization',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: theme.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Customize the appearance of your calculator with themes and color schemes.',
            style: TextStyle(
              fontSize: 16,
              color: theme.textColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceSection(
      ThemeNotifier themeManager, AppThemeConfig theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            'APPEARANCE',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: theme.primaryColor,
            ),
          ),
        ),
        AdaptiveCard(
          backgroundColor: theme.displayColor,
          padding: EdgeInsets.zero,
          child: CupertinoListTile(
            backgroundColor: theme.displayColor,
            leading: Icon(
              themeManager.isDarkMode
                  ? CupertinoIcons.moon_fill
                  : CupertinoIcons.sun_max_fill,
              color: theme.primaryColor,
            ),
            title: Text(
              'Dark Mode',
              style: TextStyle(color: theme.textColor),
            ),
            subtitle: Text(
              'Switch between light and dark themes',
              style: TextStyle(
                color: theme.textColor.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            trailing: BouncingButton(
              onPressed: () async {
                await themeManager.toggleDarkMode();
                setState(() {});
              },
              child: CupertinoSwitch(
                value: themeManager.isDarkMode,
                activeColor: theme.primaryColor,
                onChanged: (value) async {
                  await themeManager.toggleDarkMode();
                  setState(() {});
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThemesSection(ThemeNotifier themeManager, AppThemeConfig theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            'COLOR THEMES',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: theme.primaryColor,
            ),
          ),
        ),
        AdaptiveCard(
          backgroundColor: theme.displayColor,
          padding: EdgeInsets.zero,
          child: Column(
            children: themeManager.availableThemes.map((availableTheme) {
              final isSelected = availableTheme.id == theme.id;
              return BouncingButton(
                onPressed: () async {
                  await themeManager.setTheme(availableTheme.id);
                  setState(() {});
                },
                child: CupertinoListTile(
                  backgroundColor: Colors.transparent,
                  leading: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: availableTheme.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.textColor.withOpacity(0.1),
                        width: 2,
                      ),
                    ),
                  ),
                  title: Text(
                    availableTheme.name,
                    style: TextStyle(
                      color: theme.textColor,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  trailing: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: isSelected ? 1.0 : 0.0,
                    child: Icon(
                      CupertinoIcons.checkmark_circle_fill,
                      color: theme.primaryColor,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
