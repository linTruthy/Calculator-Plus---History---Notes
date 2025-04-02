// lib/screens/calculator_page.dart
import 'package:calculator_plus_history_notes/managers/theme_notifier.dart';
import 'package:calculator_plus_history_notes/services/expression_evaluator.dart';
import 'package:calculator_plus_history_notes/services/premium_manager.dart';
import 'package:calculator_plus_history_notes/widgets/adaptive_button.dart';
import 'package:calculator_plus_history_notes/widgets/adaptive_card.dart';
import 'package:calculator_plus_history_notes/widgets/adaptive_segmented_control.dart';
import 'package:calculator_plus_history_notes/widgets/bouncing_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/ad_manager.dart';
import '../models/app_theme_config_model.dart';
import '../models/history_item.dart';
import '../widgets/ad_banner_widget.dart';
import '../widgets/reponsive_widget.dart';
import 'premium_features_page.dart';
import 'theme_settings_page.dart';
import 'history_export_page.dart';

enum CalculatorMode {
  basic,
  scientific,
}

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
  CalculatorMode _calculatorMode = CalculatorMode.basic;
  final _expressionEvaluator = ExpressionEvaluator();
  
  // Track if parentheses are balanced
  int _openParenthesesCount = 0;
  
  // Flag to know if we're starting a new equation
  bool _startNewEquation = true;

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
    
    // Check if scientific mode is unlocked
    _checkScientificModeAccess();
  }
  
  Future<void> _checkScientificModeAccess() async {
    final premiumManager = PremiumManager();
    final hasScientificAccess = 
        await premiumManager.hasFeature(PremiumFeature.scientificMode);
    if (hasScientificAccess) {
      setState(() {
        // Set default mode to scientific if available
        _calculatorMode = CalculatorMode.scientific;
      });
    }
  }

  @override
  void dispose() {
    AdManager().dispose();
    _animationController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _addToDisplay(String text) {
    setState(() {
      if (_startNewEquation) {
        _display = text;
        _startNewEquation = false;
      } else {
        _display += text;
      }
      _equation = _display;
    });
  }

  void _addNumber(String number) {
    _animationController.reset();
    _animationController.forward();
    
    setState(() {
      if (_display == '0' || _startNewEquation) {
        _display = number;
        _startNewEquation = false;
      } else {
        _display += number;
      }
      _equation = _display;
    });
  }
  
  void _addDecimal() {
    _animationController.reset();
    _animationController.forward();
    
    setState(() {
      // Check if the display already contains a decimal in the current number
      final parts = _display.split(RegExp(r'[\+\-\×\÷\(\)]'));
      final lastPart = parts.isEmpty ? "" : parts.last;
      
      if (lastPart.contains('.')) {
        // Don't add another decimal if there's one already in the current number
        return;
      }
      
      if (_display == '0' || _startNewEquation) {
        _display = '0.';
        _startNewEquation = false;
      } else {
        // If the last character is an operator, add a '0' before the decimal
        final lastChar = _display.isEmpty ? '' : _display[_display.length - 1];
        if (RegExp(r'[\+\-\×\÷\(]').hasMatch(lastChar)) {
          _display += '0';
        }
        _display += '.';
      }
      _equation = _display;
    });
  }

  void _addOperator(String operator) {
    _animationController.reset();
    _animationController.forward();
    
    setState(() {
      if (_display.isEmpty) {
        if (operator == '-') {
          _display = operator;
        }
      } else {
        // Don't allow operators after an open parenthesis except minus
        final lastChar = _display[_display.length - 1];
        if (lastChar == '(' && operator != '-') {
          return;
        }
        
        // Replace the last operator if the current character is an operator
        if (RegExp(r'[\+\-\×\÷]').hasMatch(lastChar)) {
          _display = _display.substring(0, _display.length - 1) + operator;
        } else {
          _display += operator;
        }
      }
      _equation = _display;
      _startNewEquation = false;
    });
  }
  
  void _addParenthesis(String parenthesis) {
    _animationController.reset();
    _animationController.forward();
    
    setState(() {
      if (parenthesis == '(') {
        // If current display is just '0', replace it
        if (_display == '0') {
          _display = '(';
        } else {
          // Add multiplication before open parenthesis if preceded by number or closed parenthesis
          final lastChar = _display.isNotEmpty ? _display[_display.length - 1] : '';
          if (RegExp(r'[0-9\)]').hasMatch(lastChar)) {
            _display += '×(';
          } else {
            _display += '(';
          }
        }
        _openParenthesesCount++;
      } else { // closing parenthesis ')'
        // Only add if there are unmatched open parentheses
        if (_openParenthesesCount > 0) {
          _display += ')';
          _openParenthesesCount--;
        }
      }
      _equation = _display;
      _startNewEquation = false;
    });
  }
  
  void _addFunction(String function) {
    _animationController.reset();
    _animationController.forward();
    
    setState(() {
      // If the display is just '0', replace it
      if (_display == '0' || _startNewEquation) {
        _display = '$function(';
      } else {
        // Add multiplication if the last character is a number or closing parenthesis
        final lastChar = _display.isNotEmpty ? _display[_display.length - 1] : '';
        if (RegExp(r'[0-9\)]').hasMatch(lastChar)) {
          _display += '×$function(';
        } else {
          _display += '$function(';
        }
      }
      _openParenthesesCount++;
      _equation = _display;
      _startNewEquation = false;
    });
  }
  
  void _addConstant(String constant) {
    _animationController.reset();
    _animationController.forward();
    
    String constantValue;
    
    // Convert named constants to their values
    switch (constant) {
      case 'π':
        constantValue = 'π';
        break;
      case 'e':
        constantValue = 'e';
        break;
      default:
        constantValue = constant;
    }
    
    setState(() {
      // If the display is just '0', replace it
      if (_display == '0' || _startNewEquation) {
        _display = constantValue;
      } else {
        // Add multiplication if the last character is a number or closing parenthesis
        final lastChar = _display.isNotEmpty ? _display[_display.length - 1] : '';
        if (RegExp(r'[0-9\)]').hasMatch(lastChar)) {
          _display += '×$constantValue';
        } else {
          _display += constantValue;
        }
      }
      _equation = _display;
      _startNewEquation = false;
    });
  }
  
  void _toggleAngleMode() {
    setState(() {
      _expressionEvaluator.toggleAngleMode();
    });
  }

  void _calculate() {
    try {
      // Close any remaining open parentheses
      String equation = _display;
      while (_openParenthesesCount > 0) {
        equation += ')';
        _openParenthesesCount--;
      }
      
      _result = _expressionEvaluator.evaluate(equation);
      
      _animationController.reset();
      _animationController.forward();

      setState(() {
        _display = _formatResult(_result);
        _addToHistory(equation);
        _equation = _result.toString();
        _startNewEquation = true;
        _openParenthesesCount = 0;
      });
      
      if (!kIsWeb) {
        AdManager().onCalculationPerformed();
      }
    } catch (e) {
      setState(() {
        _display = e.toString().contains('zero') ? 'Cannot divide by zero' : 'Error';
        _startNewEquation = true;
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
      _openParenthesesCount = 0;
      _startNewEquation = true;
    });
  }
  
  void _backspace() {
    _animationController.reset();
    _animationController.forward();
    
    setState(() {
      // Update parentheses count if needed
      if (_display.isNotEmpty) {
        final lastChar = _display[_display.length - 1];
        if (lastChar == '(') {
          _openParenthesesCount--;
        } else if (lastChar == ')') {
          _openParenthesesCount++;
        }
      }
      
      if (_display.length > 1) {
        _display = _display.substring(0, _display.length - 1);
      } else {
        _display = '0';
        _startNewEquation = true;
      }
      
      _equation = _display;
    });
  }

  void _promptForHistoryName() {
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

  void _addToHistory(String calculationEquation) {
    _promptForHistoryName();
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
      _startNewEquation = true;
      _openParenthesesCount = 0;
    });
  }

  void _deleteHistoryItem(int index) {
    setState(() {
      _history.removeAt(index);
    });
  }
  
  void _exportHistory() async {
    final premiumManager = PremiumManager();
    final hasExportAccess = 
        await premiumManager.hasFeature(PremiumFeature.historyExport);
    
    if (hasExportAccess) {
      Navigator.push(
        context,
        CustomPageRoute(
          child: HistoryExportPage(history: _history),
        ),
      );
    } else {
      _showPremiumFeaturePrompt(PremiumFeature.historyExport);
    }
  }
  
  void _toggleCalculatorMode() async {
    // If not in scientific mode, check premium access
    if (_calculatorMode == CalculatorMode.basic) {
      final premiumManager = PremiumManager();
      final hasScientificAccess = 
          await premiumManager.hasFeature(PremiumFeature.scientificMode);
      
      if (hasScientificAccess) {
        setState(() {
          _calculatorMode = CalculatorMode.scientific;
        });
      } else {
        _showPremiumFeaturePrompt(PremiumFeature.scientificMode);
      }
    } else {
      setState(() {
        _calculatorMode = CalculatorMode.basic;
      });
    }
  }
  
  void _showPremiumFeaturePrompt(PremiumFeature feature) {
    final theme = Provider.of<ThemeNotifier>(context, listen: false).currentTheme;
    
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text('Premium Feature: ${PremiumFeaturesPage.getFeatureTitle(feature)}'),
        message: Text(
          'This is a premium feature. Would you like to unlock it?',
          style: TextStyle(color: theme.textColor.withOpacity(0.8)),
        ),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                CustomPageRoute(child: const PremiumFeaturesPage()),
              );
            },
            child: const Text('View Premium Features'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Maybe Later'),
        ),
      ),
    );
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
        backgroundColor: theme.backgroundColor.withOpacity(0.9),
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
                  if (_calculatorMode == CalculatorMode.scientific)
                    _buildModeSelector(theme),
                  Expanded(
                    flex: 4,
                    child: AdaptiveCard(
                      padding: const EdgeInsets.all(8),
                      borderRadius: 20,
                      backgroundColor: theme.backgroundColor,
                      child: _calculatorMode == CalculatorMode.basic
                          ? _buildBasicKeypad(theme)
                          : _buildScientificKeypad(theme),
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
  
  Widget _buildModeSelector(AppThemeConfig theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AdaptiveSegmentedControl(
            children: {
              0: Text('DEG', style: TextStyle(fontSize: 14)),
              1: Text('RAD', style: TextStyle(fontSize: 14)),
            },
            groupValue: _expressionEvaluator.isRadianMode ? 1 : 0,
            onValueChanged: (value) {
              _toggleAngleMode();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBasicKeypad(AppThemeConfig theme) {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              _buildButton('C', theme, isOperator: false, isClear: true),
              _buildButton('(', theme, isParenthesis: true),
              _buildButton(')', theme, isParenthesis: true),
              _buildButton('÷', theme, isOperator: true),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              _buildButton('7', theme),
              _buildButton('8', theme),
              _buildButton('9', theme),
              _buildButton('×', theme, isOperator: true),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              _buildButton('4', theme),
              _buildButton('5', theme),
              _buildButton('6', theme),
              _buildButton('-', theme, isOperator: true),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              _buildButton('1', theme),
              _buildButton('2', theme),
              _buildButton('3', theme),
              _buildButton('+', theme, isOperator: true),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              _buildButton('0', theme),
              _buildButton('.', theme, isDecimal: true),
              _buildButton('⌫', theme, isBackspace: true),
              _buildButton('=', theme, isEquals: true),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildScientificKeypad(AppThemeConfig theme) {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              _buildButton('sin', theme, isFunction: true),
              _buildButton('cos', theme, isFunction: true),
              _buildButton('tan', theme, isFunction: true),
              _buildButton('C', theme, isOperator: false, isClear: true),
              _buildButton('⌫', theme, isBackspace: true),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              _buildButton('log', theme, isFunction: true),
              _buildButton('ln', theme, isFunction: true),
              _buildButton('π', theme, isConstant: true),
              _buildButton('(', theme, isParenthesis: true),
              _buildButton(')', theme, isParenthesis: true),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              _buildButton('√', theme, isFunction: true, functionName: 'sqrt'),
              _buildButton('x²', theme, isOperator: true, operation: '^2'),
              _buildButton('e', theme, isConstant: true),
              _buildButton('÷', theme, isOperator: true),
              _buildButton('×', theme, isOperator: true),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              _buildButton('7', theme),
              _buildButton('8', theme),
              _buildButton('9', theme),
              _buildButton('-', theme, isOperator: true),
              _buildButton('+', theme, isOperator: true),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              _buildButton('4', theme),
              _buildButton('5', theme),
              _buildButton('6', theme),
              _buildButton('x^y', theme, isOperator: true, operation: '^'),
              _buildButton('=', theme, isEquals: true, flex: 1),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              _buildButton('1', theme),
              _buildButton('2', theme),
              _buildButton('3', theme),
              _buildButton('0', theme, flex: 2),
              _buildButton('.', theme, isDecimal: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDisplay(AppThemeConfig theme) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.25,
      padding: const EdgeInsets.all(16),
      child: AdaptiveCard(
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
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                child: Text(
                  _equation,
                  style: TextStyle(
                    fontSize: 20,
                    color: theme.displayTextColor.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ),
            const SizedBox(height: 8),
            FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
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
          onPressed: _exportHistory,
          child: Icon(
            CupertinoIcons.share,
            color: theme.primaryColor,
          ),
        ),
        const SizedBox(width: 8),
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
          onPressed: _toggleCalculatorMode,
          child: Icon(
            _calculatorMode == CalculatorMode.basic
                ? CupertinoIcons.function
                : CupertinoIcons.number,
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
    return GestureDetector(
      onTap: () {
        setState(() {
          _isHistoryVisible = false;
        });
      },
      child: Container(
        color: theme.backgroundColor.withOpacity(0.5),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'History',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.textColor,
                    ),
                  ),
                  Row(
                    children: [
                      BouncingButton(
                        onPressed: _exportHistory,
                        child: Row(
                          children: [
                            Icon(
                              CupertinoIcons.share,
                              color: theme.primaryColor,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Export',
                              style: TextStyle(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      BouncingButton(
                        onPressed: () {
                          setState(() {
                            _isHistoryVisible = false;
                          });
                        },
                        child: Icon(
                          CupertinoIcons.xmark,
                          color: theme.textColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: AdaptiveCard(
                backgroundColor: theme.historyBackgroundColor,
                borderRadius: 16,
                child: Column(
                  children: [
                    if (_history.isEmpty)
                      Expanded(
                        child: Center(
                          child: Text(
                            'No history yet',
                            style: TextStyle(
                              color: theme.historyTextColor.withOpacity(0.6),
                              fontSize: 16,
                            ),
                          ),
                        ),
                      )
                    else
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
    String text,
    AppThemeConfig theme, {
    bool isOperator = false,
    bool isClear = false,
    bool isEquals = false,
    bool isParenthesis = false,
    bool isFunction = false,
    bool isConstant = false,
    bool isDecimal = false,
    bool isBackspace = false,
    String? operation,
    String? functionName,
    int flex = 1,
  }) {
    final buttonText = Text(
      text,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: isOperator || isClear || isEquals || isBackspace
            ? CupertinoColors.white
            : theme.buttonTextColor,
      ),
    );

    Color backgroundColor;
    if (isEquals) {
      backgroundColor = theme.primaryColor;
    } else if (isOperator || isBackspace) {
      backgroundColor = theme.primaryColor.withOpacity(0.8);
    } else if (isClear) {
      backgroundColor = theme.secondaryColor;
    } else if (isParenthesis || isFunction || isConstant) {
      backgroundColor = theme.buttonColor.withOpacity(0.8);
    } else {
      backgroundColor = theme.buttonColor;
    }

    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: BouncingButton(
          onPressed: () {
            if (isClear) {
              _clear();
            } else if (isBackspace) {
              _backspace();
            } else if (isEquals) {
              _calculate();
            } else if (isOperator) {
              if (operation != null) {
                switch (operation) {
                  case '^2':
                    _addToDisplay('^2');
                    break;
                  case '^':
                    _addOperator('^');
                    break;
                  default:
                    _addToDisplay(operation);
                }
              } else {
                _addOperator(text);
              }
            } else if (isParenthesis) {
              _addParenthesis(text);
            } else if (isFunction) {
              _addFunction(functionName ?? text);
            } else if (isConstant) {
              _addConstant(text);
            } else if (isDecimal) {
              _addDecimal();
            } else {
              _addNumber(text);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: backgroundColor.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: buttonText,
            ),
          ),
        ),
      ),
    );
  }
}