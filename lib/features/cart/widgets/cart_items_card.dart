import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/add_control.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/product_hero.dart';
import '../../../core/widgets/product_image.dart';
import '../../../core/widgets/staggered_fade_in.dart';
import '../models/cart_models.dart';
import '../providers/cart_providers.dart';
import '../../../core/constants/spacing.dart';

class CartItemsCard extends ConsumerWidget {
  const CartItemsCard({super.key, required this.lines});

  final List<CartLine> lines;

  /// Swiped away: remove the line, with an Undo that puts it back in the same place.
  void _remove(BuildContext context, WidgetRef ref, CartLine line) {
    final index = lines.indexWhere((l) => l.id == line.id);
    // Grab the cart now: if this was the last item the cart screen is replaced by the
    // empty view, so this widget's `ref` is gone by the time Undo is tapped.
    final cart = ref.read(cartProvider.notifier);
    cart.removeAll({line.id});
    AppSnackbar.info(
      context,
      '${line.name} removed',
      actionLabel: 'Undo',
      onAction: () => cart.restore(line, index),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = lines.fold<int>(0, (sum, l) => sum + l.quantity);
    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Items in cart ($count)',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.body,
            ),
          ),
          for (var i = 0; i < lines.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: AppColors.hairline),
            Dismissible(
              key: ValueKey(lines[i].id),
              direction: DismissDirection.endToStart,
              onDismissed: (_) => _remove(context, ref, lines[i]),
              background: const _SwipeToDeleteBackground(),
              child: StaggeredFadeIn(
                index: i,
                child: ColoredBox(
                  color: Colors.white,
                  child: _LineTile(line: lines[i]),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Red strip revealed behind a cart row while it is swiped left.
class _SwipeToDeleteBackground extends StatelessWidget {
  const _SwipeToDeleteBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.delete_outline_rounded, color: Colors.white),
          SizedBox(height: 2),
          Text(
            'Remove',
            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// Warning above the items when some of them can't be bought any more.
class SoldOutBanner extends StatelessWidget {
  const SoldOutBanner({super.key, required this.count, required this.onRemove});

  final int count;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.accent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              count == 1
                  ? '1 item is sold out. Remove it to continue.'
                  : '$count items are sold out. Remove them to continue.',
              style: const TextStyle(color: AppColors.ink, fontSize: 13, height: 1.3),
            ),
          ),
          TextButton(
            onPressed: onRemove,
            style: TextButton.styleFrom(foregroundColor: AppColors.accent),
            child: Text(count == 1 ? 'Remove' : 'Remove all'),
          ),
        ],
      ),
    );
  }
}

class _LineTile extends ConsumerWidget {
  const _LineTile({required this.line});

  final CartLine line;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.read(cartProvider.notifier);
    final soldOut = ref.watch(soldOutLineIdsProvider.select((ids) => ids.contains(line.id)));
    return Opacity(
      opacity: soldOut ? 0.55 : 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            // Tapping a product's photo opens it, the photo growing into the page.
            // Add-ons aren't catalog products, so theirs is just a picture.
            if (line.isAddon)
              ProductImage(asset: line.image, size: 64, radius: 12)
            else
              GestureDetector(
                onTap: () =>
                    context.push(Routes.productFor(line.productId), extra: 'cart-${line.id}'),
                child: ProductHero(
                  tag: 'cart-${line.id}',
                  source: line.image,
                  width: 64,
                  height: 64,
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    line.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  const SizedBox(height: 3),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.hairline),
                    ),
                    child: Text(
                      line.isAddon ? '${line.unitLabel} • Add-on' : line.unitLabel,
                      style: const TextStyle(
                        color: AppColors.body,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (soldOut) ...[
                    const SizedBox(height: 6),
                    const Text(
                      'Sold out',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ] else if (line.isDiscounted) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Save ${rupees(line.mrpTotal - line.total)}',
                      style: const TextStyle(
                        color: AppColors.success,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (soldOut)
                  OutlinedButton(
                    onPressed: () => cart.removeAll({line.id}),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.accent,
                      side: const BorderSide(color: AppColors.accent),
                      minimumSize: const Size(0, 30),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                    ),
                    child: const Text('Remove', style: TextStyle(fontWeight: FontWeight.w600)),
                  )
                else
                  QtyStepper(
                    quantity: line.quantity,
                    height: 30,
                    light: true,
                    onIncrement: () => cart.increment(line.id),
                    onDecrement: () => cart.decrement(line.id),
                  ),
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    children: [
                      if (line.isDiscounted)
                        TextSpan(
                          text: '${rupees(line.mrpTotal)}  ',
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      TextSpan(text: rupees(line.total)),
                    ],
                  ),
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
