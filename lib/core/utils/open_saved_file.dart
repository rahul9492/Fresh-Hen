import 'package:flutter/services.dart';

const _channel = MethodChannel('com.freshhen.app/files');

/// Opens a PDF that was saved to Downloads, given the link the save returned, in
/// the phone's PDF viewer. Returns false when no app can open it (or off Android).
Future<bool> openSavedPdf(String uri) async {
  try {
    return await _channel.invokeMethod<bool>('openPdf', {'uri': uri}) ?? false;
  } on PlatformException {
    return false;
  } on MissingPluginException {
    return false;
  }
}
