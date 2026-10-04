import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/checkout_models.dart';

const _qrFileName = 'FreshHen_UPI_QR';

/// UPI apps register the generic `upi://pay` link on Android only; on iOS each
/// app has its own scheme, so "Pay with UPI app" is shown on Android only.
bool get canPayWithUpiApp => defaultTargetPlatform == TargetPlatform.android;

/// Reads the QR image, whether it is a bundled asset (mock mode) or the URL the
/// admin uploaded.
Future<Uint8List> _qrBytes(String source) async {
  final bundle = source.startsWith('http') ? NetworkAssetBundle(Uri.parse(source)) : rootBundle;
  final data = await bundle.load(source);
  return data.buffer.asUint8List();
}

/// Saves the store QR to the gallery, so the customer can pick it with
/// "Scan from gallery" in GPay, PhonePe or Paytm on the same phone.
/// Returns false if the customer denied gallery access.
Future<bool> saveUpiQr(String source) async {
  if (!await Gal.hasAccess() && !await Gal.requestAccess()) return false;
  await Gal.putImageBytes(await _qrBytes(source), name: _qrFileName);
  return true;
}

/// Opens the share sheet with the QR image, e.g. to send it to whoever pays.
Future<void> shareUpiQr(StoreSettings settings, int amount) async {
  final bytes = await _qrBytes(settings.upiQrImage!);
  final upiId = settings.upiId;
  await SharePlus.instance.share(
    ShareParams(
      files: [XFile.fromData(bytes, mimeType: 'image/png', name: '$_qrFileName.png')],
      text: 'Pay ₹$amount to ${settings.upiPayeeName}'
          '${upiId != null && upiId.isNotEmpty ? ' (UPI ID: $upiId)' : ''}'
          ' for my Fresh Hen order.',
    ),
  );
}

/// Opens the customer's UPI app with the payee and the exact amount filled in.
/// Returns false when no UPI app could handle the link.
Future<bool> payWithUpiApp(StoreSettings settings, int amount) async {
  // Built by hand: UPI apps expect %20 for spaces, Uri.queryParameters uses '+'.
  final params = {
    'pa': settings.upiId!,
    'pn': settings.upiPayeeName,
    'am': amount.toStringAsFixed(2),
    'cu': 'INR',
    'tn': 'Fresh Hen order',
  }.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');
  try {
    return await launchUrl(Uri.parse('upi://pay?$params'), mode: LaunchMode.externalApplication);
  } on PlatformException {
    return false;
  }
}
