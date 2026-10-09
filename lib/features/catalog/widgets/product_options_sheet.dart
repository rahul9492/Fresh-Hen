import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/add_control.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/price_text.dart';
import '../../../core/widgets/product_image.dart';
import '../../../core/widgets/small_widgets.dart';
import '../../cart/models/cart_models.dart';
import '../../cart/providers/cart_providers.dart';
import '../models/catalog_models.dart';
import '../../../core/constants/spacing.dart';

Future<void> showProductOptionsSheet(BuildContext context, Product product) {
  return showAppSheet<void>(context, builder: (_) => ProductOptionsSheet(product: product));
}

class ProductOptionsSheet extends ConsumerWidget {
  const ProductOptionsSheet({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.read(cartProvider.notifier);
    final text = Theme.of(context).textTheme;

    return AppSheet(
      bodyPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      footer: _DoneButton(product: product),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ProductImage(asset: product.image, size: 52),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, style: text.titleMedium?.copyWith(fontSize: 16)),
                    const SizedBox(height: 2),
                    RatingLabel(rating: product.rating, count: product.ratingCount),
                  ],
                ),
              ),
              const SheetCloseButton(),
            ],
          ),
          const Divider(height: 28),
          _GroupTitle(title: 'Quantity', hint: 'Select any', style: text),
          _Group(
            children: [
              for (final v in product.variants)
                _VariantRow(
                  product: product,
                  variant: v,
                  onSelect: () => cart.add(CartLine.fromVariant(product, v)),
                ),
            ],
          ),
          if (product.accompaniments.isNotEmpty) ...[
            const SizedBox(height: 24),
            _GroupTitle(title: 'Add Accompaniments', hint: 'Select any', style: text),
            _Group(
              children: [
                for (final a in product.accompaniments) _AccompanimentRow(item: a),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Closes the sheet, showing what has been picked in it so far: this product's
/// packs plus its add-ons, e.g. "Done • 2 items • ₹260".
class _DoneButton extends ConsumerWidget {
  const _DoneButton({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addonIds = {for (final a in product.accompaniments) CartLine.fromAccompaniment(a).id};
    final picked = ref.watch(cartProvider).where(
          (l) => l.isAddon ? addonIds.contains(l.id) : l.productId == product.id,
        );
    final count = picked.fold(0, (sum, l) => sum + l.quantity);
    final total = picked.fold(0, (sum, l) => sum + l.total);

    return AppButton(
      label: count == 0
          ? 'Done'
          : 'Done • $count ${count == 1 ? 'item' : 'items'} • ${rupees(total)}',
      onPressed: () => Navigator.of(context).pop(),
    );
  }
}

class _GroupTitle extends StatelessWidget {
  const _GroupTitle({required this.title, required this.hint, required this.style});

  final String title;
  final String hint;
  final TextTheme style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: style.titleMedium?.copyWith(fontSize: 16)),
          Text(hint, style: const TextStyle(color: AppColors.body, fontSize: 12)),
        ],
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadow.card,
        color: Colors.white,
      ),
      child: Column(children: children),
    );
  }
}

class _VariantRow extends ConsumerWidget {
  const _VariantRow({required this.product, required this.variant, required this.onSelect});

  final Product product;
  final ProductVariant variant;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lineId = CartLine.fromVariant(product, variant).id;
    final quantity = ref.watch(lineQuantityProvider(lineId));
    final cart = ref.read(cartProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const NonVegMark(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '${variant.label} • ',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                    ),
                    PriceText(price: variant.price, mrp: variant.mrp),
                  ],
                ),
                // Only once it matters, so the list stays clean.
                if (variant.maxQuantity != null && quantity >= variant.maxQuantity!)
                  Text(
                    'Max ${variant.maxQuantity} per order',
                    style: const TextStyle(color: AppColors.body, fontSize: 12),
                  ),
              ],
            ),
          ),
          AddControl(
            style: AddControlStyle.pill,
            quantity: quantity,
            available: variant.inStock,
            onAdd: onSelect,
            onIncrement: () => cart.increment(lineId),
            onDecrement: () => cart.decrement(lineId),
          ),
        ],
      ),
    );
  }
}

class _AccompanimentRow extends ConsumerWidget {
  const _AccompanimentRow({required this.item});

  final Accompaniment item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final line = CartLine.fromAccompaniment(item);
    final quantity = ref.watch(lineQuantityProvider(line.id));
    final cart = ref.read(cartProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          ProductImage(asset: item.image, size: 44, radius: 8),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  children: [
                    Text(
                      '${item.weight} • ${rupees(item.price)}',
                      style: const TextStyle(color: AppColors.body, fontSize: 12),
                    ),
                    RatingLabel(rating: item.rating, count: item.ratingCount, small: true),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          AddControl(
            available: item.inStock,
            quantity: quantity,
            onAdd: () => cart.add(line),
            onIncrement: () => cart.increment(line.id),
            onDecrement: () => cart.decrement(line.id),
          ),
        ],
      ),
    );
  }
}
