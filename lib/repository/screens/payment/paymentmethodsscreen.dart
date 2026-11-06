import 'package:quick_kart/domain/constants/appcolors.dart';
import 'package:quick_kart/domain/data/payment_methods.dart';
import 'package:quick_kart/repository/widgets/paymentmethodtile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  String _selectedId = PaymentMethodStore.selectedId;

  void _selectMethod(String id, String name) {
    setState(() => _selectedId = id);
    PaymentMethodStore.selectedId = id;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            '$name set as default payment method',
            style: const TextStyle(fontFamily: 'Regular', fontSize: 13),
          ),
          backgroundColor: AppColors.textPrimary,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1400),
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
          title: const Text(
            'Payment Methods',
            style: TextStyle(
              fontFamily: 'bold',
              fontSize: 18,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Set your default payment method for faster checkout.',
              style: TextStyle(
                fontFamily: 'Regular',
                fontSize: 13,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A101828),
                    blurRadius: 14,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  for (
                    var index = 0;
                    index < appPaymentMethods.length;
                    index++
                  ) ...[
                    if (index > 0)
                      const Divider(
                        height: 1,
                        color: AppColors.border,
                        indent: 66,
                      ),
                    PaymentMethodTile(
                      method: appPaymentMethods[index],
                      selected: appPaymentMethods[index].id == _selectedId,
                      onTap: () => _selectMethod(
                        appPaymentMethods[index].id,
                        appPaymentMethods[index].name,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Your payment details are encrypted and safe with us.',
                      style: TextStyle(
                        fontFamily: 'Regular',
                        fontSize: 11.5,
                        height: 1.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
