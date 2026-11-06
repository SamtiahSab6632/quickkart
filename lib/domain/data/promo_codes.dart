import 'package:quick_kart/domain/data/order_store.dart';

/// Local availability rules for QuickKart promo codes.
///
/// The first promo is `quick20` — a flat 20% off the order — and it is only
/// valid on a customer's first order. Orders that were cancelled do not
/// consume the discount, so the code stays available for the next attempt.
class PromoCodeStore {
  PromoCodeStore._();

  /// The only code this build supports (case-insensitive, trimmed).
  static const String supportedCode = 'quick20';

  /// Flat discount applied by [supportedCode], in percent.
  static const int percentOff = 20;

  /// True while the user has not completed an order yet, so `quick20` can
  /// still be applied. A cancelled order keeps the promo alive.
  static bool get firstOrderAvailable {
    for (final order in OrderStore.orders) {
      if (order.status != 'Cancelled') return false;
    }
    return true;
  }

  /// True when [input] matches the supported code (ignored case/whitespace).
  static bool isSupported(String input) =>
      input.trim().toLowerCase() == supportedCode;

  /// Discount in rupees for [itemsTotal]; 0 when the code is not supported.
  static int discountFor(String input, int itemsTotal) =>
      isSupported(input) ? itemsTotal * percentOff ~/ 100 : 0;

  /// Friendly rejection message for the promo input, or null when the code
  /// can be applied right now. Shown inline in checkout, never as an error
  /// snackbar.
  static String? rejectionFor(String input) {
    if (input.trim().isEmpty) {
      return 'Please enter a promo code first, then tap Apply.';
    }
    if (!isSupported(input)) {
      return 'This code is not valid right now — try quick20.';
    }
    if (!firstOrderAvailable) {
      return 'quick20 works only on your first order — you have already used '
          'it once. Better luck on your next order!';
    }
    return null;
  }
}
