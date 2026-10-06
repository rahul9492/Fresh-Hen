import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/routes.dart';
import '../../app/theme/app_colors.dart';

/// The soft round down-arrow at the top left of a bottom tab (Orders, Account),
/// matching the Categories tab. Tabs have nothing to pop, so it goes Home; if
/// the page was opened on top of another one, it goes back to that instead.
///
/// Use as `AppBar(leading: const TabCloseButton(), leadingWidth: TabCloseButton.width)`.
class TabCloseButton extends StatelessWidget {
  const TabCloseButton({super.key});

  /// The AppBar `leadingWidth` that lines it up with the page edge.
  static const width = 68.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Center(
        child: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 22),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.shell,
            fixedSize: const Size(40, 40),
            minimumSize: const Size(40, 40),
          ),
          onPressed: () => context.canPop() ? context.pop() : context.go(Routes.home),
        ),
      ),
    );
  }
}
