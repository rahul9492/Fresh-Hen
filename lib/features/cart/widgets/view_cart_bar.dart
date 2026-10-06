import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/fly_to_cart.dart';
import '../../../core/widgets/press_scale.dart';
import '../../../core/widgets/product_image.dart';
import '../providers/cart_providers.dart';
import '../../../core/constants/spacing.dart';

/// Floating "View cart" pill shown above the bottom nav while the cart has items.
///
/// [compact] makes it a centred, content-sized floating button (like a FAB),
/// for pages with their own bottom bar, e.g. product details.
class ViewCartBar extends ConsumerStatefulWidget {
  const ViewCartBar({super.key, this.compact = false});

  final bool compact;

  @override
  ConsumerState<ViewCartBar> createState() => _ViewCartBarState();
}

class _ViewCartBarState extends ConsumerState<ViewCartBar> {
  // Own key per bar: wishlist or a product list can open over the tabs, each with a bar.
  late final CartFlyTarget _flyTarget = (bar: context, thumbs: GlobalKey());

  @override
  void initState() {
    super.initState();
    registerCartFlyTarget(_flyTarget);
  }

  @override
  void dispose() {
    unregisterCartFlyTarget(_flyTarget);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final summary = ref.watch(cartSummaryProvider);
    final lines = ref.watch(cartProvider);
    final thumbs = lines.reversed.take(2).toList();
    final count = summary.itemCount;
    final compact = widget.compact;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      switchInCurve: Curves.easeOutCubic,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween(begin: const Offset(0, 0.6), end: Offset.zero).animate(animation),
          child: child,
        ),
      ),
      child: summary.isEmpty
          ? const SizedBox(width: double.infinity, key: ValueKey('empty'))
          : Padding(
              key: const ValueKey('bar'),
              padding: compact
                  ? const EdgeInsets.only(bottom: 12)
                  : const EdgeInsets.fromLTRB(16, 8, 16, 10),
              child: PressScale(
                scale: 0.98,
                child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => context.push(Routes.cart),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  child: Ink(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          Color.lerp(AppColors.primary, Colors.black, 0.22)!,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      // The compact one floats over content, so it casts a fuller shadow.
                      boxShadow: [
                        compact
                            ? BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.35),
                                blurRadius: 18,
                                spreadRadius: -4,
                                offset: const Offset(0, 8),
                              )
                            : BoxShadow(
                                color: Colors.black.withValues(alpha: 0.16),
                                blurRadius: 10,
                                spreadRadius: -10,
                                offset: const Offset(0, 10),
                              ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
                      children: [
                        SizedBox(
                          key: _flyTarget.thumbs,
                          child: _Thumbs(images: [for (final l in thumbs) l.image]),
                        ),
                        const SizedBox(width: 12),
                        _Fill(
                          fill: !compact,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'View cart',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 1),
                              // Pops each time the count or total changes.
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 220),
                                transitionBuilder: (child, animation) => FadeTransition(
                                  opacity: animation,
                                  child: ScaleTransition(
                                    scale: Tween(begin: 0.85, end: 1.0).animate(animation),
                                    alignment: Alignment.centerLeft,
                                    child: child,
                                  ),
                                ),
                                layoutBuilder: (current, previous) => Stack(
                                  alignment: Alignment.centerLeft,
                                  children: [...previous, ?current],
                                ),
                                child: Text(
                                  '$count ${count == 1 ? 'item' : 'items'} · ${rupees(summary.itemTotal)}',
                                  key: ValueKey('$count-${summary.itemTotal}'),
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (compact) const SizedBox(width: 14),
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.18),
                          ),
                          child: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ),
              ),
            ),
    );
  }
}

/// Takes the remaining width in the full bar; just its own width when compact.
class _Fill extends StatelessWidget {
  const _Fill({required this.fill, required this.child});

  final bool fill;
  final Widget child;

  @override
  Widget build(BuildContext context) => fill ? Expanded(child: child) : child;
}

class _Thumbs extends StatelessWidget {
  const _Thumbs({required this.images});

  final List<String> images;

  static const _size = 44.0;
  static const _overlap = 26.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _size + (images.length - 1) * _overlap,
      height: _size,
      child: Stack(
        children: [
          for (var i = images.length - 1; i >= 0; i--)
            Positioned(
              left: i * _overlap,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                child: ClipOval(
                  child: ProductImage(asset: images[i], size: _size - 4, radius: 0),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
