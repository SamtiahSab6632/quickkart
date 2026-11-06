import 'dart:convert';

import 'package:quick_kart/domain/data/local_store.dart';

/// Stores the user's free Gemini API key on the device so the AI assistant
/// can use the real model after the first setup. The key never leaves the
/// device; requests go straight to Google's endpoint.
///
/// Keys are never committed to the repository. Provide a key either through
/// `--dart-define` / `--dart-define-from-file` at build time (see
/// `config/ai_key.example.json`) or by pasting it once in the AI chat screen,
/// after which it is stored on the device only.
class AiStore {
  AiStore._();

  static const String _fileName = 'quickkart_ai.json';

  /// Optional compile-time key:
  /// `flutter run --dart-define=QUICKKART_AI_KEY=...`
  /// or `flutter run --dart-define-from-file=config/ai_key.json`.
  static const String _envKey = String.fromEnvironment('QUICKKART_AI_KEY');

  static String? _savedKey;
  static bool _loaded = false;

  static bool get hasKey => apiKey.trim().isNotEmpty;

  /// A `--dart-define` key always wins over the key saved in the app.
  static String get apiKey {
    if (_envKey.trim().isNotEmpty) return _envKey.trim();
    return _savedKey?.trim() ?? '';
  }

  static bool get isSavedKey =>
      _savedKey != null && _savedKey!.trim().isNotEmpty;

  static Future<void> load() async {
    if (_loaded) return;
    _loaded = true;

    final raw = await LocalStore.read(_fileName);
    if (raw == null || raw.isEmpty) return;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        final saved = (decoded['key'] as String?)?.trim() ?? '';
        if (saved.isNotEmpty) _savedKey = saved;
      }
    } catch (_) {
      // Ignore a corrupted key file.
    }
  }

  static Future<void> saveKey(String key) async {
    final trimmed = key.trim();
    _savedKey = trimmed.isEmpty ? null : trimmed;
    await LocalStore.write(
      _fileName,
      _savedKey == null ? '' : jsonEncode({'key': _savedKey}),
    );
  }

  static void resetForTesting() {
    _savedKey = null;
    _loaded = false;
  }
}
