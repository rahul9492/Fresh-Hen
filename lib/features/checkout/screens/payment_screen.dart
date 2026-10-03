import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/app_colors.dart';
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
import '../widgets/bill_summary.dart';

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
      title: 'Leave payment?',
      message:
          'If you have already paid, stay and upload the screenshot so we can confirm '
          'your order. Your cart will be kept.',
      confirmLabel: 'Leave',
      cancelLabel: 'Stay',
      destructive: true,
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
                const SizedBox(height: 14),
                _AfterPayingCard(amount: bill.total),
                const SizedBox(height: 14),
                _ReferenceCard(controller: _reference),
                const SizedBox(height: 14),
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
          const Text(
            'Scan & Pay via Any UPI App',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'Use Google Pay, PhonePe, Paytm or BHIM',
            style: TextStyle(color: AppColors.body, fontSize: 13),
          ),
          const SizedBox(height: 16),
          _QrFrame(
            child: AppImage(
              source: settings.upiQrImage!,
              width: 196,
              height: 196,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.successSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text.rich(
              TextSpan(
                text: 'Pay exactly  ',
                children: [
                  TextSpan(
                    text: rupees(amount),
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
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
              style: const TextStyle(color: AppColors.body, fontSize: 12.5),
            ),
            const SizedBox(height: 2),
            InkWell(
              borderRadius: BorderRadius.circular(8),
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
          borderRadius: BorderRadius.circular(8),
        ),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
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
                    fontSize: 12.5,
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
              helperStyle: const TextStyle(color: AppColors.muted, fontSize: 11.5),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
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
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.hairline),
      ),
      child: const Row(
        children: [
          Icon(Icons.photo_camera_outlined, size: 18, color: AppColors.primary),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Paid from another phone? Tap the camera button to take a photo of its payment screen.',
              style: TextStyle(color: AppColors.body, fontSize: 12.5, height: 1.35),
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
          const SizedBox(width: 10),
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
            const Text(
              'UPI payments are unavailable right now',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Text(
              'Please go back and choose Cash on Delivery.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.body),
            ),
            const SizedBox(height: 18),
            OutlinedButton(onPressed: () => context.pop(), child: const Text('Back to cart')),
          ],
        ),
      ),
    );
  }
}
