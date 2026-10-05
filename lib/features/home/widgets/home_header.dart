import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/context_x.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../../../core/widgets/filter_button.dart';
import '../../catalog/models/catalog_models.dart';
import '../../catalog/widgets/filter_sheet.dart';
import '../../address/providers/address_providers.dart';
import '../../cart/providers/cart_providers.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = context.text;
    final address = ref.watch(selectedAddressProvider);
    final cartCount = ref.watch(cartSummaryProvider).itemCount;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.egg_alt_rounded, color: AppColors.primary, size: 30),
              const SizedBox(width: 8),
              Text.rich(
                TextSpan(
                  style: text.headlineMedium?.copyWith(fontSize: 26),
                  children: const [
                    TextSpan(text: 'Fresh '),
                    TextSpan(text: 'Hen', style: TextStyle(color: AppColors.primary)),
                  ],
                ),
              ),
              const Spacer(),
              IconButton.outlined(
                onPressed: () => context.push(Routes.cart),
                icon: Badge(
                  isLabelVisible: cartCount > 0,
                  label: Text('$cartCount'),
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.shopping_cart_outlined),
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: AppColors.border),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          InkWell(
            onTap: () => context.push(Routes.addresses),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, size: 16, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      address == null ? 'Add delivery address' : 'Deliver to ${address.title}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        address?.line ?? 'Tap to add where we should deliver',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.body, fontSize: 13),
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.body),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: AppSearchBar.readOnly(onTap: () => context.push(Routes.search))),
              const SizedBox(width: 12),
              FilterButton(
                bordered: true,
                onPressed: () async {
                  final query = await showFilterSheet(context, const ProductQuery());
                  if (query != null && context.mounted) {
                    context.push(Routes.search, extra: query);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
