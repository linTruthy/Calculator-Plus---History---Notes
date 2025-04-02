// lib/services/expression_evaluator.dart
import 'dart:math' as math;

class ExpressionEvaluator {
  static final ExpressionEvaluator _instance = ExpressionEvaluator._internal();
  factory ExpressionEvaluator() => _instance;
  ExpressionEvaluator._internal();

  // Constants
  static const double _degToRad = math.pi / 180;
  static const double _radToDeg = 180 / math.pi;

  // Mode settings
  bool _isRadianMode = true;
  bool get isRadianMode => _isRadianMode;
  void toggleAngleMode() {
    _isRadianMode = !_isRadianMode;
  }

  // Convert angle based on current mode
  double _adjustAngle(double angle) {
    return _isRadianMode ? angle : angle * _degToRad;
  }

  // Main evaluation function
  double evaluate(String expression) {
    try {
      // Preprocess the expression
      expression = _preprocessExpression(expression);
      
      // Parse and evaluate
      final result = _parseExpression(expression);
      
      // Check for valid result
      if (result.isNaN || result.isInfinite) {
        throw Exception('Invalid result');
      }
      
      return result;
    } catch (e) {
      throw Exception('Error evaluating expression: ${e.toString()}');
    }
  }

  // Preprocess expression to handle scientific functions
  String _preprocessExpression(String expression) {
    // Replace scientific functions with their calculated values
    expression = _replaceFunctions(expression);
    
    // Replace constants
    expression = expression.replaceAll('π', math.pi.toString());
    expression = expression.replaceAll('e', math.e.toString());
    
    return expression;
  }

  // Replace scientific functions with their values
  String _replaceFunctions(String expression) {
    // Define regex patterns for functions
    final patterns = {
      RegExp(r'sin\(([^()]+)\)'): (String match) {
        final arg = double.parse(_parseExpression(match).toString());
        return math.sin(_adjustAngle(arg)).toString();
      },
      RegExp(r'cos\(([^()]+)\)'): (String match) {
        final arg = double.parse(_parseExpression(match).toString());
        return math.cos(_adjustAngle(arg)).toString();
      },
      RegExp(r'tan\(([^()]+)\)'): (String match) {
        final arg = double.parse(_parseExpression(match).toString());
        return math.tan(_adjustAngle(arg)).toString();
      },
      RegExp(r'log\(([^()]+)\)'): (String match) {
        final arg = double.parse(_parseExpression(match).toString());
        return math.log(arg) / math.ln10.toString();
      },
      RegExp(r'ln\(([^()]+)\)'): (String match) {
        final arg = double.parse(_parseExpression(match).toString());
        return math.log(arg).toString();
      },
      RegExp(r'sqrt\(([^()]+)\)'): (String match) {
        final arg = double.parse(_parseExpression(match).toString());
        return math.sqrt(arg).toString();
      },
      RegExp(r'(\d+)!'): (String match) {
        final n = int.parse(match);
        return _factorial(n).toString();
      },
    };

    // Replace each function call with its value
    String processed = expression;
    bool madeChanges;
    do {
      madeChanges = false;
      for (final pattern in patterns.keys) {
        final matches = pattern.allMatches(processed).toList();
        // Process from right to left to avoid issues with nested functions
        for (int i = matches.length - 1; i >= 0; i--) {
          final match = matches[i];
          final functionArg = match.group(1)!;
          final value = patterns[pattern]!(functionArg);
          processed = processed.replaceRange(
            match.start, 
            match.end, 
            value
          );
          madeChanges = true;
        }
      }
    } while (madeChanges);

    return processed;
  }

  // Recursive descent parser for expressions
  double _parseExpression(String expr) {
    // Remove spaces
    expr = expr.replaceAll(' ', '');
    
    // Handle empty expression
    if (expr.isEmpty) return 0;
    
    return _parseAdditionSubtraction(expr);
  }
  
  // Parse addition and subtraction operations
  double _parseAdditionSubtraction(String expr) {
    // Scan for + or - operators outside of parentheses
    int parenLevel = 0;
    for (int i = expr.length - 1; i >= 0; i--) {
      final char = expr[i];
      
      if (char == ')') parenLevel++;
      else if (char == '(') parenLevel--;
      
      // Only consider operators outside of parentheses
      if (parenLevel == 0) {
        if (char == '+' && i > 0 && expr[i-1] != 'e') { // Avoid scientific notation
          final left = expr.substring(0, i);
          final right = expr.substring(i + 1);
          return _parseAdditionSubtraction(left) + _parseMultiplicationDivision(right);
        } else if (char == '-' && i > 0 && expr[i-1] != 'e') { // Avoid scientific notation
          final left = expr.substring(0, i);
          final right = expr.substring(i + 1);
          return _parseAdditionSubtraction(left) - _parseMultiplicationDivision(right);
        }
      }
    }
    
    // If no addition/subtraction found, try multiplication/division
    return _parseMultiplicationDivision(expr);
  }
  
  // Parse multiplication and division operations
  double _parseMultiplicationDivision(String expr) {
    // Scan for * or / operators outside of parentheses
    int parenLevel = 0;
    for (int i = expr.length - 1; i >= 0; i--) {
      final char = expr[i];
      
      if (char == ')') parenLevel++;
      else if (char == '(') parenLevel--;
      
      // Only consider operators outside of parentheses
      if (parenLevel == 0) {
        if (char == '×' || char == '*') {
          final left = expr.substring(0, i);
          final right = expr.substring(i + 1);
          return _parseMultiplicationDivision(left) * _parsePower(right);
        } else if (char == '÷' || char == '/') {
          final left = expr.substring(0, i);
          final right = expr.substring(i + 1);
          final divisor = _parsePower(right);
          if (divisor == 0) throw Exception('Division by zero');
          return _parseMultiplicationDivision(left) / divisor;
        }
      }
    }
    
    // If no multiplication/division found, try exponentiation
    return _parsePower(expr);
  }
  
  // Parse power operation
  double _parsePower(String expr) {
    // Scan for ^ operator outside of parentheses
    int parenLevel = 0;
    for (int i = 0; i < expr.length; i++) {
      final char = expr[i];
      
      if (char == '(') parenLevel++;
      else if (char == ')') parenLevel--;
      
      // Only consider operators outside of parentheses
      if (parenLevel == 0 && char == '^') {
        final left = expr.substring(0, i);
        final right = expr.substring(i + 1);
        return math.pow(_parseTerm(left), _parsePower(right)).toDouble();
      }
    }
    
    // If no power operation found, try parsing a term
    return _parseTerm(expr);
  }
  
  // Parse a term (number, parenthesized expression, negative value)
  double _parseTerm(String expr) {
    // Remove leading and trailing spaces
    expr = expr.trim();
    
    // Handle empty expression
    if (expr.isEmpty) return 0;
    
    // Handle parentheses
    if (expr.startsWith('(') && expr.endsWith(')')) {
      // Verify that the parentheses match
      if (_checkBalancedParentheses(expr)) {
        return _parseExpression(expr.substring(1, expr.length - 1));
      }
    }
    
    // Handle negative number
    if (expr.startsWith('-')) {
      return -_parseTerm(expr.substring(1));
    }
    
    // Try parsing as a number
    try {
      return double.parse(expr);
    } catch (e) {
      throw Exception('Invalid term: $expr');
    }
  }
  
  // Check that parentheses are balanced
  bool _checkBalancedParentheses(String expr) {
    int count = 0;
    for (int i = 0; i < expr.length; i++) {
      if (expr[i] == '(') count++;
      else if (expr[i] == ')') count--;
      
      // If count goes negative, the parentheses are unbalanced
      if (count < 0) return false;
    }
    return count == 0;
  }
  
  // Calculate factorial
  int _factorial(int n) {
    if (n < 0) throw Exception('Factorial not defined for negative numbers');
    if (n <= 1) return 1;
    return n * _factorial(n - 1);
  }
}