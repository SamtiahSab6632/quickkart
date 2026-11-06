class OrderItem {
  const OrderItem({
    required this.productId,
    required this.name,
    required this.unit,
    required this.quantity,
    required this.price,
  });

  final String productId;
  final String name;
  final String unit;
  final int quantity;
  final int price;

  int get total => price * quantity;

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'unit': unit,
      'quantity': quantity,
      'price': price,
    };
  }

  static OrderItem? fromJson(Map<String, dynamic> json) {
    final productId = (json['productId'] as String?) ?? '';
    final name = (json['name'] as String?) ?? '';
    if (productId.isEmpty || name.isEmpty) return null;

    return OrderItem(
      productId: productId,
      name: name,
      unit: (json['unit'] as String?) ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      price: (json['price'] as num?)?.toInt() ?? 0,
    );
  }
}

class Order {
  const Order({
    required this.id,
    required this.items,
    required this.itemsTotal,
    required this.deliveryFee,
    required this.total,
    required this.paymentMethod,
    required this.address,
    required this.placedAt,
    this.status = 'Confirmed',
    this.isPaid = false,
    this.paymentRef = '',
    this.discount = 0,
    this.promoCode = '',
  });

  final String id;
  final List<OrderItem> items;
  final int itemsTotal;
  final int deliveryFee;
  final int total;
  final String paymentMethod;
  final String address;
  final DateTime placedAt;
  final String status;

  /// True when the order was paid online (card, JazzCash, Easypaisa).
  final bool isPaid;

  /// Masked payment detail captured during the payment step, e.g. `•••• 4242`.
  final String paymentRef;

  /// Promo discount in rupees included in [total] (0 when no promo was used).
  final int discount;

  /// Promo code applied to this order, e.g. `quick20` (empty when none).
  final String promoCode;

  int get itemCount => items.fold(0, (total, item) => total + item.quantity);

  /// Returns a copy of this order with a new status (e.g. cancelled).
  Order withStatus(String status) {
    return Order(
      id: id,
      items: items,
      itemsTotal: itemsTotal,
      deliveryFee: deliveryFee,
      total: total,
      paymentMethod: paymentMethod,
      address: address,
      placedAt: placedAt,
      status: status,
      isPaid: isPaid,
      paymentRef: paymentRef,
      discount: discount,
      promoCode: promoCode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items.map((item) => item.toJson()).toList(),
      'itemsTotal': itemsTotal,
      'deliveryFee': deliveryFee,
      'total': total,
      'paymentMethod': paymentMethod,
      'address': address,
      'status': status,
      if (isPaid) 'isPaid': true,
      if (paymentRef.isNotEmpty) 'paymentRef': paymentRef,
      if (discount > 0) 'discount': discount,
      if (promoCode.isNotEmpty) 'promoCode': promoCode,
      'placedAt': placedAt.toIso8601String(),
    };
  }

  static Order? fromJson(Map<String, dynamic> json) {
    final id = (json['id'] as String?) ?? '';
    if (id.isEmpty) return null;

    final items =
        (json['items'] as List<dynamic>? ?? const <dynamic>[]) //
            .whereType<Map>()
            .map((item) => OrderItem.fromJson(Map<String, dynamic>.from(item)))
            .whereType<OrderItem>()
            .toList(growable: false);
    if (items.isEmpty) return null;

    final placedAtRaw = json['placedAt'];
    final placedAt = placedAtRaw is String
        ? DateTime.tryParse(placedAtRaw) ?? DateTime.now()
        : DateTime.now();

    return Order(
      id: id,
      items: items,
      itemsTotal: (json['itemsTotal'] as num?)?.toInt() ?? 0,
      deliveryFee: (json['deliveryFee'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
      paymentMethod: (json['paymentMethod'] as String?) ?? 'Cash on delivery',
      address: (json['address'] as String?) ?? '',
      placedAt: placedAt,
      status: (json['status'] as String?) ?? 'Confirmed',
      isPaid: json['isPaid'] as bool? ?? false,
      paymentRef: json['paymentRef'] as String? ?? '',
      discount: (json['discount'] as num?)?.toInt() ?? 0,
      promoCode: (json['promoCode'] as String?) ?? '',
    );
  }
}
