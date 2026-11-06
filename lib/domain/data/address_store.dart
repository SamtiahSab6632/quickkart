import 'dart:convert';

import 'package:quick_kart/domain/data/local_store.dart';
import 'package:quick_kart/domain/models/address.dart';

class AddressStore {
  AddressStore._();

  static const String _fileName = 'quickkart_addresses.json';

  static const SavedAddress defaultAddress = SavedAddress(
    id: 'home',
    label: 'Home',
    details: 'House 12, Street 4',
    area: 'Sector F-11',
    city: 'Islamabad',
  );

  static final List<SavedAddress> _addresses = [defaultAddress];

  static String _selectedId = 'home';
  static int _nextId = 1;
  static bool _loaded = false;

  static List<SavedAddress> get addresses =>
      List<SavedAddress>.unmodifiable(_addresses);

  static SavedAddress get selected {
    for (final address in _addresses) {
      if (address.id == _selectedId) return address;
    }
    return _addresses.first;
  }

  static String get selectedId => selected.id;

  static String nextId() {
    while (_addresses.any((address) => address.id == 'address-$_nextId')) {
      _nextId++;
    }
    return 'address-${_nextId++}';
  }

  static Future<void> load() async {
    if (_loaded) return;
    _loaded = true;

    final raw = await LocalStore.read(_fileName);
    if (raw == null || raw.isEmpty) return;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return;

      final loaded = ((decoded['addresses'] as List?) ?? const [])
          .whereType<Map>()
          .map((item) => SavedAddress.fromJson(Map<String, dynamic>.from(item)))
          .where(
            (address) =>
                address.id.isNotEmpty &&
                address.label.trim().isNotEmpty &&
                address.fullAddress.isNotEmpty,
          )
          .toList(growable: false);

      if (loaded.isEmpty) return;

      _addresses
        ..clear()
        ..addAll(loaded);

      var maxId = 0;
      for (final address in _addresses) {
        final match = RegExp(r'^address-(\d+)$').firstMatch(address.id);
        final number = match == null ? 0 : int.tryParse(match.group(1)!) ?? 0;
        if (number > maxId) maxId = number;
      }
      _nextId = maxId + 1;

      final savedSelected = (decoded['selectedId'] as String?) ?? '';
      _selectedId = _addresses.any((address) => address.id == savedSelected)
          ? savedSelected
          : _addresses.first.id;
    } catch (_) {
      // Ignore a corrupted addresses file and use the defaults.
    }
  }

  static void add(SavedAddress address) {
    _addresses.add(address);
    if (_addresses.length == 1) {
      _selectedId = address.id;
    }
    _persist();
  }

  static void update(SavedAddress address) {
    final index = _addresses.indexWhere((item) => item.id == address.id);
    if (index == -1) return;
    _addresses[index] = address;
    _persist();
  }

  static void select(String id) {
    if (!_addresses.any((address) => address.id == id)) return;
    if (_selectedId == id) return;
    _selectedId = id;
    _persist();
  }

  static bool remove(String id) {
    if (_addresses.length <= 1) return false;

    _addresses.removeWhere((address) => address.id == id);
    if (_selectedId == id) {
      _selectedId = _addresses.first.id;
    }
    _persist();
    return true;
  }

  static Future<void> _persist() async {
    // Persistence is best-effort and never blocks the UI.
    await LocalStore.write(
      _fileName,
      jsonEncode({
        'selectedId': _selectedId,
        'addresses': _addresses.map((address) => address.toJson()).toList(),
      }),
    );
  }

  static void resetForTesting() {
    _addresses
      ..clear()
      ..add(defaultAddress);
    _selectedId = 'home';
    _nextId = 1;
    _loaded = false;
  }
}
