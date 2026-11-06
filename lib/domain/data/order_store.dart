import 'dart:async';
import 'dart:convert';

import 'package:quick_kart/domain/data/local_store.dart';
import 'package:quick_kart/domain/models/order.dart';

class OrderStore {
  OrderStore._();

  static const String _fileName = 'quickkart_orders.json';

  static final List<Order> _orders = [];
  static bool _loaded = false;

  static List<Order> get orders => List<Order>.unmodifiable(_orders);

  static int get orderCount => _orders.length;

  static Future<void> load() async {
    if (_loaded) return;
    _loaded = true;

    final raw = await LocalStore.read(_fileName);
    if (raw == null || raw.isEmpty) return;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        _orders
          ..clear()
          ..addAll(
            decoded
                .whereType<Map>()
                .map((item) => Order.fromJson(Map<String, dynamic>.from(item)))
                .whereType<Order>()
                .toList(growable: false),
          );
        _orders.sort((a, b) => b.placedAt.compareTo(a.placedAt));
      }
    } catch (_) {
      // Ignore a corrupted orders file and start fresh.
    }
  }

  static void add(Order order) {
    _orders.insert(0, order);
    _persist();
  }

  /// Cancels a confirmed order. Returns false when the order does not exist
  /// or is not in a state that can be cancelled.
  static bool cancelOrder(String id) {
    final index = _orders.indexWhere((order) => order.id == id);
    if (index < 0) return false;
    if (_orders[index].status != 'Confirmed') return false;

    _orders[index] = _orders[index].withStatus('Cancelled');
    _persist();
    return true;
  }

  static Order? findById(String id) {
    for (final order in _orders) {
      if (order.id == id) return order;
    }
    return null;
  }

  static void clear() {
    _orders.clear();
    _persist();
  }

  static Future<void> _persist() async {
    await LocalStore.write(
      _fileName,
      jsonEncode(_orders.map((order) => order.toJson()).toList()),
    );
  }

  static void resetForTesting() {
    _orders.clear();
    _loaded = false;
  }
}
