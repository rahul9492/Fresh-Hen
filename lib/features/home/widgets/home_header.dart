import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/context_x.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../../../core/widgets/filter_button.dart';
import '../../../core/widgets/pop_on_change.dart';
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
                    TextSpan(
                      text: 'Hen',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => context.push(Routes.cart),
                // The cart springs each time its count changes.
                icon: PopOnChange(
                  value: cartCount,
                  child: Badge(
                    isLabelVisible: cartCount > 0,
                    label: Text('$cartCount'),
                    backgroundColor: AppColors.primary,
                    child: const Icon(Icons.shopping_cart_outlined),
                  ),
                ),
                style: IconButton.styleFrom(backgroundColor: AppColors.shell),
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
        ],
      ),
    );
  }
}

/// Search bar and filter button. On Home this stays pinned under the status bar
/// while the logo and address above it scroll away.
class HomeSearchRow extends StatelessWidget {
  const HomeSearchRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}

/// Pins [HomeSearchRow]; a soft shadow fades in once content scrolls beneath it.
class HomeSearchPinnedDelegate extends SliverPersistentHeaderDelegate {
  const HomeSearchPinnedDelegate();

  static const extent = 72.0; // 12 + 48 (search bar) + 12

  @override
  double get minExtent => extent;

  @override
  double get maxExtent => extent;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    // `overlapsContent` is only set when another pinned sliver sits above this one,
    // which is not the case on Home. A pinned bar the page has scrolled up to has a
    // positive `shrinkOffset`, which is the real "content is under me" signal.
    final lifted = overlapsContent || shrinkOffset > 0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: lifted
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.07),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : const [],
      ),
      child: const HomeSearchRow(),
    );
  }

  @override
  bool shouldRebuild(HomeSearchPinnedDelegate oldDelegate) => false;
}
