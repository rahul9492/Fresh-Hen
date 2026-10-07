import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/utils/context_x.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_image.dart';
import '../models/checkout_models.dart';
import '../services/upi_qr_actions.dart';
import '../../../core/constants/spacing.dart';

class UpiQrCard extends StatelessWidget {
  const UpiQrCard({super.key, required this.settings, required this.amount});

  final StoreSettings settings;
  final int amount;

  @override
  Widget build(BuildContext context) {
    final upiId = settings.upiId;
    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      child: Column(
        children: [
          Text('Scan & Pay via Any UPI App', style: AppType.display(size: 19)),
          const SizedBox(height: 4),
          const Text(
            'Use Google Pay, PhonePe, Paytm or BHIM',
            style: TextStyle(color: AppColors.body, fontSize: 13),
          ),
          const SizedBox(height: 16),
          if (canPayWithUpiApp && upiId != null && upiId.isNotEmpty) ...[
            _PayWithAppButton(settings: settings, amount: amount),
            const _OrDivider(label: 'or scan the QR'),
          ],
          _QrFrame(
            child: AppImage(
              source: settings.upiQrImage!,
              width: 196,
              height: 196,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 12),
          _QrActions(settings: settings, amount: amount),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.successSoft,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Text.rich(
              TextSpan(
                text: 'Pay exactly  ',
                children: [
                  TextSpan(
                    text: rupees(amount),
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ],
              ),
              style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w600),
            ),
          ),
          if (upiId != null && upiId.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              settings.upiPayeeName,
              style: const TextStyle(color: AppColors.body, fontSize: 12),
            ),
            const SizedBox(height: 2),
            InkWell(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              onTap: () {
                Clipboard.setData(ClipboardData(text: upiId));
                context.showSuccess('UPI ID copied');
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(upiId, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(width: 6),
                    const Icon(Icons.copy_rounded, size: 16, color: AppColors.primary),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Opens GPay, PhonePe, Paytm etc. on this phone with the amount filled in.
class _PayWithAppButton extends StatelessWidget {
  const _PayWithAppButton({required this.settings, required this.amount});

  final StoreSettings settings;
  final int amount;

  Future<void> _pay(BuildContext context) async {
    final opened = await payWithUpiApp(settings, amount);
    if (!opened && context.mounted) {
      context.showError('No UPI app found. Save the QR and scan it from your UPI app instead.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton.icon(
        onPressed: () => _pay(context),
        icon: const Icon(Icons.account_balance_wallet_outlined, size: 20),
        label: Text('Pay ${rupees(amount)} with UPI app'),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accentSoft,
          foregroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          const Expanded(child: Divider(color: AppColors.hairline)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
          ),
          const Expanded(child: Divider(color: AppColors.hairline)),
        ],
      ),
    );
  }
}

/// Save the QR to the gallery (to scan it from a UPI app on this phone) or
/// share it to another phone.
class _QrActions extends StatefulWidget {
  const _QrActions({required this.settings, required this.amount});

  final StoreSettings settings;
  final int amount;

  @override
  State<_QrActions> createState() => _QrActionsState();
}

class _QrActionsState extends State<_QrActions> {
  var _busy = false;

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } catch (e) {
      if (mounted) context.showError('Could not get the QR. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _save() => _run(() async {
    final saved = await saveUpiQr(widget.settings.upiQrImage!);
    if (!mounted) return;
    if (saved) {
      context.showSuccess('QR saved. In your UPI app tap Scan → Gallery and pick it.');
    } else {
      context.showError('Allow photo access to save the QR.');
    }
  });

  Future<void> _share() => _run(() => shareUpiQr(widget.settings, widget.amount));

  @override
  Widget build(BuildContext context) {
    final style = OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      side: const BorderSide(color: AppColors.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      textStyle: const TextStyle(fontWeight: FontWeight.w600),
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        OutlinedButton.icon(
          onPressed: _busy ? null : _save,
          icon: const Icon(Icons.download_rounded, size: 18),
          label: const Text('Save QR'),
          style: style,
        ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: _busy ? null : _share,
          icon: const Icon(Icons.share_rounded, size: 18),
          label: const Text('Share QR'),
          style: style,
        ),
      ],
    );
  }
}

/// Scanner-style corner brackets around the QR.
class _QrFrame extends StatelessWidget {
  const _QrFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _CornerPainter(),
      child: Container(
        width: 236,
        height: 236,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7FD),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const len = 26.0;
    const r = 6.0;
    final paint = Paint()
      ..color = AppColors.primaryDark
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final w = size.width;
    final h = size.height;
    final corners = [
      Path()
        ..moveTo(0, len)
        ..lineTo(0, r)
        ..quadraticBezierTo(0, 0, r, 0)
        ..lineTo(len, 0),
      Path()
        ..moveTo(w - len, 0)
        ..lineTo(w - r, 0)
        ..quadraticBezierTo(w, 0, w, r)
        ..lineTo(w, len),
      Path()
        ..moveTo(w, h - len)
        ..lineTo(w, h - r)
        ..quadraticBezierTo(w, h, w - r, h)
        ..lineTo(w - len, h),
      Path()
        ..moveTo(len, h)
        ..lineTo(r, h)
        ..quadraticBezierTo(0, h, 0, h - r)
        ..lineTo(0, h - len),
    ];
    for (final c in corners) {
      canvas.drawPath(c, paint);
    }
  }

  @override
  bool shouldRepaint(_CornerPainter oldDelegate) => false;
}
