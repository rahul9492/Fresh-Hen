import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/product_image.dart';
import '../../cart/models/cart_models.dart';
import '../models/order_models.dart';
import 'order_status_style.dart';
import '../../../core/constants/spacing.dart';

const _hairline = AppColors.hairline;
const _tileFill = AppColors.surfaceMuted;
const _footerFill = Color(0xFFFAFAFC);

/// One order in "My Orders": status header, the items and the actions that fit
/// the status (help while active, reorder and rate once delivered).
class OrderCard extends StatefulWidget {
  const OrderCard({
    super.key,
    required this.order,
    required this.onReorder,
    required this.onRate,
    required this.onHelp,
    this.onTap,
  });

  final Order order;

  /// Opens the order's details.
  final VoidCallback? onTap;
  final VoidCallback onReorder;
  final VoidCallback onRate;
  final VoidCallback onHelp;

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  /// Orders with more lines than this start collapsed to the first two.
  static const _maxVisible = 3;

  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final lines = order.lines;
    final collapsible = lines.length > _maxVisible;
    final shown = collapsible && !_expanded ? lines.take(2).toList() : lines;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadow.card,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: widget.onTap,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                child: _Header(order: order),
              ),
            ),
            if (order.paymentIssue) _PaymentIssueBanner(onTap: widget.onHelp),
            const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16, color: _hairline),
            // The item list opens the order too; the "more" toggle inside still wins its own taps.
            InkWell(
              onTap: widget.onTap,
              child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: Column(
                  children: [
                    for (var i = 0; i < shown.length; i++) ...[
                      if (i > 0) const SizedBox(height: 8),
                      _ItemTile(line: shown[i]),
                    ],
                    if (collapsible)
                      _MoreToggle(
                        expanded: _expanded,
                        hiddenCount: lines.length - 2,
                        onTap: () => setState(() => _expanded = !_expanded),
                      ),
                  ],
                ),
              ),
            ),
            ),
            _Footer(actions: _actions(order)),
          ],
        ),
      ),
    );
  }

  List<Widget> _actions(Order order) {
    final help = _FooterButton(label: 'Help & Support', onTap: widget.onHelp);
    final reorder = _FooterButton(
      label: 'Reorder',
      icon: Icons.cached_rounded,
      color: AppColors.primary,
      onTap: widget.onReorder,
    );
    return switch (order.status) {
      OrderStatus.delivered => [
          reorder,
          order.rating == null
              ? _FooterButton(
                  label: 'Rate order',
                  icon: Icons.star_rounded,
                  iconColor: AppColors.star,
                  onTap: widget.onRate,
                )
              : _RatedButton(stars: order.rating!, onTap: widget.onRate),
        ],
      OrderStatus.cancelled => [reorder, help],
      _ => [help],
    };
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final color = order.statusColor;
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: color.withValues(alpha: 0.18)),
          ),
          child: Icon(order.statusIcon, color: color, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      order.statusLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: color,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '#${order.id}',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                '${rupees(order.total)} • ${formatOrderDate(order.placedAt)}',
                style: const TextStyle(color: AppColors.body, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Red strip under the header when the store couldn't verify the UPI payment.
class _PaymentIssueBanner extends StatelessWidget {
  const _PaymentIssueBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Material(
        color: AppColors.accentSoft,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: const Padding(
            padding: EdgeInsets.fromLTRB(12, 10, 8, 10),
            child: Row(
              children: [
                Icon(Icons.error_outline_rounded, color: AppColors.accent, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "We couldn't verify your payment. Tap to contact us.",
                    style: TextStyle(color: AppColors.primaryDark, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: AppColors.accent),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  const _ItemTile({required this.line});

  final CartLine line;

  @override
  Widget build(BuildContext context) {
    final quantity = line.quantity > 1 ? ' × ${line.quantity}' : '';
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _tileFill,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: _hairline),
      ),
      child: Row(
        children: [
          ProductImage(asset: line.image, size: 46, radius: 8),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  '${line.unitLabel}$quantity • ${rupees(line.total)}',
                  style: const TextStyle(color: AppColors.body, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MoreToggle extends StatelessWidget {
  const _MoreToggle({required this.expanded, required this.hiddenCount, required this.onTap});

  final bool expanded;
  final int hiddenCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                expanded ? 'Show less' : '+$hiddenCount more items',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(
                expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.actions});

  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: const BoxDecoration(
        color: _footerFill,
        border: Border(top: BorderSide(color: _hairline)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < actions.length; i++) ...[
            if (i > 0) const VerticalDivider(width: 1, thickness: 1, color: _hairline),
            Expanded(child: actions[i]),
          ],
        ],
      ),
    );
  }
}

class _FooterButton extends StatelessWidget {
  const _FooterButton({
    required this.label,
    required this.onTap,
    this.icon,
    this.color = AppColors.ink,
    this.iconColor,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final Color color;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 17, color: iconColor ?? color),
              const SizedBox(width: 6),
            ],
            Text(label, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

/// Shows the customer's rating as stars; tapping lets them change it.
class _RatedButton extends StatelessWidget {
  const _RatedButton({required this.stars, required this.onTap});

  final int stars;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Semantics(
          button: true,
          label: 'Rated $stars out of 5. Tap to change.',
          excludeSemantics: true,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Rated',
                style: TextStyle(color: AppColors.body, fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 6),
              for (var i = 1; i <= 5; i++)
                Icon(
                  i <= stars ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 16,
                  color: i <= stars ? AppColors.star : AppColors.muted,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
