import 'package:quick_kart/domain/data/account_store.dart';
import 'package:quick_kart/domain/data/address_store.dart';
import 'package:quick_kart/domain/data/ai_store.dart';
import 'package:quick_kart/domain/data/catalog_data.dart';
import 'package:quick_kart/domain/data/order_store.dart';
import 'package:quick_kart/domain/data/payment_methods.dart';
import 'package:quick_kart/domain/data/promo_codes.dart';
import 'package:quick_kart/domain/models/account.dart';
import 'package:quick_kart/domain/models/address.dart';
import 'package:quick_kart/domain/models/cart.dart';
import 'package:quick_kart/domain/models/catalog.dart';
import 'package:quick_kart/domain/models/order.dart';
import 'package:quick_kart/repository/screens/account/savedaddressesscreen.dart';
import 'package:quick_kart/repository/screens/ai/aichatscreen.dart';
import 'package:quick_kart/repository/screens/checkout/checkoutscreen.dart';
import 'package:quick_kart/repository/screens/home/homescreen.dart';
import 'package:quick_kart/repository/screens/login/loginscreen.dart';
import 'package:quick_kart/repository/screens/login/signupscreen.dart';
import 'package:quick_kart/repository/screens/search/searchscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// In-memory stand-in for the native `quickkart/storage` channel so tests can
/// exercise the same files the app writes on a device.
final Map<String, String> _fakeStorage = {};

void _installFakeStorage() {
  TestWidgetsFlutterBinding.ensureInitialized();
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(const MethodChannel('quickkart/storage'), (
        MethodCall call,
      ) async {
        final arguments = call.arguments;
        if (arguments is! Map) return null;
        final args = Map<String, dynamic>.from(arguments);

        switch (call.method) {
          case 'read':
            return _fakeStorage[args['name'] as String];
          case 'write':
            _fakeStorage[args['name'] as String] = args['content'] as String;
            return true;
        }
        return null;
      });
}

Future<void> _flushPendingWrites(WidgetTester tester) {
  return tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 20)),
  );
}

void main() {
  setUp(() {
    AccountStore.resetForTesting();
    OrderStore.resetForTesting();
    AddressStore.resetForTesting();
    AiStore.resetForTesting();
  });

  testWidgets(
    'saved addresses are stored in the database and restored after restart',
    (WidgetTester tester) async {
      _installFakeStorage();

      AddressStore.resetForTesting();
      AddressStore.add(
        const SavedAddress(
          id: 'address-1',
          label: 'Work',
          details: 'Office 3rd Floor, Blue Area',
          area: 'G-7',
          city: 'Islamabad',
        ),
      );
      AddressStore.select('address-1');
      await _flushPendingWrites(tester);

      // Simulate an app restart: same storage, fresh in-memory state.
      AddressStore.resetForTesting();
      await AddressStore.load();

      expect(AddressStore.addresses.length, 2);
      expect(AddressStore.selectedId, 'address-1');
      expect(
        AddressStore.selected.fullAddress,
        'Office 3rd Floor, Blue Area, G-7, Islamabad',
      );
    },
  );

  testWidgets(
    'editing a saved address saves on the first attempt without any error',
    (WidgetTester tester) async {
      AddressStore.resetForTesting();

      await tester.pumpWidget(const MaterialApp(home: SavedAddressesScreen()));
      await tester.pumpAndSettle();

      // Open the card menu, then the edit dialog.
      await tester.tap(find.byIcon(Icons.more_vert_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit address').last);
      await tester.pumpAndSettle();

      // Change the house details and save: pre-filled fields must never
      // raise validation errors, and the first save tap must succeed.
      await tester.enterText(
        find.widgetWithText(TextFormField, 'House / street'),
        'House 99, Street 8',
      );
      await tester.tap(find.text('Save address'));
      await tester.pumpAndSettle();

      expect(find.textContaining('is required'), findsNothing);
      expect(find.textContaining('Address updated'), findsOneWidget);
      expect(find.textContaining('House 99, Street 8'), findsOneWidget);
      expect(AddressStore.addresses.single.details, 'House 99, Street 8');
    },
  );

  testWidgets(
    'a new address saves in one tap with the optional fields left empty',
    (WidgetTester tester) async {
      AddressStore.resetForTesting();

      await tester.pumpWidget(const MaterialApp(home: SavedAddressesScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add new address'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'House / street'),
        'Flat 5, Gulberg III',
      );
      await tester.tap(find.text('Save address'));
      await tester.pumpAndSettle();

      // Area and city are optional: leaving them empty must not block saving.
      expect(find.textContaining('is required'), findsNothing);
      expect(find.textContaining('Address added'), findsOneWidget);
      expect(find.textContaining('Flat 5, Gulberg III'), findsOneWidget);
      expect(AddressStore.addresses.length, 2);
      expect(
        AddressStore.addresses.last.fullAddress,
        'Flat 5, Gulberg III, Islamabad',
      );
    },
  );

  test('catalog imagery covers every product and category', () async {
    TestWidgetsFlutterBinding.ensureInitialized();

    expect(appCategories.length, greaterThanOrEqualTo(16));
    expect(appProducts.length, greaterThanOrEqualTo(75));

    for (final category in appCategories) {
      expect(
        productsForCategory(category.id).length,
        greaterThanOrEqualTo(3),
        reason: '${category.title} has too few products',
      );
    }

    final emojis = <String>{
      for (final category in appCategories) category.emoji,
      for (final product in appProducts) product.emoji,
    };
    for (final emoji in emojis) {
      final data = await rootBundle.load(emojiAssetPath(emoji));
      expect(data.lengthInBytes, greaterThan(1000));
    }
  });

  testWidgets('gemini key is saved on the device and restored after restart', (
    WidgetTester tester,
  ) async {
    _installFakeStorage();

    await AiStore.saveKey('test-gemini-key');
    await _flushPendingWrites(tester);

    // Simulate an app restart: same storage, fresh in-memory state.
    AiStore.resetForTesting();
    await AiStore.load();

    expect(AiStore.hasKey, isTrue);
    expect(AiStore.apiKey, 'test-gemini-key');

    // The key can be removed again.
    await AiStore.saveKey('');
    await _flushPendingWrites(tester);
    AiStore.resetForTesting();
    await AiStore.load();
    expect(AiStore.hasKey, isFalse);
  });

  testWidgets('ai assistant suggests products in demo mode', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('AI Assistant'));
    await tester.pumpAndSettle();

    // Demo banner is visible until a key is saved.
    expect(find.textContaining('Demo mode'), findsOneWidget);

    await tester.tap(find.text('Find cheap milk'));
    await tester.pump();
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Amul Taaza Milk'), findsOneWidget);
    expect(find.text('ADD'), findsWidgets);

    await tester.tap(find.text('ADD').first);
    await tester.pump();

    expect(find.textContaining('added to cart'), findsOneWidget);

    await tester.pumpAndSettle();
  });

  testWidgets('gemini key can be saved from the chat screen', (
    WidgetTester tester,
  ) async {
    _installFakeStorage();
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(MaterialApp(home: AiChatScreen(onAdd: (_) {})));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Gemini API key'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('ai-key-field')),
      'test-gemini-key',
    );
    await tester.tap(find.byKey(const ValueKey('save-ai-key')));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(AiStore.apiKey, 'test-gemini-key');
    // No demo banner once a key is saved.
    expect(find.textContaining('Demo mode'), findsNothing);

    await _flushPendingWrites(tester);
  });

  test('profile photo is saved with the account', () async {
    await AccountStore.register(
      name: 'Ayesha Khan',
      phone: '3001234567',
      password: 'secret123',
    );

    final updated = await AccountStore.updateCurrentUser(
      name: 'Ayesha Khan',
      phone: '3001234567',
      photoBase64: 'cGhvdG8=',
    );

    expect(updated?.photoBase64, 'cGhvdG8=');
    expect(AccountStore.currentUser?.photoBase64, 'cGhvdG8=');

    final restored = Account.fromJson(updated!.toJson());
    expect(restored.photoBase64, 'cGhvdG8=');
  });

  testWidgets('login session is restored after an app restart', (
    WidgetTester tester,
  ) async {
    _installFakeStorage();
    _fakeStorage.clear();

    await AccountStore.register(
      name: 'Ayesha Khan',
      phone: '3001234567',
      password: 'secret123',
    );
    await AccountStore.authenticate(phone: '3001234567', password: 'secret123');
    await _flushPendingWrites(tester);

    expect(AccountStore.currentUser?.phone, '3001234567');

    // Simulate closing and reopening the app with the same storage.
    AccountStore.resetForTesting();
    expect(AccountStore.currentUser, isNull);

    await AccountStore.load();
    expect(AccountStore.currentUser?.name, 'Ayesha Khan');
    expect(AccountStore.currentUser?.phone, '3001234567');

    // Logging out clears the stored session too.
    AccountStore.logout();
    await _flushPendingWrites(tester);

    AccountStore.resetForTesting();
    await AccountStore.load();
    expect(AccountStore.currentUser, isNull);
  });

  testWidgets('google login session is restored after an app restart', (
    WidgetTester tester,
  ) async {
    _installFakeStorage();
    _fakeStorage.clear();

    await AccountStore.signInWithGoogle(
      name: 'Ayesha Khan',
      email: 'ayesha.khan@gmail.com',
    );
    await _flushPendingWrites(tester);

    AccountStore.resetForTesting();
    await AccountStore.load();

    expect(AccountStore.currentUser?.name, 'Ayesha Khan');
    expect(AccountStore.currentUser?.email, 'ayesha.khan@gmail.com');
  });

  testWidgets('placed orders are restored after an app restart', (
    WidgetTester tester,
  ) async {
    _installFakeStorage();
    _fakeStorage.clear();

    final placedAt = DateTime(2026, 11, 4, 14, 30);
    OrderStore.add(
      Order(
        id: 'QK123456',
        items: [
          const OrderItem(
            productId: 'amul-milk',
            name: 'Amul Taaza Milk',
            unit: '500 ml',
            quantity: 2,
            price: 290,
          ),
        ],
        itemsTotal: 580,
        deliveryFee: 0,
        total: 580,
        paymentMethod: 'Cash on delivery',
        address: 'House 12, Street 4, Sector F-11, Islamabad',
        placedAt: placedAt,
      ),
    );
    await _flushPendingWrites(tester);

    // Simulate closing and reopening the app with the same storage.
    OrderStore.resetForTesting();
    expect(OrderStore.orderCount, 0);

    await OrderStore.load();

    expect(OrderStore.orderCount, 1);
    final restored = OrderStore.orders.first;
    expect(restored.id, 'QK123456');
    expect(restored.total, 580);
    expect(restored.items.single.name, 'Amul Taaza Milk');
    expect(restored.items.single.quantity, 2);
    expect(restored.placedAt, placedAt);
  });

  test('only confirmed orders can be cancelled', () {
    OrderStore.resetForTesting();
    OrderStore.add(
      Order(
        id: 'QKCANCEL1',
        items: [
          const OrderItem(
            productId: 'amul-milk',
            name: 'Amul Taaza Milk',
            unit: '500 ml',
            quantity: 1,
            price: 290,
          ),
        ],
        itemsTotal: 290,
        deliveryFee: 29,
        total: 319,
        paymentMethod: 'Cash on Delivery',
        address: 'House 12, Street 4, Sector F-11, Islamabad',
        placedAt: DateTime(2026, 11, 4, 16, 0),
      ),
    );

    expect(OrderStore.cancelOrder('QKCANCEL1'), isTrue);
    expect(OrderStore.orders.single.status, 'Cancelled');

    // A cancelled order cannot be cancelled again.
    expect(OrderStore.cancelOrder('QKCANCEL1'), isFalse);
    // Unknown ids cannot be cancelled.
    expect(OrderStore.cancelOrder('QKUNKNOWN'), isFalse);
  });

  testWidgets('my orders can cancel a placed order', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.ensureVisible(find.text('ADD').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('ADD').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1800));

    await tester.tap(find.text('Cart'));
    await tester.pumpAndSettle();

    ScaffoldMessenger.of(
      tester.element(find.byType(Scaffold).first),
    ).hideCurrentSnackBar();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Proceed to Checkout'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Place Order'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Place Order'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pumpAndSettle();

    expect(find.text('Order placed successfully'), findsOneWidget);

    await tester.tap(find.text('Continue shopping'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Account'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('My Orders'));
    await tester.pumpAndSettle();

    expect(find.text('Confirmed'), findsOneWidget);
    expect(find.text('Cancel order'), findsOneWidget);

    // Open the cancel confirmation dialog.
    await tester.tap(find.text('Cancel order'));
    await tester.pumpAndSettle();

    expect(find.text('Cancel this order?'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('confirm-cancel-order')));
    await tester.pump();

    expect(
      find.textContaining(RegExp('Order QK\\d+ cancelled')),
      findsOneWidget,
    );

    await tester.pumpAndSettle();

    expect(find.text('Cancelled'), findsOneWidget);
    expect(find.text('Cancel order'), findsNothing);
    expect(find.textContaining('No payment was due'), findsOneWidget);
    expect(OrderStore.orders.single.status, 'Cancelled');
  });

  testWidgets('login screen opens the signup screen', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    await tester.tap(find.text('Create an account'));
    await tester.pumpAndSettle();

    expect(find.byType(SignupScreen), findsOneWidget);
    expect(find.text('Create your account'), findsOneWidget);
  });

  testWidgets('login screen renders the mobile number and password form', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('+92'), findsOneWidget);
    expect(find.text('Mobile number'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Create an account'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
  });

  testWidgets('login screen validates the mobile number', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    await tester.enterText(find.byType(TextFormField).first, '98765');
    await tester.ensureVisible(find.text('Login'));
    await tester.tap(find.text('Login'));
    await tester.pump();

    expect(
      find.text('Enter a valid mobile number (e.g. 0300 1234567)'),
      findsOneWidget,
    );
  });

  testWidgets('login screen validates the password', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    await tester.enterText(find.byType(TextFormField).first, '03001234567');
    await tester.ensureVisible(find.text('Login'));
    await tester.tap(find.text('Login'));
    await tester.pump();

    expect(find.text('Please enter your password'), findsOneWidget);
  });

  testWidgets('login rejects an account that does not exist', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    await tester.enterText(find.byType(TextFormField).first, '03001234567');
    await tester.enterText(find.byType(TextFormField).last, 'secret123');
    await tester.ensureVisible(find.text('Login'));
    await tester.tap(find.text('Login'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 450));

    expect(
      find.text('No account found. Please create an account first.'),
      findsOneWidget,
    );
  });

  testWidgets('signup returns to login and then login opens home', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    await tester.tap(find.text('Create an account'));
    await tester.pumpAndSettle();
    expect(find.byType(SignupScreen), findsOneWidget);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Ayesha Khan');
    await tester.enterText(fields.at(1), '03001234567');
    await tester.enterText(fields.at(2), 'secret123');
    await tester.enterText(fields.at(3), 'secret123');

    final signupButton = find.widgetWithText(ElevatedButton, 'Create account');
    await tester.ensureVisible(signupButton);
    await tester.pumpAndSettle();
    await tester.tap(signupButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 450));
    await tester.pumpAndSettle();

    expect(find.byType(SignupScreen), findsNothing);
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(
      find.text('Account created successfully. Please login to continue.'),
      findsOneWidget,
    );
    expect(AccountStore.currentUser, isNull);
    expect(AccountStore.accounts.single.phone, '3001234567');
    final phoneField = tester.widget<TextFormField>(
      find.byType(TextFormField).first,
    );
    expect(phoneField.controller?.text, '3001234567');

    await tester.enterText(find.byType(TextFormField).last, 'secret123');
    await tester.ensureVisible(find.text('Login'));
    await tester.tap(find.text('Login'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 450));
    await tester.pumpAndSettle();

    expect(find.text('Delivery in 10 minutes'), findsOneWidget);
    expect(AccountStore.currentUser?.name, 'Ayesha Khan');
  });

  testWidgets('signup rejects a password confirmation mismatch', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: SignupScreen()));

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Ayesha Khan');
    await tester.enterText(fields.at(1), '03001234567');
    await tester.enterText(fields.at(2), 'secret123');
    await tester.enterText(fields.at(3), 'secret999');

    final signupButton = find.widgetWithText(ElevatedButton, 'Create account');
    await tester.ensureVisible(signupButton);
    await tester.pumpAndSettle();
    await tester.tap(signupButton);
    await tester.pump();

    expect(find.text('Passwords do not match'), findsOneWidget);
    expect(AccountStore.accounts, isEmpty);
  });

  testWidgets('continue with Google signs in and opens home', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    await tester.ensureVisible(find.text('Continue with Google'));
    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();

    expect(find.text('Choose a Google account for QuickKart.'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('google-name-field')),
      'Ayesha Khan',
    );
    await tester.enterText(
      find.byKey(const ValueKey('google-email-field')),
      'ayesha.khan@gmail.com',
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 450));
    await tester.pumpAndSettle();

    expect(find.text('Delivery in 10 minutes'), findsOneWidget);
    expect(AccountStore.currentUser?.name, 'Ayesha Khan');
    expect(AccountStore.currentUser?.email, 'ayesha.khan@gmail.com');
    expect(AccountStore.currentUser?.isGoogleAccount, isTrue);

    await tester.tap(find.text('Account'));
    await tester.pumpAndSettle();

    expect(find.text('Ayesha Khan'), findsOneWidget);
    expect(find.text('ayesha.khan@gmail.com'), findsOneWidget);
  });

  testWidgets('edit profile updates the name and mobile number', (
    WidgetTester tester,
  ) async {
    await AccountStore.register(
      name: 'Ayesha Khan',
      phone: '3001234567',
      password: 'secret123',
    );

    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.tap(find.text('Account'));
    await tester.pumpAndSettle();

    expect(find.text('Edit profile'), findsOneWidget);
    await tester.tap(find.text('Edit profile'));
    await tester.pumpAndSettle();

    expect(find.text('Profile details'), findsOneWidget);
    expect(find.text('Choose from gallery'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('profile-name-field')),
      'Ayesha Ali',
    );
    await tester.enterText(
      find.byKey(const ValueKey('profile-phone-field')),
      '03011234567',
    );
    await tester.tap(find.text('Save changes'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(AccountStore.currentUser?.name, 'Ayesha Ali');
    expect(AccountStore.currentUser?.phone, '3011234567');
    expect(find.text('Ayesha Ali'), findsOneWidget);
    expect(find.text('+92 3011234567'), findsOneWidget);
    expect(find.text('Profile updated successfully.'), findsOneWidget);
  });

  testWidgets('edit profile updates a Google account email', (
    WidgetTester tester,
  ) async {
    await AccountStore.signInWithGoogle(
      name: 'Ayesha Khan',
      email: 'ayesha.khan@gmail.com',
    );

    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.tap(find.text('Account'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Edit profile'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('profile-email-field')), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('profile-email-field')),
      'ayesha.ali@gmail.com',
    );
    await tester.tap(find.text('Save changes'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(AccountStore.currentUser?.email, 'ayesha.ali@gmail.com');
    expect(find.text('ayesha.ali@gmail.com'), findsOneWidget);
  });

  testWidgets('login with a registered account opens home', (
    WidgetTester tester,
  ) async {
    await AccountStore.register(
      name: 'Ayesha Khan',
      phone: '3001234567',
      password: 'secret123',
    );
    AccountStore.logout();

    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    await tester.enterText(find.byType(TextFormField).first, '03001234567');
    await tester.enterText(find.byType(TextFormField).last, 'secret123');
    await tester.ensureVisible(find.text('Login'));
    await tester.tap(find.text('Login'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 450));
    await tester.pumpAndSettle();

    expect(find.text('Delivery in 10 minutes'), findsOneWidget);

    await tester.tap(find.text('Account'));
    await tester.pumpAndSettle();

    expect(find.text('Ayesha Khan'), findsOneWidget);
    expect(find.text('+92 3001234567'), findsOneWidget);
  });

  testWidgets('login rejects an incorrect password', (
    WidgetTester tester,
  ) async {
    await AccountStore.register(
      name: 'Ayesha Khan',
      phone: '3001234567',
      password: 'secret123',
    );
    AccountStore.logout();

    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    await tester.enterText(find.byType(TextFormField).first, '03001234567');
    await tester.enterText(find.byType(TextFormField).last, 'wrongpass');
    await tester.ensureVisible(find.text('Login'));
    await tester.tap(find.text('Login'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 450));

    expect(find.text('Incorrect mobile number or password.'), findsOneWidget);
  });

  testWidgets('categories tab opens category products', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.tap(find.text('Categories'));
    await tester.pumpAndSettle();

    expect(find.text('Shop by category'), findsOneWidget);

    await tester.tap(find.text('Dairy'));
    await tester.pumpAndSettle();

    expect(find.text('Amul Taaza Milk'), findsOneWidget);
    expect(find.text('Farm Eggs'), findsOneWidget);
  });

  testWidgets('home search opens the search screen', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    await tester.tap(find.text('Search in QuickKart...'));
    await tester.pumpAndSettle();

    expect(find.byType(SearchScreen), findsOneWidget);
    expect(find.text('Popular searches'), findsOneWidget);
    expect(find.text('All products'), findsOneWidget);
    expect(find.text('${appProducts.length} items'), findsOneWidget);
  });

  testWidgets('search filters products by name', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SearchScreen(products: appProducts, onAdd: (product) {}),
      ),
    );
    await tester.pump();

    await tester.enterText(find.byKey(const ValueKey('search-field')), 'milk');
    await tester.pump();

    expect(find.text('Results for "milk"'), findsOneWidget);
    expect(find.text('Amul Taaza Milk'), findsOneWidget);
    expect(find.text('Dairy Milk Chocolate'), findsOneWidget);
    expect(find.text('Farm Eggs'), findsNothing);
    expect(find.text('2 items'), findsOneWidget);
  });

  testWidgets('search shows an empty state with clear button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SearchScreen(products: appProducts, onAdd: (_) {}),
      ),
    );
    await tester.pump();

    await tester.enterText(find.byKey(const ValueKey('search-field')), 'pizza');
    await tester.pump();

    expect(find.text('No products found'), findsOneWidget);
    expect(find.text('Results for "pizza"'), findsOneWidget);
    expect(
      find.text(
        'We could not find anything for "pizza". Try a different keyword.',
      ),
      findsOneWidget,
    );

    await tester.enterText(find.byKey(const ValueKey('search-field')), '');
    await tester.pump();

    expect(find.text('No products found'), findsNothing);
    expect(find.text('All products'), findsOneWidget);
  });

  testWidgets('search results can be added to the cart', (
    WidgetTester tester,
  ) async {
    final added = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        home: SearchScreen(
          products: appProducts,
          onAdd: (product) => added.add(product.id),
        ),
      ),
    );
    await tester.pump();

    await tester.enterText(
      find.byKey(const ValueKey('search-field')),
      'bananas',
    );
    await tester.pump();

    await tester.tap(find.text('ADD'));
    await tester.pump();

    expect(added, contains('bananas'));
    expect(find.text('Fresh Bananas added to cart'), findsOneWidget);
  });

  testWidgets('search popular term opens filtered results', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SearchScreen(products: appProducts, onAdd: (_) {}),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Juice'));
    await tester.pump();

    expect(find.text('Results for "Juice"'), findsOneWidget);
    expect(find.text('Orange Juice'), findsOneWidget);
    expect(find.text('Cola'), findsNothing);
  });

  testWidgets('cart shows selected products and totals', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    await tester.ensureVisible(find.text('ADD').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('ADD').first);
    await tester.pump();
    await tester.tap(find.text('ADD').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1800));

    await tester.tap(find.text('Cart'));
    await tester.pumpAndSettle();

    expect(find.text('My Cart'), findsOneWidget);
    expect(find.text('Amul Taaza Milk'), findsOneWidget);
    expect(find.text('Rs 580'), findsNWidgets(3));
    expect(find.text('FREE'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('clear cart button empties the cart tab', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    await tester.ensureVisible(find.text('ADD').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('ADD').first);
    await tester.pump(const Duration(milliseconds: 1800));

    await tester.tap(find.text('Cart'));
    await tester.pumpAndSettle();

    expect(find.text('My Cart'), findsOneWidget);
    expect(find.text('Amul Taaza Milk'), findsOneWidget);

    await tester.tap(find.text('Clear cart'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.textContaining('Cart cleared'), findsOneWidget);
    expect(find.text('Your cart is empty'), findsOneWidget);
    expect(find.text('My Cart'), findsNothing);
    expect(find.text('Amul Taaza Milk'), findsNothing);

    await tester.pump(const Duration(milliseconds: 1800));
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('account tab shows profile and options', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.tap(find.text('Account'));
    await tester.pumpAndSettle();

    expect(find.text('QuickKart User'), findsOneWidget);
    expect(find.text('+92 3001234567'), findsOneWidget);
    expect(find.text('My Orders'), findsOneWidget);
    expect(find.text('Log out'), findsOneWidget);
  });

  testWidgets('logging out clears the account and returns to login', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await AccountStore.register(
      name: 'Ayesha Khan',
      phone: '3001234567',
      password: 'secret123',
    );

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.tap(find.text('Account'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Log out'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Log out'));
    await tester.pumpAndSettle();

    expect(AccountStore.currentUser, isNull);
    expect(find.text('Welcome back'), findsOneWidget);
  });

  testWidgets('checkout places an order and clears the cart', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.ensureVisible(find.text('ADD').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('ADD').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1800));

    await tester.tap(find.text('Cart'));
    await tester.pumpAndSettle();

    ScaffoldMessenger.of(
      tester.element(find.byType(Scaffold).first),
    ).hideCurrentSnackBar();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Proceed to Checkout'));
    await tester.pumpAndSettle();

    expect(find.text('Checkout'), findsOneWidget);
    expect(find.text('Cash on Delivery'), findsOneWidget);
    expect(find.text('JazzCash'), findsOneWidget);
    expect(find.text('Place Order'), findsOneWidget);

    await tester.ensureVisible(find.text('Place Order'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Place Order'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pumpAndSettle();

    expect(find.text('Order placed successfully'), findsOneWidget);
    expect(find.text('Cash on Delivery'), findsOneWidget);
    expect(find.text('Pay on delivery'), findsOneWidget);

    await tester.tap(find.text('Continue shopping'));
    await tester.pumpAndSettle();
    expect(find.text('Delivery in 10 minutes'), findsOneWidget);

    await tester.tap(find.text('Cart'));
    await tester.pumpAndSettle();
    expect(find.text('Your cart is empty'), findsOneWidget);

    await tester.tap(find.text('Account'));
    await tester.pumpAndSettle();
    expect(find.text('My Orders'), findsOneWidget);

    await tester.tap(find.text('My Orders'));
    await tester.pumpAndSettle();

    expect(find.text('Amul Taaza Milk'), findsOneWidget);
    expect(find.text('Cash on Delivery • Pay on delivery'), findsOneWidget);
    expect(find.textContaining('House 12, Street 4'), findsOneWidget);
  });

  testWidgets('card payment collects details and places a paid order', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.ensureVisible(find.text('ADD').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('ADD').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1800));

    await tester.tap(find.text('Cart'));
    await tester.pumpAndSettle();

    ScaffoldMessenger.of(
      tester.element(find.byType(Scaffold).first),
    ).hideCurrentSnackBar();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Proceed to Checkout'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Debit / Credit Card'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Debit / Credit Card'));
    await tester.pump();

    expect(find.text('Pay & Place Order'), findsOneWidget);

    await tester.tap(find.text('Pay & Place Order'));
    await tester.pumpAndSettle();

    expect(find.text('Card payment'), findsOneWidget);
    expect(find.text('Pay Rs 319'), findsOneWidget);

    // Submitting with invalid details keeps the payment screen open.
    await tester.enterText(
      find.byKey(const ValueKey('card-number-field')),
      '4242424242424242',
    );
    await tester.enterText(
      find.byKey(const ValueKey('card-expiry-field')),
      '1228',
    );
    await tester.enterText(find.byKey(const ValueKey('card-cvv-field')), '12');
    await tester.enterText(find.byKey(const ValueKey('card-name-field')), 'A');
    await tester.pump();

    await tester.tap(find.text('Pay Rs 319'));
    await tester.pump();

    expect(find.text('3-4 digits'), findsOneWidget);
    expect(find.text('Enter the name printed on the card'), findsOneWidget);
    expect(find.text('Card payment'), findsOneWidget);

    // Fix the details and pay.
    await tester.enterText(find.byKey(const ValueKey('card-cvv-field')), '123');
    await tester.enterText(
      find.byKey(const ValueKey('card-name-field')),
      'Ali Raza',
    );
    await tester.pump();

    await tester.tap(find.text('Pay Rs 319'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pumpAndSettle();

    expect(find.text('Order placed successfully'), findsOneWidget);
    expect(find.text('Payment status'), findsOneWidget);
    expect(find.text('Paid • •••• 4242'), findsOneWidget);
    expect(
      find.text(
        'Payment of Rs 319 received. Your order will be '
        'delivered in 10 minutes.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Continue shopping'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cart'));
    await tester.pumpAndSettle();
    expect(find.text('Your cart is empty'), findsOneWidget);

    await tester.tap(find.text('Account'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('My Orders'));
    await tester.pumpAndSettle();

    expect(find.textContaining('•••• 4242'), findsOneWidget);
  });

  testWidgets('jazzcash wallet payment places a paid order', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.ensureVisible(find.text('ADD').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('ADD').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1800));

    await tester.tap(find.text('Cart'));
    await tester.pumpAndSettle();

    ScaffoldMessenger.of(
      tester.element(find.byType(Scaffold).first),
    ).hideCurrentSnackBar();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Proceed to Checkout'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('JazzCash'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('JazzCash'));
    await tester.pump();

    await tester.tap(find.text('Pay & Place Order'));
    await tester.pumpAndSettle();

    expect(find.text('JazzCash payment'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('wallet-number-field')),
      '03451234567',
    );
    await tester.enterText(
      find.byKey(const ValueKey('wallet-mpin-field')),
      '1234',
    );
    await tester.pump();

    await tester.tap(find.text('Pay Rs 319'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pumpAndSettle();

    expect(find.text('Order placed successfully'), findsOneWidget);
    expect(find.text('Paid • 0345•••4567'), findsOneWidget);
  });

  testWidgets('cancelling the payment screen keeps the cart intact', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.ensureVisible(find.text('ADD').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('ADD').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1800));

    await tester.tap(find.text('Cart'));
    await tester.pumpAndSettle();

    ScaffoldMessenger.of(
      tester.element(find.byType(Scaffold).first),
    ).hideCurrentSnackBar();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Proceed to Checkout'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Debit / Credit Card'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Debit / Credit Card'));
    await tester.pump();

    await tester.tap(find.text('Pay & Place Order'));
    await tester.pumpAndSettle();

    expect(find.text('Card payment'), findsOneWidget);

    // Back out of the payment screen.
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.text('Checkout'), findsOneWidget);
    expect(find.text('Pay & Place Order'), findsOneWidget);
    expect(OrderStore.orderCount, 0);
  });

  testWidgets('account payment methods screen lists options', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.tap(find.text('Account'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Payment Methods'));
    await tester.pumpAndSettle();

    expect(
      find.text('Set your default payment method for faster checkout.'),
      findsOneWidget,
    );
    expect(find.text('Cash on Delivery'), findsOneWidget);
    expect(find.text('Debit / Credit Card'), findsOneWidget);
    expect(find.text('JazzCash'), findsOneWidget);
    expect(find.text('Easypaisa'), findsOneWidget);
  });

  testWidgets('my orders shows an empty state before ordering', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.tap(find.text('Account'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('My Orders'));
    await tester.pumpAndSettle();

    expect(find.text('No orders yet'), findsOneWidget);
  });

  testWidgets('saved addresses shows the default home address', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.tap(find.text('Account'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Saved Addresses'));
    await tester.pumpAndSettle();

    expect(
      find.text('House 12, Street 4, Sector F-11, Islamabad'),
      findsOneWidget,
    );
    expect(find.text('Add new address'), findsOneWidget);
    expect(find.text('DEFAULT'), findsOneWidget);
  });

  testWidgets('help and support shows the contact number', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.tap(find.text('Account'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Help & Support'));
    await tester.pumpAndSettle();

    expect(find.text('We are here to help'), findsOneWidget);
    expect(find.text('0340 6632190'), findsOneWidget);
    expect(find.text('Frequently asked questions'), findsOneWidget);
  });

  testWidgets('about quickkart shows the brand description', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.tap(find.text('Account'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('About QuickKart'));
    await tester.pumpAndSettle();

    expect(find.text('Shopping at the speed of life'), findsOneWidget);
    expect(find.textContaining('quick-commerce platform'), findsOneWidget);
    expect(find.text('VERSION 1.0.0'), findsOneWidget);
  });

  test('quick20 gives a flat 20% discount on the first order only', () {
    OrderStore.resetForTesting();

    expect(PromoCodeStore.firstOrderAvailable, isTrue);
    expect(PromoCodeStore.discountFor('quick20', 290), 58);
    expect(PromoCodeStore.discountFor(' QUICK20 ', 290), 58);
    expect(PromoCodeStore.discountFor('quick10', 290), 0);

    // Unknown codes are rejected with a friendly hint instead of an error.
    expect(PromoCodeStore.rejectionFor('quick10'), contains('quick20'));
    expect(PromoCodeStore.rejectionFor('quick20'), isNull);

    // Completing an order consumes the promo.
    OrderStore.add(
      Order(
        id: 'QK001',
        items: const [
          OrderItem(
            productId: 'amul-milk',
            name: 'Amul Taaza Milk',
            unit: '500 ml',
            quantity: 1,
            price: 290,
          ),
        ],
        itemsTotal: 290,
        deliveryFee: 29,
        total: 319,
        paymentMethod: 'Cash on Delivery',
        address: 'House 12, Street 4, Sector F-11, Islamabad',
        placedAt: DateTime(2026, 11, 5, 10, 0),
      ),
    );
    expect(PromoCodeStore.firstOrderAvailable, isFalse);
    expect(PromoCodeStore.rejectionFor('quick20'), isNotNull);

    // Cancelling frees the promo up again for the next attempt.
    expect(OrderStore.cancelOrder('QK001'), isTrue);
    expect(PromoCodeStore.firstOrderAvailable, isTrue);
    expect(PromoCodeStore.rejectionFor('quick20'), isNull);
  });

  test('order model keeps the promo discount through persistence', () {
    final order = Order(
      id: 'QK002',
      items: const [
        OrderItem(
          productId: 'amul-milk',
          name: 'Amul Taaza Milk',
          unit: '500 ml',
          quantity: 1,
          price: 290,
        ),
      ],
      itemsTotal: 290,
      deliveryFee: 29,
      total: 261,
      paymentMethod: 'Cash on Delivery',
      address: 'House 12, Street 4, Sector F-11, Islamabad',
      placedAt: DateTime(2026, 11, 5, 11, 0),
      discount: 58,
      promoCode: 'quick20',
    );

    expect(order.withStatus('Cancelled').discount, 58);
    expect(order.withStatus('Cancelled').promoCode, 'quick20');

    final restored = Order.fromJson(order.toJson());
    expect(restored!.total, 261);
    expect(restored.discount, 58);
    expect(restored.promoCode, 'quick20');

    // Orders without a promo keep working with the legacy file format.
    final legacy = Order.fromJson({
      'id': 'QK003',
      'items': [
        const OrderItem(
          productId: 'amul-milk',
          name: 'Amul Taaza Milk',
          unit: '500 ml',
          quantity: 1,
          price: 290,
        ).toJson(),
      ],
      'itemsTotal': 290,
      'deliveryFee': 29,
      'total': 319,
      'paymentMethod': 'Cash on Delivery',
      'address': 'House 12, Street 4',
      'status': 'Confirmed',
    });
    expect(legacy!.discount, 0);
    expect(legacy.promoCode, '');
  });

  testWidgets('checkout applies quick20 and shows the discounted bill', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    PaymentMethodStore.selectedId = 'cod';

    final product = appProducts.firstWhere((item) => item.id == 'amul-milk');
    await tester.pumpWidget(
      MaterialApp(
        home: CheckoutScreen(
          items: [CartLine(product: product, quantity: 1)],
          onOrderPlaced: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    // The first-order hint is visible until a promo code is applied.
    expect(find.textContaining('First order? quick20'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const ValueKey('promo-field')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('promo-field')),
      'quick20',
    );
    await tester.tap(find.text('Apply'));
    await tester.pump();

    // Amul 290 with 20% off: Rs 58 saved, Rs 29 delivery, Rs 261 total.
    expect(find.text('Coupon quick20'), findsOneWidget);
    expect(find.text('- Rs 58'), findsOneWidget);
    expect(find.textContaining('you saved Rs 58'), findsOneWidget);
    expect(find.text('Rs 261'), findsNWidgets(2));

    await tester.ensureVisible(find.text('Place Order'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Place Order'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pumpAndSettle();

    expect(find.text('Order placed successfully'), findsOneWidget);
    expect(find.text('Saved Rs 58 (quick20)'), findsOneWidget);

    final placed = OrderStore.orders.single;
    expect(placed.total, 261);
    expect(placed.discount, 58);
    expect(placed.promoCode, 'quick20');
  });

  testWidgets('checkout rejects an unknown promo code inline', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    PaymentMethodStore.selectedId = 'cod';

    final product = appProducts.firstWhere((item) => item.id == 'amul-milk');
    await tester.pumpWidget(
      MaterialApp(
        home: CheckoutScreen(
          items: [CartLine(product: product, quantity: 1)],
          onOrderPlaced: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const ValueKey('promo-field')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('promo-field')),
      'QUICK10',
    );
    await tester.tap(find.text('Apply'));
    await tester.pump();

    // A friendly inline message appears; the bill stays unchanged.
    expect(find.textContaining('not valid right now'), findsOneWidget);
    expect(find.textContaining('Coupon'), findsNothing);
    expect(find.text('Rs 319'), findsNWidgets(2));
  });

  testWidgets('tapping a product opens the details screen', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Amul Taaza Milk').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Amul Taaza Milk').first);
    await tester.pumpAndSettle();

    // Only the details route is visible now; price shows in hero and bar.
    expect(find.text('Amul Taaza Milk'), findsOneWidget);
    expect(find.text('Rs 290'), findsNWidgets(2));
    expect(find.textContaining('fresh toned dairy'), findsOneWidget);
    expect(find.text('ADD TO CART'), findsOneWidget);

    await tester.tap(find.text('ADD TO CART'));
    await tester.pump();
    expect(find.textContaining('added to cart'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    // The add went through the shared callback into the cart.
    await tester.tap(find.text('Cart'));
    await tester.pumpAndSettle();
    expect(find.text('Amul Taaza Milk'), findsOneWidget);
    expect(find.text('Proceed to Checkout'), findsOneWidget);
  });
}
