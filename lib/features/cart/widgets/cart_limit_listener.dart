import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/context_x.dart';
import '../providers/cart_providers.dart';

/// Shows "You can order up to N..." wherever the customer taps + past a pack's
/// order limit. Sits once above every screen, so no add button needs to know.
class CartLimitListener extends ConsumerWidget {
  const CartLimitListener({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(cartLimitProvider, (_, notice) {
      if (notice != null) context.showSnack(notice.message);
    });
    return child;
  }
}
