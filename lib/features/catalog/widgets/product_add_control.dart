import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/add_control.dart';
import '../../cart/models/cart_models.dart';
import '../../cart/providers/cart_providers.dart';
import '../models/catalog_models.dart';
import 'product_options_sheet.dart';

class ProductAddControl extends ConsumerWidget {
  const ProductAddControl({super.key, required this.product, this.style = AddControlStyle.pill});

  final Product product;
  final AddControlStyle style;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quantity = ref.watch(productQuantityProvider(product.id));
    final cart = ref.read(cartProvider.notifier);

    CartLine? line() => ref
        .read(cartProvider)
        .where((l) => l.productId == product.id && !l.isAddon)
        .firstOrNull;

    return AddControl(
      style: style,
      quantity: quantity,
      onAdd: () => product.needsOptions
          ? showProductOptionsSheet(context, product)
          : cart.add(CartLine.fromVariant(product, product.defaultVariant)),
      onIncrement: () => cart.increment(line()!.id),
      onDecrement: () => cart.decrement(line()!.id),
    );
  }
}
