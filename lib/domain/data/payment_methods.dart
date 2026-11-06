import 'package:quick_kart/domain/constants/appcolors.dart';
import 'package:quick_kart/domain/models/payment_method.dart';
import 'package:flutter/material.dart';

const List<PaymentMethod> appPaymentMethods = [
  PaymentMethod(
    id: 'cod',
    name: 'Cash on Delivery',
    description: 'Pay when your order arrives',
    icon: Icons.payments_outlined,
    color: AppColors.primary,
  ),
  PaymentMethod(
    id: 'card',
    name: 'Debit / Credit Card',
    description: 'Visa, Mastercard, UnionPay',
    icon: Icons.credit_card_rounded,
    color: Color(0xFF2563EB),
  ),
  PaymentMethod(
    id: 'jazzcash',
    name: 'JazzCash',
    description: 'Pay with your JazzCash wallet',
    icon: Icons.phone_android_rounded,
    color: Color(0xFFD32F2F),
  ),
  PaymentMethod(
    id: 'easypaisa',
    name: 'Easypaisa',
    description: 'Pay with your Easypaisa wallet',
    icon: Icons.account_balance_wallet_outlined,
    color: Color(0xFF00897B),
  ),
];

class PaymentMethodStore {
  PaymentMethodStore._();

  static String selectedId = appPaymentMethods.first.id;
}
