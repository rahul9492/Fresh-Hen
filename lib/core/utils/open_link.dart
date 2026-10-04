import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'context_x.dart';

/// Opens [uri] outside the app (dialer, WhatsApp, browser) and shows [error]
/// if nothing can handle it. Web pages open in an in-app browser tab.
Future<void> openLink(BuildContext context, Uri uri, {required String error}) async {
  final web = uri.scheme == 'http' || uri.scheme == 'https';
  var opened = false;
  try {
    opened = await launchUrl(
      uri,
      mode: web && uri.host != 'wa.me' ? LaunchMode.inAppBrowserView : LaunchMode.externalApplication,
    );
  } catch (_) {}
  if (!opened && context.mounted) context.showError(error);
}

/// The store's support number as digits with the country code (e.g.
/// `919711739492`), whether the admin typed `9711739492` or `+91 97117 39492`.
String supportDigits(String phone) {
  final digits = phone.replaceAll(RegExp(r'\D'), '');
  return digits.length == 10 ? '91$digits' : digits;
}

/// "+91 97117 39492" for an Indian number, otherwise `+` and the digits.
String supportDisplay(String phone) {
  final d = supportDigits(phone);
  if (d.length == 12 && d.startsWith('91')) {
    return '+91 ${d.substring(2, 7)} ${d.substring(7)}';
  }
  return '+$d';
}
