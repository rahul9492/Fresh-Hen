import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../checkout/models/checkout_models.dart';
import '../../checkout/providers/checkout_providers.dart';
import '../../../core/constants/spacing.dart';

/// "Order now" vs "Schedule for later". Scheduling only appears while the
/// admin has it switched on.
class DeliveryTimingCard extends ConsumerWidget {
  const DeliveryTimingCard({super.key, required this.onPickSlot});

  final VoidCallback onPickSlot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(currentStoreSettingsProvider);
    final mode = ref.watch(deliveryModeProvider);
    final slot = ref.watch(checkoutProvider.select((s) => s.slot));

    if (!settings.scheduleEnabled) {
      return AppCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.bolt_rounded, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text('Order now', style: TextStyle(fontWeight: FontWeight.w700)),
            const Spacer(),
            Text(
              'Arrives in ${settings.etaLabel}',
              style: const TextStyle(color: AppColors.body, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return AppCard(
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          Expanded(
            child: _TimingOption(
              icon: Icons.bolt_rounded,
              title: 'Order now',
              subtitle: settings.etaLabel,
              selected: mode == DeliveryMode.now,
              onTap: ref.read(checkoutProvider.notifier).orderNow,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _TimingOption(
              icon: Icons.schedule_rounded,
              title: 'Schedule for later',
              subtitle: mode == DeliveryMode.scheduled && slot != null
                  ? formatDayName(slot.start)
                  : 'Pick a slot',
              selected: mode == DeliveryMode.scheduled,
              onTap: onPickSlot,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimingOption extends StatelessWidget {
  const _TimingOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? Colors.white : AppColors.ink;
    return Material(
      color: selected ? AppColors.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            children: [
              Icon(icon, size: 20, color: selected ? Colors.white : AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        title,
                        maxLines: 1,
                        style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selected ? Colors.white.withValues(alpha: 0.85) : AppColors.body,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
