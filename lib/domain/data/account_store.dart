import 'dart:async';
import 'dart:convert';

import 'package:quick_kart/domain/data/local_store.dart';
import 'package:quick_kart/domain/models/account.dart';

class AccountStore {
  AccountStore._();

  static const String _fileName = 'quickkart_accounts.json';
  static const String _sessionFileName = 'quickkart_session.json';

  static final List<Account> _accounts = [];
  static Account? _currentUser;
  static bool _loaded = false;

  static Account? get currentUser => _currentUser;

  static List<Account> get accounts => List<Account>.unmodifiable(_accounts);

  static Future<void> load() async {
    if (_loaded) return;
    _loaded = true;

    final raw = await LocalStore.read(_fileName);
    if (raw == null || raw.isEmpty) return;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        _accounts
          ..clear()
          ..addAll(
            decoded.whereType<Map>().map(
              (item) => Account.fromJson(Map<String, dynamic>.from(item)),
            ),
          );
      }
    } catch (_) {
      // Ignore a corrupted account file and start fresh.
    }

    await _restoreSession();
  }

  /// Restores the last logged-in account from the session file.
  static Future<void> _restoreSession() async {
    final sessionRaw = await LocalStore.read(_sessionFileName);
    if (sessionRaw == null || sessionRaw.isEmpty) return;

    try {
      final decoded = jsonDecode(sessionRaw);
      if (decoded is! Map) return;
      final session = Map<String, dynamic>.from(decoded);
      final email = (session['email'] as String?) ?? '';
      final phone = (session['phone'] as String?) ?? '';

      for (final account in _accounts) {
        final matched = email.isNotEmpty
            ? account.isGoogleAccount && account.email == email
            : phone.isNotEmpty && account.phone == phone;
        if (matched) {
          _currentUser = account;
          return;
        }
      }
    } catch (_) {
      // Ignore a corrupted session file.
    }
  }

  static Future<void> _persistSession() async {
    final user = _currentUser;
    final content = user == null
        ? ''
        : jsonEncode(<String, String>{
            if (user.isGoogleAccount)
              'email': user.email
            else
              'phone': user.phone,
          });
    await LocalStore.write(_sessionFileName, content);
  }

  static bool phoneExists(String phone) {
    return _accounts.any((account) => account.phone == phone);
  }

  static bool emailExists(String email) {
    final normalisedEmail = email.trim().toLowerCase();
    return _accounts.any(
      (account) => account.isGoogleAccount && account.email == normalisedEmail,
    );
  }

  static Future<Account?> register({
    required String name,
    required String phone,
    required String password,
  }) async {
    if (phoneExists(phone)) return null;

    final account = Account(
      name: name.trim(),
      phone: phone,
      password: password,
    );
    _accounts.add(account);
    _currentUser = account;
    unawaited(_persist());
    // Signup does not log the user in; the session starts on login only.
    return account;
  }

  static Future<Account?> authenticate({
    required String phone,
    required String password,
  }) async {
    for (final account in _accounts) {
      if (account.phone == phone && account.password == password) {
        _currentUser = account;
        unawaited(_persistSession());
        return account;
      }
    }
    return null;
  }

  static Future<Account> signInWithGoogle({
    required String name,
    required String email,
  }) async {
    final normalisedEmail = email.trim().toLowerCase();

    for (final account in _accounts) {
      if (account.isGoogleAccount && account.email == normalisedEmail) {
        _currentUser = account;
        unawaited(_persistSession());
        return account;
      }
    }

    final account = Account(
      name: name.trim(),
      phone: '',
      password: '',
      email: normalisedEmail,
      isGoogleAccount: true,
    );
    _accounts.add(account);
    _currentUser = account;
    unawaited(_persist());
    unawaited(_persistSession());
    return account;
  }

  static Future<Account?> updateCurrentUser({
    required String name,
    String? phone,
    String? email,
    String? photoBase64,
  }) async {
    final current = _currentUser;
    if (current == null) return null;

    final index = _accounts.indexWhere(
      (account) => identical(account, current),
    );
    if (index < 0) return null;

    final updated = current.copyWith(
      name: name.trim(),
      phone: phone?.trim(),
      email: email?.trim().toLowerCase(),
      photoBase64: photoBase64,
    );

    final phoneTaken =
        updated.phone.isNotEmpty &&
        _accounts.any(
          (account) =>
              !identical(account, current) && account.phone == updated.phone,
        );
    final emailTaken =
        updated.email.isNotEmpty &&
        _accounts.any(
          (account) =>
              !identical(account, current) &&
              account.isGoogleAccount &&
              account.email == updated.email,
        );

    if (phoneTaken || emailTaken) return null;

    _accounts[index] = updated;
    _currentUser = updated;
    unawaited(_persist());
    unawaited(_persistSession());
    return updated;
  }

  static void logout() {
    _currentUser = null;
    unawaited(_persistSession());
  }

  static Future<void> _persist() async {
    await LocalStore.write(
      _fileName,
      jsonEncode(_accounts.map((account) => account.toJson()).toList()),
    );
  }

  static void resetForTesting() {
    _accounts.clear();
    _currentUser = null;
    _loaded = false;
  }
}
