import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quick_kart/domain/constants/appcolors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
            'About QuickKart',
            style: TextStyle(
              fontFamily: 'bold',
              fontSize: 18,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 22,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(26),
                      child: Image.asset(
                        'assets/images/quickkart_logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'QuickKart',
                    style: TextStyle(
                      fontFamily: 'bold',
                      fontSize: 26,
                      letterSpacing: -0.7,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Daily essentials, delivered in minutes.',
                    style: TextStyle(
                      fontFamily: 'Regular',
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'VERSION 1.0.0',
                      style: TextStyle(
                        fontFamily: 'bold',
                        fontSize: 8.5,
                        letterSpacing: 0.8,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A101828),
                    blurRadius: 14,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Shopping at the speed of life',
                    style: TextStyle(
                      fontFamily: 'bold',
                      fontSize: 17,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'QuickKart is a quick-commerce platform built to make everyday shopping effortless. From fresh groceries and dairy to snacks, personal care, and household essentials, we bring thousands of products from trusted neighbourhood stores to your doorstep in minutes.',
                    style: TextStyle(
                      fontFamily: 'Regular',
                      fontSize: 12.5,
                      height: 1.65,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'We combine a thoughtfully curated catalogue, transparent pricing, secure payments, and reliable delivery into one seamless experience — so you can spend less time shopping and more time on what matters.',
                    style: TextStyle(
                      fontFamily: 'Regular',
                      fontSize: 12.5,
                      height: 1.65,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.ink, AppColors.inkSoft],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.flag_outlined,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Our mission',
                        style: TextStyle(
                          fontFamily: 'bold',
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    'To simplify everyday life for families across Pakistan by making quality essentials accessible, affordable, and always just a few minutes away.',
                    style: TextStyle(
                      fontFamily: 'Regular',
                      fontSize: 12.5,
                      height: 1.6,
                      color: Color(0xD9FFFFFF),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Why QuickKart',
              style: TextStyle(
                fontFamily: 'bold',
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: const Column(
                children: [
                  _FeatureRow(
                    icon: Icons.bolt_rounded,
                    title: '10-minute delivery',
                    description:
                        'Lightning-fast delivery from stores close to you.',
                  ),
                  Divider(height: 1, indent: 58, color: AppColors.border),
                  _FeatureRow(
                    icon: Icons.verified_outlined,
                    title: 'Quality you can trust',
                    description:
                        'Fresh produce and genuine products, carefully packed.',
                  ),
                  Divider(height: 1, indent: 58, color: AppColors.border),
                  _FeatureRow(
                    icon: Icons.lock_outline_rounded,
                    title: 'Secure payments',
                    description:
                        'Cash on delivery, cards, JazzCash, and Easypaisa.',
                  ),
                  Divider(height: 1, indent: 58, color: AppColors.border),
                  _FeatureRow(
                    icon: Icons.support_agent_rounded,
                    title: 'Support that cares',
                    description:
                        'A real team ready to help when something is not right.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Column(
                children: [
                  Text(
                    'Made for Pakistan, with care.',
                    style: TextStyle(
                      fontFamily: 'bold',
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    '© 2026 QuickKart. All rights reserved.',
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
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 17, color: AppColors.primary),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'bold',
                    fontSize: 12.5,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontFamily: 'Regular',
                    fontSize: 11,
                    height: 1.45,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
