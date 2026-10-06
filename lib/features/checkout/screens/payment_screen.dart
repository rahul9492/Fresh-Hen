import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/media/image_picking.dart';
import '../../../core/utils/context_x.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/bottom_action_bar.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/image_upload_button.dart';
import '../../cart/providers/cart_providers.dart';
import '../../orders/models/order_models.dart';
import '../../orders/providers/order_providers.dart';
import '../models/checkout_models.dart';
import '../providers/checkout_providers.dart';
import '../services/upi_qr_actions.dart';
import '../widgets/bill_summary.dart';
import '../../../core/constants/spacing.dart';

/// Pay by scanning the store's UPI QR (uploaded from the admin app), then
/// upload the payment screenshot: the order is placed with it straight away
/// and confirmed once the store verifies the payment. The QR is static, so
/// there is no payment window or countdown.
class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  final _reference = TextEditingController();

  @override
  void dispose() {
    _reference.dispose();
    super.dispose();
  }

  /// The UPI reference is optional, but if typed it must be 12 digits.
  bool _referenceValid() {
    final reference = _reference.text.trim();
    if (reference.isEmpty || RegExp(r'^\d{12}$').hasMatch(reference)) return true;
    context.showError('The UPI transaction ID has 12 digits. Check it or leave it empty.');
    return false;
  }

  /// Places the order with the screenshot or photo the customer just picked.
  Future<void> _placeWith(PickedImage proof) async {
    final order = await ref
        .read(placeOrderProvider.notifier)
        .submit(method: PaymentMethod.upi, proof: proof, paymentReference: _reference.text.trim());
    if (order != null && mounted) context.go(Routes.orderSuccessFor(order.id));
  }

  /// Leaving after paying would lose the order, so confirm first.
  Future<void> _confirmLeave() async {
    final leave = await showConfirmDialog(
      context,
      icon: Icons.warning_amber_rounded,
      title: 'Leave payment?',
      message:
          'If you have already paid, stay and upload the payment screenshot so we can '
          'confirm your order.',
      note: 'Your cart is saved',
      noteIcon: Icons.shopping_cart_rounded,
      confirmLabel: 'Leave anyway',
      cancelLabel: 'Stay & upload screenshot',
      destructive: true,
      preferCancel: true,
    );
    if (leave && mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(placeOrderProvider, (_, s) {
      if (s.hasError) context.showError(s.error!);
    });
    final placing = ref.watch(placeOrderProvider).isLoading;
    final bill = ref.watch(checkoutBillProvider);
    final settings = ref.watch(storeSettingsProvider);
    final cartEmpty = ref.watch(cartSummaryProvider).isEmpty;

    return PopScope(
      // Someone may already have paid, so leaving always asks first.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !placing) _confirmLeave();
      },
      child: Scaffold(
        backgroundColor: AppColors.page,
        appBar: AppBar(title: const Text('Payment')),
        body: AsyncView(
          value: settings,
          onRetry: () => ref.invalidate(storeSettingsProvider),
          data: (settings) {
            if (!settings.upiEnabled) {
              return const _Unavailable();
            }
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [
                _QrCard(settings: settings, amount: bill.total),
                const SizedBox(height: 16),
                _AfterPayingCard(amount: bill.total),
                const SizedBox(height: 16),
                _ReferenceCard(controller: _reference),
                const SizedBox(height: 16),
                AppCard(child: BillSummary(bill: bill)),
              ],
            );
          },
        ),
        bottomNavigationBar: cartEmpty
            ? null
            : BottomActionBar(
                button: ImageUploadButton(
                  label: 'Upload Screenshot',
                  cameraTooltip: 'Take a photo of the payment screen',
                  loading: placing,
                  beforePick: _referenceValid,
                  onImage: _placeWith,
                ),
              ),
      ),
    );
  }
}

class _QrCard extends StatelessWidget {
  const _QrCard({required this.settings, required this.amount});

  final StoreSettings settings;
  final int amount;

  @override
  Widget build(BuildContext context) {
    final upiId = settings.upiId;
    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      child: Column(
        children: [
          Text(
            'Scan & Pay via Any UPI App',
            style: AppType.display(size: 19),
          ),
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
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.sm)),
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

/// What to do after paying.
class _AfterPayingCard extends StatelessWidget {
  const _AfterPayingCard({required this.amount});

  final int amount;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('How to pay', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          _Step(number: 1, text: 'Scan the QR with any UPI app and pay exactly ${rupees(amount)}.'),
          const _Step(number: 2, text: 'Take a screenshot of the payment success screen.'),
          const _Step(
            number: 3,
            text:
                'Upload it using the button below. We confirm your order once the payment '
                'is verified.',
          ),
          const _CameraHint(),
        ],
      ),
    );
  }
}

/// Optional UPI transaction ID (UTR), so the store can match the payment faster.
class _ReferenceCard extends StatelessWidget {
  const _ReferenceCard({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text.rich(
            TextSpan(
              text: 'UPI Transaction ID ',
              children: [
                TextSpan(
                  text: '(optional)',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(12),
            ],
            cursorColor: AppColors.primary,
            decoration: InputDecoration(
              hintText: '12 digit number from your UPI app',
              hintStyle: const TextStyle(color: AppColors.muted, fontSize: 13),
              helperText: 'Helps us confirm your payment faster',
              helperStyle: const TextStyle(color: AppColors.muted, fontSize: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: const BorderSide(color: AppColors.border),
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

/// Points people who paid from another phone to the camera button.
class _CameraHint extends StatelessWidget {
  const _CameraHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.hairline),
      ),
      child: const Row(
        children: [
          Icon(Icons.photo_camera_outlined, size: 18, color: AppColors.primary),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Paid from another phone? Tap the camera button to take a photo of its payment screen.',
              style: TextStyle(color: AppColors.body, fontSize: 12, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 11,
            backgroundColor: AppColors.accentSoft,
            child: Text(
              '$number',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppColors.body, fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _Unavailable extends StatelessWidget {
  const _Unavailable();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.qr_code_2_rounded, size: 56, color: AppColors.muted),
            const SizedBox(height: 12),
            Text(
              'UPI payments are unavailable right now',
              textAlign: TextAlign.center,
              style: AppType.display(size: 17),
            ),
            const SizedBox(height: 6),
            const Text(
              'Please go back and choose Cash on Delivery.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.body),
            ),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: () => context.pop(), child: const Text('Back to cart')),
          ],
        ),
      ),
    );
  }
}
