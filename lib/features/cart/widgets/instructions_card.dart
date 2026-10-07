import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../checkout/providers/checkout_providers.dart';
import '../../../core/constants/spacing.dart';

class InstructionsCard extends ConsumerStatefulWidget {
  const InstructionsCard({super.key});

  @override
  ConsumerState<InstructionsCard> createState() => _InstructionsCardState();
}

class _InstructionsCardState extends ConsumerState<InstructionsCard> {
  late final _controller = TextEditingController(text: ref.read(checkoutProvider).instructions);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(Icons.edit_note_rounded, size: 20, color: AppColors.body),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Special Instructions',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
              Text('(Optional)', style: TextStyle(color: AppColors.muted, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            minLines: 1,
            maxLines: 3,
            inputFormatters: [LengthLimitingTextInputFormatter(200)],
            textCapitalization: TextCapitalization.sentences,
            onChanged: ref.read(checkoutProvider.notifier).setInstructions,
            cursorColor: AppColors.primary,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              isDense: true,
              hintText: 'e.g. Ring the doorbell, leave at the door...',
              hintStyle: const TextStyle(color: AppColors.muted, fontSize: 13),
              filled: true,
              fillColor: AppColors.surfaceMuted,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: const BorderSide(color: AppColors.hairline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: const BorderSide(color: AppColors.hairline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
