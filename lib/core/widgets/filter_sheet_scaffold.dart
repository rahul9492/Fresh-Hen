import 'package:flutter/material.dart';

import 'app_bottom_sheet.dart';
import 'app_button.dart';

/// [AppSheet] preset for filter sheets: "Filters" title, Reset action and an
/// Apply button. Each feature supplies only its own filter fields as [child].
class FilterSheetScaffold extends StatelessWidget {
  const FilterSheetScaffold({
    super.key,
    required this.child,
    required this.onReset,
    required this.onApply,
    this.title = 'Filters',
    this.applyLabel = 'Show results',
  });

  final Widget child;
  final VoidCallback onReset;
  final VoidCallback onApply;
  final String title;
  final String applyLabel;

  @override
  Widget build(BuildContext context) {
    return AppSheet(
      title: title,
      trailing: TextButton(onPressed: onReset, child: const Text('Reset')),
      footer: AppButton(label: applyLabel, onPressed: onApply),
      child: child,
    );
  }
}
