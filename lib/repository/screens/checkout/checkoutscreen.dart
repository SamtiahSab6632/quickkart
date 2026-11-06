import 'package:quick_kart/domain/constants/appcolors.dart';
import 'package:quick_kart/domain/data/address_store.dart';
import 'package:quick_kart/domain/data/catalog_data.dart';
import 'package:quick_kart/domain/data/order_store.dart';
import 'package:quick_kart/domain/data/payment_methods.dart';
import 'package:quick_kart/domain/data/promo_codes.dart';
import 'package:quick_kart/domain/models/address.dart';
import 'package:quick_kart/domain/models/cart.dart';
import 'package:quick_kart/domain/models/order.dart';
import 'package:quick_kart/domain/models/payment_method.dart';
import 'package:quick_kart/repository/screens/account/savedaddressesscreen.dart';
import 'package:quick_kart/repository/screens/checkout/ordersuccessscreen.dart';
import 'package:quick_kart/repository/screens/payment/paymentprocessscreen.dart';
import 'package:quick_kart/repository/widgets/paymentmethodtile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({
    super.key,
    required this.items,
    required this.onOrderPlaced,
  });

  final List<CartLine> items;
  final VoidCallback onOrderPlaced;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  static const Set<String> _onlineMethodIds = {'card', 'jazzcash', 'easypaisa'};

  late String _selectedMethodId;
  late SavedAddress _address;
  bool _isPlacingOrder = false;
  String _appliedPromoCode = '';
  int _promoDiscount = 0;
  String? _promoError;
  final TextEditingController _promoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedMethodId = PaymentMethodStore.selectedId;
    _address = AddressStore.selected;
  }

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  int get _itemsTotal =>
      widget.items.fold(0, (total, line) => total + line.total);

  int get _deliveryFee => deliveryFeeFor(_itemsTotal);

  int get _total => _itemsTotal - _promoDiscount + _deliveryFee;

  PaymentMethod get _selectedMethod =>
      appPaymentMethods.firstWhere((method) => method.id == _selectedMethodId);

  Future<void> _changeAddress() async {
    final address = await Navigator.of(context).push<SavedAddress>(
      MaterialPageRoute(
        builder: (context) => const SavedAddressesScreen(selectionMode: true),
      ),
    );

    if (!mounted || address == null) return;
    setState(() => _address = address);
  }

  void _applyPromo() {
    if (_isPlacingOrder) return;

    FocusScope.of(context).unfocus();
    final input = _promoController.text;
    final rejection = PromoCodeStore.rejectionFor(input);

    setState(() {
      if (rejection != null) {
        _appliedPromoCode = '';
        _promoDiscount = 0;
        _promoError = rejection;
        return;
      }
      _appliedPromoCode = PromoCodeStore.supportedCode;
      _promoDiscount = PromoCodeStore.discountFor(input, _itemsTotal);
      _promoError = null;
    });
  }

  void _removePromo() {
    FocusScope.of(context).unfocus();
    setState(() {
      _appliedPromoCode = '';
      _promoDiscount = 0;
      _promoError = null;
      _promoController.clear();
    });
  }

  Future<void> _placeOrder() async {
    if (_isPlacingOrder) return;

    FocusScope.of(context).unfocus();

    var isPaid = false;
    var paymentRef = '';

    if (_onlineMethodIds.contains(_selectedMethod.id)) {
      setState(() => _isPlacingOrder = true);

      // Online methods must complete a payment before the order is placed.
      final result = await Navigator.of(context).push<PaymentResult>(
        MaterialPageRoute(
          builder: (context) =>
              PaymentProcessScreen(method: _selectedMethod, amount: _total),
        ),
      );

      if (!mounted) return;

      if (result == null) {
        // The user backed out of the payment screen; keep the cart intact.
        setState(() => _isPlacingOrder = false);
        return;
      }

      isPaid = true;
      paymentRef = result.reference;
    }

    setState(() => _isPlacingOrder = true);

    await Future<void>.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;

    final orderId =
        'QK${(DateTime.now().millisecondsSinceEpoch % 1000000).toString().padLeft(6, '0')}';
    final paymentMethod = _selectedMethod.name;
    final total = _total;
    final items = widget.items
        .map(
          (line) => OrderItem(
            productId: line.product.id,
            name: line.product.name,
            unit: line.product.unit,
            quantity: line.quantity,
            price: line.product.price,
          ),
        )
        .toList();

    OrderStore.add(
      Order(
        id: orderId,
        items: items,
        itemsTotal: _itemsTotal,
        deliveryFee: _deliveryFee,
        total: total,
        paymentMethod: paymentMethod,
        address: _address.fullAddress,
        placedAt: DateTime.now(),
        isPaid: isPaid,
        paymentRef: paymentRef,
        discount: _promoDiscount,
        promoCode: _appliedPromoCode,
      ),
    );

    widget.onOrderPlaced();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => OrderSuccessScreen(
          orderId: orderId,
          total: total,
          paymentMethod: paymentMethod,
          address: _address.fullAddress,
          isPaid: isPaid,
          paymentRef: paymentRef,
          discount: _promoDiscount,
          promoCode: _appliedPromoCode,
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
            'Checkout',
            style: TextStyle(
              fontFamily: 'bold',
              fontSize: 18,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            _buildSectionTitle('Delivery address'),
            _buildCard(
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _address.label,
                          style: const TextStyle(
                            fontFamily: 'bold',
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _address.fullAddress,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Regular',
                            fontSize: 11.5,
                            height: 1.4,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _changeAddress,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: const Size(0, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Change',
                      style: TextStyle(
                        fontFamily: 'bold',
                        fontSize: 11.5,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  Icon(Icons.bolt_rounded, size: 18, color: AppColors.primary),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Express delivery in 10 minutes',
                      style: TextStyle(
                        fontFamily: 'bold',
                        fontSize: 12,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            _buildSectionTitle('Order summary'),
            _buildCard(
              child: Column(
                children: [
                  for (var index = 0; index < widget.items.length; index++) ...[
                    if (index > 0)
                      const Divider(height: 18, color: AppColors.border),
                    _buildOrderLine(widget.items[index]),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 22),
            _buildSectionTitle('Promo code'),
            _buildCard(
              padding: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            key: const ValueKey('promo-field'),
                            controller: _promoController,
                            textCapitalization: TextCapitalization.characters,
                            autocorrect: false,
                            style: const TextStyle(
                              fontFamily: 'Regular',
                              fontSize: 13.5,
                              color: AppColors.textPrimary,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Enter code e.g. quick20',
                              hintStyle: const TextStyle(
                                fontFamily: 'Regular',
                                fontSize: 12.5,
                                color: AppColors.textSecondary,
                              ),
                              filled: true,
                              fillColor: AppColors.fieldBackground,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 13,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.border,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.border,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.primary,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            onPressed: _appliedPromoCode.isEmpty
                                ? _applyPromo
                                : _removePromo,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _appliedPromoCode.isEmpty
                                  ? AppColors.primary
                                  : AppColors.primarySoft,
                              foregroundColor: _appliedPromoCode.isEmpty
                                  ? Colors.white
                                  : AppColors.primaryDark,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              textStyle: const TextStyle(
                                fontFamily: 'bold',
                                fontSize: 13,
                                letterSpacing: 0.2,
                              ),
                            ),
                            child: Text(
                              _appliedPromoCode.isEmpty ? 'Apply' : 'Remove',
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_promoError != null) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            size: 15,
                            color: AppColors.danger,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _promoError!,
                              style: const TextStyle(
                                fontFamily: 'Regular',
                                fontSize: 11.5,
                                height: 1.45,
                                color: AppColors.danger,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else if (_appliedPromoCode.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 15,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '$_appliedPromoCode applied — you saved '
                              'Rs $_promoDiscount',
                              style: const TextStyle(
                                fontFamily: 'Regular',
                                fontSize: 11.5,
                                color: AppColors.success,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else if (PromoCodeStore.firstOrderAvailable) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(
                            Icons.local_offer_rounded,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'First order? quick20 gives you flat '
                              '${PromoCodeStore.percentOff}% off.',
                              style: const TextStyle(
                                fontFamily: 'Regular',
                                fontSize: 11.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),
            _buildSectionTitle('Payment method'),
            _buildCard(
              padding: EdgeInsets.zero,
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
                      selected:
                          appPaymentMethods[index].id == _selectedMethodId,
                      onTap: () {
                        setState(
                          () => _selectedMethodId = appPaymentMethods[index].id,
                        );
                        PaymentMethodStore.selectedId =
                            appPaymentMethods[index].id;
                      },
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 22),
            _buildSectionTitle('Bill details'),
            _buildCard(
              child: Column(
                children: [
                  _buildBillRow('Item total', 'Rs $_itemsTotal'),
                  const SizedBox(height: 8),
                  _buildBillRow(
                    'Delivery fee',
                    _deliveryFee == 0 ? 'FREE' : 'Rs $_deliveryFee',
                    valueColor: _deliveryFee == 0 ? AppColors.primary : null,
                  ),
                  if (_promoDiscount > 0) ...[
                    const SizedBox(height: 8),
                    _buildBillRow(
                      'Coupon $_appliedPromoCode',
                      '- Rs $_promoDiscount',
                      valueColor: AppColors.success,
                    ),
                  ],
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, color: AppColors.border),
                  ),
                  Row(
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontFamily: 'bold',
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Rs $_total',
                        style: const TextStyle(
                          fontFamily: 'bold',
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: 5),
                Text(
                  '100% secure payments',
                  style: TextStyle(
                    fontFamily: 'Regular',
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
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
              child: Row(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontFamily: 'Regular',
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        'Rs $_total',
                        style: const TextStyle(
                          fontFamily: 'bold',
                          fontSize: 18,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isPlacingOrder ? null : _placeOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AppColors.primary.withValues(
                            alpha: 0.6,
                          ),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isPlacingOrder
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                _onlineMethodIds.contains(_selectedMethodId)
                                    ? 'Pay & Place Order'
                                    : 'Place Order',
                                style: const TextStyle(
                                  fontFamily: 'bold',
                                  fontSize: 15,
                                  letterSpacing: 0.2,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'bold',
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(14),
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
      child: child,
    );
  }

  Widget _buildOrderLine(CartLine line) {
    return Row(
      children: [
        SizedBox(
          width: 26,
          child: Text(
            '${line.quantity}×',
            style: const TextStyle(
              fontFamily: 'Regular',
              fontSize: 11.5,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            line.product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Regular',
              fontSize: 12.5,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Rs ${line.total}',
          style: const TextStyle(
            fontFamily: 'bold',
            fontSize: 12.5,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildBillRow(String label, String value, {Color? valueColor}) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Regular',
            fontSize: 12.5,
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'bold',
            fontSize: 12.5,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
