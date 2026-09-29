import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/context_x.dart';
import '../../catalog/models/catalog_models.dart';
import '../../catalog/widgets/filter_sheet.dart';
import '../../address/providers/address_providers.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = context.text;
    final address = ref.watch(selectedAddressProvider);
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
                onPressed: () => context.showSnack('No new notifications'),
                icon: const Icon(Icons.notifications_none_rounded),
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
                      'Deliver to ${address.label.title}',
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        address.line,
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
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: SearchPill(onTap: () => context.push(Routes.search))),
              const SizedBox(width: 12),
              IconButton.outlined(
                onPressed: () async {
                  final query = await showFilterSheet(context, const ProductQuery());
                  if (query != null && context.mounted) {
                    context.push(Routes.search, extra: query);
                  }
                },
                icon: const Icon(Icons.tune_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  fixedSize: const Size(48, 48),
                  side: const BorderSide(color: AppColors.border),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SearchPill extends StatelessWidget {
  const SearchPill({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.border),
        ),
        child: const Row(
          children: [
            Icon(Icons.search_rounded, color: AppColors.body),
            SizedBox(width: 10),
            Text('Search...', style: TextStyle(color: AppColors.muted, fontSize: 15)),
          ],
        ),
      ),
    );
  }
}
