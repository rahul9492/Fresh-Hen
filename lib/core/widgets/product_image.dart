import 'package:flutter/material.dart';

class ProductImage extends StatelessWidget {
  const ProductImage({
    super.key,
    required this.asset,
    this.size,
    this.radius = 12,
    this.fit = BoxFit.cover,
  });

  final String asset;
  final double? size;
  final double radius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.asset(asset, width: size, height: size, fit: fit),
    );
  }
}
