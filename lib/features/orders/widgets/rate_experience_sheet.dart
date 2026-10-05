import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/app_button.dart';
import '../models/order_models.dart';
import '../../../core/constants/spacing.dart';

/// The customer's rating: 1-5 stars and an optional comment.
typedef OrderReview = ({int stars, String comment});

/// Asks the customer to rate [order]. Returns the review, or null if dismissed.
Future<OrderReview?> showRateExperienceSheet(BuildContext context, {required Order order}) =>
    showAppSheet<OrderReview>(context, builder: (_) => _RateExperienceSheet(order: order));

class _RateExperienceSheet extends StatefulWidget {
  const _RateExperienceSheet({required this.order});

  final Order order;

  @override
  State<_RateExperienceSheet> createState() => _RateExperienceSheetState();
}

class _RateExperienceSheetState extends State<_RateExperienceSheet> {
  static const _maxLength = 250;
  static const _moods = ['Terrible', 'Bad', 'Okay', 'Good', 'Loved it!'];

  late var _stars = widget.order.rating ?? 0;
  late final _comment = TextEditingController(text: widget.order.review);

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppSheet(
      title: 'Rate Your Experience',
      footer: AppButton(
        label: 'Submit',
        onPressed: _stars == 0
            ? null
            : () => Navigator.pop(context, (stars: _stars, comment: _comment.text.trim())),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          const Text(
            'Your Rating',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 1; i <= 5; i++)
                IconButton(
                  onPressed: () => setState(() => _stars = i),
                  tooltip: '$i star${i == 1 ? '' : 's'}',
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  icon: AnimatedScale(
                    scale: i <= _stars ? 1.1 : 1,
                    duration: const Duration(milliseconds: 160),
                    child: Icon(
                      i <= _stars ? Icons.star_rounded : Icons.star_outline_rounded,
                      size: 42,
                      color: i <= _stars ? AppColors.star : AppColors.muted,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(
            height: 22,
            child: Text(
              _stars == 0 ? 'Tap a star to rate' : _moods[_stars - 1],
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _stars == 0 ? AppColors.muted : AppColors.ink,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text.rich(
            TextSpan(
              text: 'Additional Comments ',
              children: [
                TextSpan(
                  text: '(Optional)',
                  style: TextStyle(color: AppColors.muted, fontSize: 12, fontWeight: FontWeight.w400),
                ),
              ],
            ),
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _comment,
            minLines: 3,
            maxLines: 5,
            textCapitalization: TextCapitalization.sentences,
            inputFormatters: [LengthLimitingTextInputFormatter(_maxLength)],
            cursorColor: AppColors.primary,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Tell us more about the delivery time, meat quality, packaging or delivery partner...',
              hintStyle: const TextStyle(color: AppColors.muted, fontSize: 13),
              filled: true,
              fillColor: AppColors.surfaceMuted,
              contentPadding: const EdgeInsets.all(16),
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
          const SizedBox(height: 6),
          ValueListenableBuilder(
            valueListenable: _comment,
            builder: (_, value, _) => Text(
              '${value.text.length}/$_maxLength characters',
              textAlign: TextAlign.right,
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
