import 'package:flutter/cupertino.dart';

/// AdaptiveSegmentedControl provides a themed segmented control
class AdaptiveSegmentedControl extends StatelessWidget {
  final Map<int, Widget> children;
  final int groupValue;
  final ValueChanged<int> onValueChanged;

  const AdaptiveSegmentedControl({
    super.key,
    required this.children,
    required this.groupValue,
    required this.onValueChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoSegmentedControl<int>(
      children: children,
      groupValue: groupValue,
      onValueChanged: onValueChanged,
      padding: EdgeInsets.zero,
    );
  }
}
