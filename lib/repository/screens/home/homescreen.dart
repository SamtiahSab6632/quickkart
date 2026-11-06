import 'dart:convert';

import 'package:quick_kart/domain/constants/appcolors.dart';
import 'package:quick_kart/domain/data/account_store.dart';
import 'package:quick_kart/domain/data/address_store.dart';
import 'package:quick_kart/domain/data/catalog_data.dart';
import 'package:quick_kart/domain/data/order_store.dart';
import 'package:quick_kart/domain/models/account.dart';
import 'package:quick_kart/domain/models/cart.dart';
import 'package:quick_kart/domain/models/catalog.dart';
import 'package:quick_kart/repository/screens/account/aboutscreen.dart';
import 'package:quick_kart/repository/screens/account/editprofilescreen.dart';
import 'package:quick_kart/repository/screens/account/helpsupportscreen.dart';
import 'package:quick_kart/repository/screens/account/ordersscreen.dart';
import 'package:quick_kart/repository/screens/account/savedaddressesscreen.dart';
import 'package:quick_kart/repository/screens/ai/aichatscreen.dart';
import 'package:quick_kart/repository/screens/category/categoryscreen.dart';
import 'package:quick_kart/repository/screens/checkout/checkoutscreen.dart';
import 'package:quick_kart/repository/screens/login/loginscreen.dart';
import 'package:quick_kart/repository/screens/payment/paymentmethodsscreen.dart';
import 'package:quick_kart/repository/screens/search/searchscreen.dart';
import 'package:quick_kart/repository/widgets/productcard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.phoneNumber = '3001234567'});

  final String phoneNumber;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final Map<String, int> _cart = {};

  String get _displayName {
    final user = AccountStore.currentUser;
    if (user != null && user.name.isNotEmpty) return user.name;
    return 'QuickKart User';
  }

  String get _displayContact {
    final user = AccountStore.currentUser;
    if (user != null && user.isGoogleAccount && user.email.isNotEmpty) {
      return user.email;
    }
    return '+92 ${user?.phone ?? widget.phoneNumber}';
  }

  Uint8List? get _profilePhotoBytes {
    final photo = AccountStore.currentUser?.photoBase64 ?? '';
    if (photo.isEmpty) return null;
    try {
      return base64Decode(photo);
    } catch (_) {
      return null;
    }
  }

  Widget _buildProfileAvatar() {
    final photo = _profilePhotoBytes;
    if (photo == null) {
      return const Icon(Icons.person_rounded, size: 29, color: Colors.white);
    }

    return ClipOval(
      child: Image.memory(
        photo,
        width: 58,
        height: 58,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.person_rounded, size: 29, color: Colors.white),
      ),
    );
  }

  int get _cartCount =>
      _cart.values.fold(0, (total, quantity) => total + quantity);

  List<Product> get _cartProducts =>
      appProducts.where((product) => _cart.containsKey(product.id)).toList();

  int get _itemsTotal => _cartProducts.fold(
    0,
    (total, product) => total + product.price * _cart[product.id]!,
  );

  int get _deliveryFee => deliveryFeeFor(_itemsTotal);

  List<CartLine> get _cartLines => _cartProducts
      .map(
        (product) =>
            CartLine(product: product, quantity: _cart[product.id] ?? 0),
      )
      .toList();

  void _addProduct(Product product) {
    setState(() {
      _cart.update(product.id, (quantity) => quantity + 1, ifAbsent: () => 1);
    });
  }

  void _addToCart(Product product) {
    _addProduct(product);
    _showMessage('${product.name} added to cart');
  }

  void _increment(Product product) {
    setState(() {
      _cart.update(product.id, (quantity) => quantity + 1, ifAbsent: () => 1);
    });
  }

  void _decrement(Product product) {
    setState(() {
      final quantity = _cart[product.id] ?? 0;
      if (quantity <= 1) {
        _cart.remove(product.id);
      } else {
        _cart[product.id] = quantity - 1;
      }
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(fontFamily: 'Regular', fontSize: 13),
          ),
          backgroundColor: AppColors.textPrimary,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1200),
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  void _openCategory(Category category) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CategoryScreen(
          category: category,
          products: productsForCategory(category.id),
          onAdd: _addProduct,
        ),
      ),
    );
  }

  void _openSearch() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SearchScreen(
          products: appProducts,
          onAdd: (product) {
            _addProduct(product);
            _showMessage('${product.name} added to cart');
          },
        ),
      ),
    );
  }

  void _openAiAssistant() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => AiChatScreen(onAdd: _addProduct)),
    );
  }

  Future<void> _openCheckout() async {
    if (_cart.isEmpty) return;

    var orderPlaced = false;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(
          items: _cartLines,
          onOrderPlaced: () {
            orderPlaced = true;
            _clearCart();
          },
        ),
      ),
    );

    if (mounted && orderPlaced) {
      setState(() => _selectedIndex = 0);
    }
  }

  void _clearCart() {
    if (!mounted) return;
    setState(() => _cart.clear());
  }

  void _handleClearCart() {
    setState(_cart.clear);
    _showMessage('Cart cleared');
  }

  void _openPaymentMethods() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const PaymentMethodsScreen()),
    );
  }

  Future<void> _openOrders() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const OrdersScreen()));
    if (mounted) setState(() {});
  }

  Future<void> _openSavedAddresses() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SavedAddressesScreen()),
    );
    if (mounted) setState(() {});
  }

  Future<void> _openEditProfile() async {
    final account = AccountStore.currentUser;
    if (account == null) {
      _showMessage('Please login to edit your profile.');
      return;
    }

    final updated = await Navigator.of(context).push<Account>(
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(account: account),
      ),
    );

    if (!mounted || updated == null) return;

    setState(() {});
    _showMessage('Profile updated successfully.');
  }

  void _openHelpSupport() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const HelpSupportScreen()));
  }

  void _openAbout() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const AboutScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final isHome = _selectedIndex == 0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: (isHome ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
          .copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: isHome ? _buildHome() : _buildTabContent(),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildHome() {
    final popularProducts = appProducts.take(8).toList();
    final essentialsProducts = appProducts
        .where(
          (product) => const {
            'staples',
            'spices',
            'frozen',
            'tea',
          }.contains(product.categoryId),
        )
        .take(8)
        .toList();
    final freshProducts = appProducts
        .where(
          (product) => const {
            'fruits',
            'vegetables',
            'dairy',
            'meat',
          }.contains(product.categoryId),
        )
        .take(10)
        .toList();

    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 28),
            children: [
              const SizedBox(height: 20),
              _buildCategories(),
              const SizedBox(height: 22),
              _buildPromoBanner(),
              const SizedBox(height: 26),
              _buildSectionHeader('Popular near you'),
              const SizedBox(height: 12),
              _buildProductGrid(popularProducts),
              const SizedBox(height: 26),
              _buildSectionHeader('Everyday essentials'),
              const SizedBox(height: 12),
              _buildProductGrid(essentialsProducts),
              const SizedBox(height: 26),
              _buildSectionHeader('Fresh picks'),
              const SizedBox(height: 12),
              _buildProductGrid(freshProducts),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.ink, AppColors.inkSoft],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 20),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      'assets/images/quickkart_logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Delivery in 10 minutes',
                        style: TextStyle(
                          fontFamily: 'bold',
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AddressStore.selected.shortAddress,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Regular',
                          fontSize: 11.5,
                          color: Color(0xB3FFFFFF),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: _openAiAssistant,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.18),
                      ),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => setState(() => _selectedIndex = 3),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.18),
                      ),
                    ),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      size: 21,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _openSearch,
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.search_rounded,
                        size: 22,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          'Search in QuickKart...',
                          style: TextStyle(
                            fontFamily: 'Regular',
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.mic_none_rounded,
                        size: 21,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Expanded(
                  child: _HeaderChip(
                    icon: Icons.bolt_rounded,
                    label: 'Express delivery',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _HeaderChip(
                    icon: Icons.auto_awesome_rounded,
                    label: 'AI Assistant',
                    onTap: _openAiAssistant,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: _HeaderChip(
                    icon: Icons.eco_outlined,
                    label: 'Fresh picks daily',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: appCategories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final category = appCategories[index];
          return GestureDetector(
            onTap: () => _openCategory(category),
            child: SizedBox(
              width: 68,
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: category.color,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.9),
                        width: 2,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0F101828),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Image.asset(
                      emojiAssetPath(category.emoji),
                      width: 40,
                      height: 40,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Text(
                        category.emoji,
                        style: const TextStyle(fontSize: 27),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Regular',
                      fontSize: 11.5,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.24),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: -46,
              right: -26,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -56,
              right: 52,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  color: AppColors.ink.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'FIRST ORDER',
                            style: TextStyle(
                              fontFamily: 'bold',
                              fontSize: 9,
                              letterSpacing: 1.1,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Flat 20% OFF',
                          style: TextStyle(
                            fontFamily: 'bold',
                            fontSize: 24,
                            letterSpacing: -0.4,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'On your first order above Rs 499',
                          style: TextStyle(
                            fontFamily: 'Regular',
                            fontSize: 12,
                            color: Color(0xE6FFFFFF),
                          ),
                        ),
                        const SizedBox(height: 13),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: const Text(
                            'USE CODE  QUICK20',
                            style: TextStyle(
                              fontFamily: 'bold',
                              fontSize: 10.5,
                              letterSpacing: 0.5,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.24),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.delivery_dining_rounded,
                      size: 44,
                      color: Colors.white,
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'bold',
                fontSize: 18,
                letterSpacing: -0.2,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => setState(() => _selectedIndex = 1),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(0, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'See all',
              style: TextStyle(
                fontFamily: 'bold',
                fontSize: 12.5,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid(List<Product> products) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 224,
      ),
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductCard(product: product, onAdd: () => _addToCart(product));
      },
    );
  }

  Widget _buildTabContent() {
    switch (_selectedIndex) {
      case 1:
        return _buildCategoriesTab();
      case 2:
        return _buildCartTab();
      case 3:
        return _buildAccountTab();
      default:
        return _buildHome();
    }
  }

  Widget _buildCategoriesTab() {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
        children: [
          const Text(
            'Shop by category',
            style: TextStyle(
              fontFamily: 'bold',
              fontSize: 22,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Everything you need, delivered in minutes.',
            style: TextStyle(
              fontFamily: 'Regular',
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: appCategories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              mainAxisExtent: 124,
            ),
            itemBuilder: (context, index) {
              final category = appCategories[index];
              final itemCount = productsForCategory(category.id).length;

              return Container(
                decoration: BoxDecoration(
                  color: category.color,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.9),
                    width: 2,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0F101828),
                      blurRadius: 12,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(22),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: () => _openCategory(category),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset(
                            emojiAssetPath(category.emoji),
                            width: 34,
                            height: 34,
                            fit: BoxFit.contain,
                            alignment: Alignment.centerLeft,
                            errorBuilder: (context, error, stackTrace) => Text(
                              category.emoji,
                              style: const TextStyle(fontSize: 30),
                            ),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  category.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: 'bold',
                                    fontSize: 14,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 16,
                                color: Color(0x991A1A1A),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$itemCount items',
                            style: const TextStyle(
                              fontFamily: 'Regular',
                              fontSize: 10.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCartTab() {
    if (_cart.isEmpty) {
      return _buildEmptyCart();
    }

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'My Cart',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'bold',
                      fontSize: 22,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  '$_cartCount item${_cartCount == 1 ? '' : 's'}',
                  style: const TextStyle(
                    fontFamily: 'Regular',
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 4),
                TextButton.icon(
                  onPressed: _handleClearCart,
                  icon: const Icon(Icons.delete_sweep_rounded, size: 16),
                  label: const Text(
                    'Clear cart',
                    style: TextStyle(fontFamily: 'bold', fontSize: 12),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(0, 36),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: _cartProducts.length,
              separatorBuilder: (context, index) => const Divider(
                height: 24,
                thickness: 1,
                color: AppColors.border,
              ),
              itemBuilder: (context, index) {
                return _buildCartItem(_cartProducts[index]);
              },
            ),
          ),
          _buildCartSummary(),
        ],
      ),
    );
  }

  Widget _buildCartItem(Product product) {
    final quantity = _cart[product.id] ?? 0;

    return Row(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: product.tint,
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: Image.asset(
            emojiAssetPath(product.emoji),
            width: 40,
            height: 40,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                Text(product.emoji, style: const TextStyle(fontSize: 28)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'bold',
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                product.unit,
                style: const TextStyle(
                  fontFamily: 'Regular',
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Rs ${product.price * quantity}',
                style: const TextStyle(
                  fontFamily: 'bold',
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _buildQuantityStepper(product, quantity),
      ],
    );
  }

  Widget _buildQuantityStepper(Product product, int quantity) {
    return Container(
      height: 34,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStepperButton(
            icon: Icons.remove_rounded,
            onTap: () => _decrement(product),
          ),
          SizedBox(
            width: 20,
            child: Center(
              child: Text(
                '$quantity',
                style: const TextStyle(
                  fontFamily: 'bold',
                  fontSize: 12,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          _buildStepperButton(
            icon: Icons.add_rounded,
            onTap: () => _increment(product),
          ),
        ],
      ),
    );
  }

  Widget _buildStepperButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 8),
        child: Icon(icon, size: 16, color: AppColors.primary),
      ),
    );
  }

  Widget _buildCartSummary() {
    final total = _itemsTotal + _deliveryFee;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildBillRow('Item total', 'Rs $_itemsTotal'),
          const SizedBox(height: 8),
          _buildBillRow(
            'Delivery fee',
            _deliveryFee == 0 ? 'FREE' : 'Rs $_deliveryFee',
            valueColor: _deliveryFee == 0 ? AppColors.primary : null,
          ),
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
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                'Rs $total',
                style: const TextStyle(
                  fontFamily: 'bold',
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _openCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Proceed to Checkout',
                style: TextStyle(
                  fontFamily: 'bold',
                  fontSize: 15,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ],
      ),
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

  Widget _buildEmptyCart() {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shopping_cart_outlined,
                  size: 36,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Your cart is empty',
                style: TextStyle(
                  fontFamily: 'bold',
                  fontSize: 21,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Add your favourite products and they will show up here.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Regular',
                  fontSize: 13,
                  height: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 46,
                child: ElevatedButton(
                  onPressed: () => setState(() => _selectedIndex = 0),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Start shopping',
                    style: TextStyle(fontFamily: 'bold', fontSize: 13.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountTab() {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
        children: [
          const Text(
            'Account',
            style: TextStyle(
              fontFamily: 'bold',
              fontSize: 22,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.24),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -48,
                  right: -20,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.28),
                            width: 1.5,
                          ),
                        ),
                        child: _buildProfileAvatar(),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'bold',
                                fontSize: 17,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _displayContact,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Regular',
                                fontSize: 12.5,
                                color: Color(0xD9FFFFFF),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: _openEditProfile,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.edit_outlined,
                                size: 15,
                                color: Colors.white,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'Edit profile',
                                style: TextStyle(
                                  fontFamily: 'bold',
                                  fontSize: 10.5,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(18),
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
                _buildAccountTile(
                  icon: Icons.receipt_long_outlined,
                  title: 'My Orders',
                  onTap: _openOrders,
                  trailingLabel: OrderStore.orderCount > 0
                      ? '${OrderStore.orderCount}'
                      : null,
                ),
                _buildAccountDivider(),
                _buildAccountTile(
                  icon: Icons.location_on_outlined,
                  title: 'Saved Addresses',
                  onTap: _openSavedAddresses,
                ),
                _buildAccountDivider(),
                _buildAccountTile(
                  icon: Icons.credit_card_outlined,
                  title: 'Payment Methods',
                  onTap: _openPaymentMethods,
                ),
                _buildAccountDivider(),
                _buildAccountTile(
                  icon: Icons.support_agent_rounded,
                  title: 'Help & Support',
                  onTap: _openHelpSupport,
                ),
                _buildAccountDivider(),
                _buildAccountTile(
                  icon: Icons.info_outline_rounded,
                  title: 'About QuickKart',
                  onTap: _openAbout,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 50,
            child: OutlinedButton.icon(
              onPressed: _confirmLogout,
              icon: const Icon(
                Icons.logout_rounded,
                size: 18,
                color: Color(0xFFD32F2F),
              ),
              label: const Text(
                'Log out',
                style: TextStyle(
                  fontFamily: 'bold',
                  fontSize: 13.5,
                  color: Color(0xFFD32F2F),
                ),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFF0C9C9)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountTile({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    String? trailingLabel,
  }) {
    return ListTile(
      onTap: onTap ?? () => _showMessage('$title is coming soon'),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: AppColors.primary),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Regular',
          fontSize: 13.5,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingLabel != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              margin: const EdgeInsets.only(right: 5),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                trailingLabel,
                style: const TextStyle(
                  fontFamily: 'bold',
                  fontSize: 10,
                  color: AppColors.primary,
                ),
              ),
            ),
          const Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      indent: 64,
      color: AppColors.border,
    );
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Log out?',
            style: TextStyle(
              fontFamily: 'bold',
              fontSize: 18,
              color: AppColors.textPrimary,
            ),
          ),
          content: const Text(
            'Are you sure you want to log out?',
            style: TextStyle(
              fontFamily: 'Regular',
              fontSize: 13.5,
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'bold',
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(
                'Log out',
                style: TextStyle(
                  fontFamily: 'bold',
                  fontSize: 13,
                  color: Color(0xFFD32F2F),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    AccountStore.logout();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          navigationBarTheme: NavigationBarThemeData(
            height: 70,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            elevation: 0,
            indicatorColor: AppColors.primarySoft,
            indicatorShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              final selected = states.contains(WidgetState.selected);
              return TextStyle(
                fontFamily: selected ? 'SemiBold' : 'Regular',
                fontSize: 10.5,
                color: selected ? AppColors.primary : AppColors.textSecondary,
              );
            }),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() => _selectedIndex = index);
          },
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home_outlined, color: AppColors.textSecondary),
              selectedIcon: Icon(Icons.home_rounded, color: AppColors.primary),
              label: 'Home',
            ),
            const NavigationDestination(
              icon: Icon(
                Icons.grid_view_outlined,
                color: AppColors.textSecondary,
              ),
              selectedIcon: Icon(
                Icons.grid_view_rounded,
                color: AppColors.primary,
              ),
              label: 'Categories',
            ),
            NavigationDestination(
              icon: _buildCartIcon(selected: false),
              selectedIcon: _buildCartIcon(selected: true),
              label: 'Cart',
            ),
            const NavigationDestination(
              icon: Icon(
                Icons.person_outline_rounded,
                color: AppColors.textSecondary,
              ),
              selectedIcon: Icon(
                Icons.person_rounded,
                color: AppColors.primary,
              ),
              label: 'Account',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartIcon({required bool selected}) {
    return Badge(
      isLabelVisible: _cartCount > 0,
      backgroundColor: AppColors.primary,
      label: Text(
        '$_cartCount',
        style: const TextStyle(fontFamily: 'Regular', fontSize: 9),
      ),
      child: Icon(
        selected ? Icons.shopping_cart_rounded : Icons.shopping_cart_outlined,
        color: selected ? AppColors.primary : AppColors.textSecondary,
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Regular',
                fontSize: 10.5,
                color: Color(0xCCFFFFFF),
              ),
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return chip;
    return GestureDetector(onTap: onTap, child: chip);
  }
}
