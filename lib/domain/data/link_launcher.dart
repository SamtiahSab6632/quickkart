import 'package:flutter/services.dart';

/// Opens external links (phone dialer, WhatsApp, websites) through a small
/// platform channel implemented in the Android host activity. Keeping this
/// native avoids pulling in an extra plugin dependency for two links.
class LinkLauncher {
  LinkLauncher._();

  static const MethodChannel _channel = MethodChannel('quickkart/links');

  static Future<bool> open(String url) async {
    try {
      final result = await _channel.invokeMethod<bool>('open', {'url': url});
      return result ?? false;
    } catch (_) {
      return false;
    }
  }
}
