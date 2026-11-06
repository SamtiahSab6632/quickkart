import 'package:quick_kart/domain/constants/appcolors.dart';
import 'package:quick_kart/domain/data/account_store.dart';
import 'package:quick_kart/domain/data/address_store.dart';
import 'package:quick_kart/domain/data/ai_store.dart';
import 'package:quick_kart/domain/data/order_store.dart';
import 'package:quick_kart/repository/screens/home/homescreen.dart';
import 'package:quick_kart/repository/screens/login/loginscreen.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([
    AccountStore.load(),
    OrderStore.load(),
    AddressStore.load(),
    AiStore.load(),
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QuickKart',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          surface: AppColors.surface,
        ),
        fontFamily: 'Regular',
        scaffoldBackgroundColor: AppColors.background,
        splashFactory: InkSparkle.splashFactory,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'bold',
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontFamily: 'bold', fontSize: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: AppColors.primary,
          selectionColor: AppColors.primarySoft,
          selectionHandleColor: AppColors.primary,
        ),
      ),
      home: AccountStore.currentUser == null
          ? const LoginScreen()
          : const HomeScreen(),
    );
  }
}
