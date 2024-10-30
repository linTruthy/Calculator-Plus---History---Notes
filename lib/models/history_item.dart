class HistoryItem {
  final String equation;
  final double result;
  final DateTime timestamp;
  final String? name;

  HistoryItem({
    required this.equation,
    required this.result,
    required this.timestamp,
    this.name,
  });
}
