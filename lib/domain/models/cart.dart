import 'package:quick_kart/domain/models/catalog.dart';

class CartLine {
  const CartLine({required this.product, required this.quantity});

  final Product product;
  final int quantity;

  int get total => product.price * quantity;
}
