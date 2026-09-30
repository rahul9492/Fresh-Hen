import 'package:flutter/material.dart';

/// Animated skeleton placeholder. Combine several for loading states.
class ShimmerBox extends StatefulWidget {
  const ShimmerBox({super.key, this.width, this.height = 16, this.radius = 8});

  final double? width;
  final double height;
  final double radius;

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, _) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Color.lerp(const Color(0xFFEDEDF0), const Color(0xFFF7F7F9), _controller.value),
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}

/// A vertical list of shimmering rows, a sensible default for list loading.
class ShimmerList extends StatelessWidget {
  const ShimmerList({super.key, this.itemCount = 6, this.itemHeight = 88});

  final int itemCount;
  final double itemHeight;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, _) => ShimmerBox(height: itemHeight, radius: 14),
    );
  }
}
