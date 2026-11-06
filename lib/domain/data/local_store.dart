import 'dart:async';

import 'package:flutter/services.dart';

/// Reads and writes small text files in the app's private storage through the
/// Android host activity. Used for local demo persistence without extra plugins.
class LocalStore {
  LocalStore._();

  static const MethodChannel _channel = MethodChannel('quickkart/storage');

  static Future<String?> read(String name) async {
    try {
      return await _channel
          .invokeMethod<String>('read', {'name': name})
          .timeout(const Duration(seconds: 3));
    } catch (_) {
      return null;
    }
  }

  static Future<void> write(String name, String content) async {
    // Persistence is best-effort. Do not await the platform call so the UI and
    // in-memory store never block when no host handler is available.
    unawaited(
      _channel
          .invokeMethod<bool>('write', {'name': name, 'content': content})
          .catchError((Object _) => false),
    );
  }
}
