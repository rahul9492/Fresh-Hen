import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/product_image.dart';
import '../../catalog/models/catalog_models.dart';
import '../../../core/constants/spacing.dart';

class PromoCarousel extends StatefulWidget {
  const PromoCarousel({super.key, required this.banners});

  final List<PromoBanner> banners;

  @override
  State<PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends State<PromoCarousel> {
  final _controller = PageController();
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer?.cancel();
    if (widget.banners.length < 2) return;
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_controller.hasClients) return;
      _controller.animateToPage(
        (_index + 1) % widget.banners.length,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    });
  }

  /// Stops the auto-scroll while a finger is on the banners, so it never jumps away mid-swipe.
  void _pauseAutoScroll() => _timer?.cancel();

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 176,
          child: Listener(
            onPointerDown: (_) => _pauseAutoScroll(),
            onPointerUp: (_) => _startAutoScroll(),
            onPointerCancel: (_) => _startAutoScroll(),
            child: PageView.builder(
              controller: _controller,
              itemCount: widget.banners.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (_, i) => AnimatedBuilder(
                animation: _controller,
                // The banners next to the current one are a little smaller.
                builder: (_, child) {
                  final page = _controller.hasClients && _controller.position.haveDimensions
                      ? (_controller.page ?? _index.toDouble())
                      : _index.toDouble();
                  final distance = (page - i).abs().clamp(0.0, 1.0);
                  return Transform.scale(scale: 1 - 0.05 * distance, child: child);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _BannerCard(banner: widget.banners[i]),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < widget.banners.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _index ? 18 : 7,
                height: 5,
                decoration: BoxDecoration(
                  color: i == _index ? AppColors.primary : const Color(0xFFD6D6D6),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({required this.banner});

  final PromoBanner banner;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        gradient: const LinearGradient(colors: [Color(0xFFFBE3D6), Color(0xFFF3D3C4)]),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  banner.eyebrow,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 9.5,
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  banner.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppType.display(size: 18, weight: FontWeight.w700, height: 1.15),
                ),
                Text(
                  banner.highlight,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppType.display(
                    size: 18,
                    weight: FontWeight.w700,
                    color: AppColors.primary,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 4),
                Flexible(
                  child: Text(
                    banner.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: AppColors.body, height: 1.3),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 30,
                  child: FilledButton.icon(
                    onPressed: () => context.push(
                      Routes.productsFor(title: banner.title, category: banner.categoryId),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    icon: const Icon(Icons.arrow_forward_rounded, size: 14),
                    label: const Text('Order Now'),
                    iconAlignment: IconAlignment.end,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ProductImage(asset: banner.image, size: 110, radius: 14),
        ],
      ),
    );
  }
}
