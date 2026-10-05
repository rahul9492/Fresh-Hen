import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/shimmer_box.dart';
import '../../orders/models/order_models.dart';
import '../models/checkout_models.dart';
import '../providers/checkout_providers.dart';
import '../../../core/constants/spacing.dart';

/// Picks a delivery slot. Returns the chosen slot, or null if dismissed.
Future<DeliverySlot?> showDeliverySlotSheet(BuildContext context, {DeliverySlot? current}) =>
    showAppSheet<DeliverySlot>(context, builder: (_) => _DeliverySlotSheet(current: current));

class _DeliverySlotSheet extends ConsumerStatefulWidget {
  const _DeliverySlotSheet({this.current});

  final DeliverySlot? current;

  @override
  ConsumerState<_DeliverySlotSheet> createState() => _DeliverySlotSheetState();
}

class _DeliverySlotSheetState extends ConsumerState<_DeliverySlotSheet> {
  int? _dayIndex;
  late DeliverySlot? _slot = widget.current;

  /// Starts on the day of the current slot, else the first day with free slots.
  int _initialDay(List<DeliveryDay> days) {
    final current = widget.current;
    if (current != null) {
      final i = days.indexWhere((d) => d.slots.any((s) => s.id == current.id && s.available));
      if (i != -1) return i;
    }
    final open = days.indexWhere((d) => d.isOpen);
    return open == -1 ? 0 : open;
  }

  @override
  Widget build(BuildContext context) {
    final days = ref.watch(deliveryDaysProvider);
    final slotStillFree = days.value?.any(
          (d) => d.slots.any((s) => s.id == _slot?.id && s.available),
        ) ??
        false;

    return AppSheet(
      title: 'Select delivery slot',
      footer: AppButton(
        label: 'Confirm',
        onPressed: _slot == null || !slotStillFree ? null : () => Navigator.pop(context, _slot),
      ),
      child: AsyncView(
        value: days,
        onRetry: () => ref.invalidate(deliveryDaysProvider),
        loading: const _SlotsLoading(),
        data: (days) {
          if (!days.any((d) => d.isOpen)) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Text(
                'No delivery slots are open right now.\nPlease choose "Order now" or try again later.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.body, height: 1.4),
              ),
            );
          }
          final index = _dayIndex ?? _initialDay(days);
          final day = days[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 6),
              SizedBox(
                height: 62,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: days.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (_, i) => _DayChip(
                    day: days[i],
                    selected: i == index,
                    onTap: () => setState(() => _dayIndex = i),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Choose Time Slot',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              if (!day.isOpen)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    day.closedReason == null
                        ? 'All slots for this day are taken. Please pick another day.'
                        : 'We are closed on this day (${day.closedReason!.toLowerCase()}).',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.body),
                  ),
                )
              else
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 3.6,
                  children: [
                    for (final s in day.slots)
                      _SlotChip(
                        slot: s,
                        selected: s.id == _slot?.id,
                        onTap: () => setState(() => _slot = s),
                      ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({required this.day, required this.selected, required this.onTap});

  final DeliveryDay day;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final open = day.isOpen;
    final name = formatDayName(day.date);
    final title = name == 'Today' || name == 'Tomorrow' ? name : DateFormat('EEEE').format(day.date);
    final fg = selected ? Colors.white : (open ? AppColors.ink : AppColors.muted);

    return Material(
      color: selected ? AppColors.primary : (open ? Colors.white : const Color(0xFFF1F1F3)),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: open ? onTap : null,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          width: 104,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: selected ? AppColors.primary : (open ? AppColors.border : Colors.transparent),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title, style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 2),
              Text(
                open ? DateFormat('d MMM').format(day.date) : (day.closedReason ?? 'Full'),
                style: TextStyle(color: fg.withValues(alpha: 0.85), fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlotChip extends StatelessWidget {
  const _SlotChip({required this.slot, required this.selected, required this.onTap});

  final DeliverySlot slot;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final available = slot.available;
    return Material(
      color: selected
          ? AppColors.accentSoft
          : (available ? Colors.white : const Color(0xFFF4F4F6)),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: available ? onTap : null,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: selected ? AppColors.primary : (available ? AppColors.border : Colors.transparent),
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                slot.timeLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected
                      ? AppColors.primary
                      : (available ? AppColors.ink : AppColors.muted),
                  decoration: available ? null : TextDecoration.lineThrough,
                ),
              ),
              if (!available)
                const Text('Unavailable', style: TextStyle(fontSize: 10.5, color: AppColors.muted)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlotsLoading extends StatelessWidget {
  const _SlotsLoading();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 6),
        const Row(
          children: [
            Expanded(child: ShimmerBox(height: 62, radius: 12)),
            SizedBox(width: 12),
            Expanded(child: ShimmerBox(height: 62, radius: 12)),
            SizedBox(width: 12),
            Expanded(child: ShimmerBox(height: 62, radius: 12)),
          ],
        ),
        const SizedBox(height: 24),
        for (var i = 0; i < 4; i++) ...[
          const Row(
            children: [
              Expanded(child: ShimmerBox(height: 44, radius: 10)),
              SizedBox(width: 12),
              Expanded(child: ShimmerBox(height: 44, radius: 10)),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
