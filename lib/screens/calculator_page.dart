import 'package:calculator_plus_history_notes/managers/theme_notifier.dart';
import 'package:calculator_plus_history_notes/widgets/adaptive_button.dart';
import 'package:calculator_plus_history_notes/widgets/adaptive_card.dart';
import 'package:calculator_plus_history_notes/widgets/bouncing_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/ad_manager.dart';
import '../models/app_theme_config_model.dart';
import '../models/history_item.dart';
import '../widgets/ad_banner_widget.dart';
import '../widgets/reponsive_widget.dart';
import 'theme_settings_page.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage>
    with SingleTickerProviderStateMixin {
  String _display = '0';
  String _equation = '';
  double _result = 0;
  List<HistoryItem> _history = [];
  final TextEditingController _nameController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isHistoryVisible = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    AdManager().dispose();
    _animationController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _addNumber(String number) {
    _animationController.reset();
    _animationController.forward();
    setState(() {
      if (_display == '0') {
        _display = number;
      } else {
        _display += number;
      }
      _equation = _display;
    });
  }

  void _addOperator(String operator) {
    _animationController.reset();
    _animationController.forward();
    setState(() {
      _display += ' $operator ';
      _equation = _display;
    });
  }

  void _calculate() {
    try {
      final parts = _equation.split(' ');
      if (parts.length >= 3) {
        final num1 = double.parse(parts[0]);
        final operator = parts[1];
        final num2 = double.parse(parts[2]);

        switch (operator) {
          case '+':
            _result = num1 + num2;
            break;
          case '-':
            _result = num1 - num2;
            break;
          case '×':
            _result = num1 * num2;
            break;
          case '÷':
            if (num2 != 0) {
              _result = num1 / num2;
            } else {
              throw Exception('Division by zero');
            }
            break;
        }

        _animationController.reset();
        _animationController.forward();

        setState(() {
          _display = _formatResult(_result);
          _addToHistory();
          _equation = _result.toString();
        });
        if (!kIsWeb) {
          AdManager().onCalculationPerformed();
        }
      }
    } catch (e) {
      setState(() {
        _display =
            e.toString().contains('zero') ? 'Cannot divide by zero' : 'Error';
      });
    }
  }

  String _formatResult(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value
        .toStringAsFixed(6)
        .replaceAll(RegExp(r'0*$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  void _clear() {
    _animationController.reset();
    _animationController.forward();
    setState(() {
      _display = '0';
      _equation = '';
      _result = 0;
    });
  }

  void _addToHistory() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Save Calculation'),
        message: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: CupertinoTextField(
            controller: _nameController,
            placeholder: 'Enter a name (optional)',
            decoration: BoxDecoration(
              color: CupertinoColors.systemBackground,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _saveToHistory(_nameController.text);
            },
            child: const Text('Save'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            _saveToHistory('');
          },
          isDestructiveAction: true,
          child: const Text('Skip'),
        ),
      ),
    );
  }

  void _saveToHistory(String name) {
    setState(() {
      _history.insert(
        0,
        HistoryItem(
          equation: _equation,
          result: _result,
          timestamp: DateTime.now(),
          name: name.isNotEmpty ? name : null,
        ),
      );
      _nameController.clear();
    });
  }

  void _recallHistory(HistoryItem item) {
    _animationController.reset();
    _animationController.forward();
    setState(() {
      _display = item.result.toString();
      _equation = item.result.toString();
      _result = item.result;
      _isHistoryVisible = false;
    });
  }

  void _deleteHistoryItem(int index) {
    setState(() {
      _history.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeNotifier>(context);
    final theme = themeManager.currentTheme;
    return CupertinoPageScaffold(
      backgroundColor: theme.backgroundColor,
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Calculator Plus - History & Notes'),
        trailing: _buildNavigationButtons(theme),
      ),
      child: ResponsiveLayout(
        padding: EdgeInsets.zero,
        child: ScrollConfiguration(
          behavior: SpringScrollConfiguration(),
          child: Stack(
            children: [
              Column(
                children: [
                  _buildDisplay(theme),
                  Expanded(
                    flex: 4,
                    child: AdaptiveCard(
                      padding: const EdgeInsets.all(8),
                      borderRadius: 20,
                      backgroundColor: theme.backgroundColor,
                      child: _buildKeypad(theme),
                    ),
                  ),
                  if (!kIsWeb) const AdBannerWidget(),
                ],
              ),
              if (_isHistoryVisible) _buildHistoryPanel(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad(AppThemeConfig theme) {
    return ResponsiveGrid(
      spacing: 5,
      runSpacing: 5,
      minCrossAxisCount: 4,
      maxCrossAxisCount: 4,
      children: [
        ...['7', '8', '9', '÷'],
        ...['4', '5', '6', '×'],
        ...['1', '2', '3', '-'],
        ...['C', '0', '=', '+'],
      ].map((button) => _buildButton(button, theme)).toList(),
    );
  }

  Widget _buildDisplay(AppThemeConfig theme) {
    return Expanded(
      flex: 2,
      child: AdaptiveCard(
        //margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        backgroundColor: theme.displayColor,
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _equation,
              style: TextStyle(
                fontSize: 20,
                color: theme.displayTextColor.withOpacity(0.7),
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 8),
            FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                _display,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: theme.displayTextColor,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(AppThemeConfig theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        BouncingButton(
          onPressed: () {
            setState(() {
              _isHistoryVisible = !_isHistoryVisible;
            });
          },
          child: Icon(
            _isHistoryVisible
                ? CupertinoIcons.chevron_down
                : CupertinoIcons.clock,
            color: theme.primaryColor,
          ),
        ),
        const SizedBox(width: 8),
        BouncingButton(
          onPressed: () {
            Navigator.push(
              context,
              CustomPageRoute(child: const ThemeSettingsPage()),
            );
          },
          child: Icon(
            CupertinoIcons.settings,
            color: theme.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryPanel(AppThemeConfig theme) {
    return AdaptiveCard(
      backgroundColor: theme.historyBackgroundColor,
      borderRadius: 16,
      child: Column(
        children: [
// Suggested code may be subject to a license. Learn more: ~LicenseLog:1172723274.
          if (_history.isNotEmpty && !kIsWeb) const AdBannerWidget(),
          Expanded(
            child: CupertinoScrollbar(
              child: ListView.builder(
                itemCount: _history.length,
                itemBuilder: (context, index) {
                  final item = _history[index];
                  return Dismissible(
                    key: Key('history_$index'),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      color: CupertinoColors.destructiveRed,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(
                        CupertinoIcons.delete,
                        color: CupertinoColors.white,
                      ),
                    ),
                    onDismissed: (direction) => _deleteHistoryItem(index),
                    child: CupertinoListTile(
                      onTap: () => _recallHistory(item),
                      title: Text(
                        item.name ?? 'Calculation ${_history.length - index}',
                        style: TextStyle(
                          color: theme.historyTextColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        '${item.equation} = ${_formatResult(item.result)}\n${DateFormat('MMM d, y HH:mm').format(item.timestamp)}',
                        style: TextStyle(
                          color: theme.historyTextColor.withOpacity(0.8),
                        ),
                      ),
                      trailing: const CupertinoListTileChevron(),
                    ),
                  );
                },
              ),
            ),
          ),
          if (_history.isNotEmpty && !kIsWeb) const AdBannerWidget(),
        ],
      ),
    );
  }

  // Widget _buildButtonRow(List<String> buttons) {
  //   return Expanded(
  //     child: Row(
  //       crossAxisAlignment: CrossAxisAlignment.stretch,
  //       children: buttons.map((button) => _buildButton(button)).toList(),
  //     ),
  //   );
  // }

  Widget _buildButton(String text, AppThemeConfig theme) {
    final isOperator = _isOperator(text);
    final isClear = text == 'C';

    return AdaptiveButton(
      text: text,
      backgroundColor: isOperator
          ? theme.primaryColor
          : isClear
              ? theme.secondaryColor
              : theme.buttonColor,
      textColor:
          isOperator || isClear ? CupertinoColors.white : theme.buttonTextColor,
      onPressed: () {
        switch (text) {
          case '=':
            _calculate();
            break;
          case 'C':
            _clear();
            break;
          case '+':
          case '-':
          case '×':
          case '÷':
            _addOperator(text);
            break;
          default:
            _addNumber(text);
        }
      },
      borderRadius: 28,
    );
  }

  bool _isOperator(String text) {
    return ['+', '-', '×', '÷', '='].contains(text);
  }
}
