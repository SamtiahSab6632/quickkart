import 'package:quick_kart/domain/constants/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({
    super.key,
    required this.orderId,
    required this.total,
    required this.paymentMethod,
    required this.address,
    this.isPaid = false,
    this.paymentRef = '',
    this.discount = 0,
    this.promoCode = '',
  });

  final String orderId;
  final int total;
  final String paymentMethod;
  final String address;
  final bool isPaid;
  final String paymentRef;

  /// Promo discount in rupees subtracted from the items total (0 if none).
  final int discount;

  /// The promo code that produced [discount], e.g. `quick20`.
  final String promoCode;

  String get _paymentStatus {
    if (!isPaid) return 'Pay on delivery';
    return paymentRef.isEmpty ? 'Paid' : 'Paid • $paymentRef';
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            child: Column(
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 48,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Order placed successfully',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'bold',
                    fontSize: 23,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isPaid
                      ? 'Payment of Rs $total received. Your order will be '
                            'delivered in 10 minutes.'
                      : 'Your order will be delivered in 10 minutes.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Regular',
                    fontSize: 13,
                    height: 1.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 28),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow('Order ID', orderId),
                      const Divider(height: 1, color: AppColors.border),
                      _buildDetailRow('Payment method', paymentMethod),
                      const Divider(height: 1, color: AppColors.border),
                      _buildDetailRow('Payment status', _paymentStatus),
                      if (discount > 0) ...[
                        const Divider(height: 1, color: AppColors.border),
                        _buildDetailRow(
                          'Promo discount',
                          'Saved Rs $discount ($promoCode)',
                        ),
                      ],
                      const Divider(height: 1, color: AppColors.border),
                      _buildDetailRow('Order total', 'Rs $total'),
                      const Divider(height: 1, color: AppColors.border),
                      _buildDetailRow('Delivery address', address),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.delivery_dining_rounded,
                        size: 26,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Arriving in 10 minutes',
                              style: TextStyle(
                                fontFamily: 'bold',
                                fontSize: 12.5,
                                color: AppColors.primary,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'We will notify you when your order is on the way.',
                              style: TextStyle(
                                fontFamily: 'Regular',
                                fontSize: 10.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Keep this order ID handy for tracking your order.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Regular',
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Continue shopping',
                    style: TextStyle(
                      fontFamily: 'bold',
                      fontSize: 15,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Regular',
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'bold',
                fontSize: 12.5,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
