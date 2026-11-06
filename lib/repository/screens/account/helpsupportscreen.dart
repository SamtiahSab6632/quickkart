import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quick_kart/domain/constants/appcolors.dart';
import 'package:quick_kart/domain/data/link_launcher.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const String supportPhone = '0340 6632190';
  static const String supportPhoneRaw = '03406632190';

  Future<void> _launchOrCopy(
    BuildContext context,
    String url,
    String fallbackMessage,
  ) async {
    final opened = await LinkLauncher.open(url);
    if (opened || !context.mounted) return;

    await Clipboard.setData(const ClipboardData(text: supportPhoneRaw));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            fallbackMessage,
            style: const TextStyle(fontFamily: 'Regular', fontSize: 13),
          ),
          backgroundColor: AppColors.textPrimary,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  Future<void> _copyNumber(BuildContext context) async {
    await Clipboard.setData(const ClipboardData(text: supportPhoneRaw));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'Support number copied',
            style: TextStyle(fontFamily: 'Regular', fontSize: 13),
          ),
          backgroundColor: AppColors.textPrimary,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
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
            'Help & Support',
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
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.ink, AppColors.inkSoft],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.support_agent_rounded,
                      size: 23,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'We are here to help',
                    style: TextStyle(
                      fontFamily: 'bold',
                      fontSize: 21,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Questions about an order, delivery, payment, or your account? Our support team is just a call away.',
                    style: TextStyle(
                      fontFamily: 'Regular',
                      fontSize: 12,
                      height: 1.55,
                      color: Color(0xCCFFFFFF),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.call_outlined,
                          size: 21,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 11),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Support helpline',
                                style: TextStyle(
                                  fontFamily: 'Regular',
                                  fontSize: 10.5,
                                  color: Color(0xB3FFFFFF),
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                supportPhone,
                                style: TextStyle(
                                  fontFamily: 'bold',
                                  fontSize: 18,
                                  letterSpacing: 0.4,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => _copyNumber(context),
                          tooltip: 'Copy number',
                          icon: const Icon(
                            Icons.copy_rounded,
                            size: 18,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 46,
                          child: ElevatedButton.icon(
                            onPressed: () => _launchOrCopy(
                              context,
                              'tel:$supportPhoneRaw',
                              'Could not open the dialer. Number copied instead.',
                            ),
                            icon: const Icon(Icons.call_rounded, size: 17),
                            label: const Text(
                              'Call now',
                              style: TextStyle(
                                fontFamily: 'bold',
                                fontSize: 13,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SizedBox(
                          height: 46,
                          child: OutlinedButton.icon(
                            onPressed: () => _launchOrCopy(
                              context,
                              'https://wa.me/923406632190',
                              'Could not open WhatsApp. Number copied instead.',
                            ),
                            icon: const Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 16,
                            ),
                            label: const Text(
                              'WhatsApp',
                              style: TextStyle(
                                fontFamily: 'bold',
                                fontSize: 13,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.28),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 14,
                        color: Color(0xB3FFFFFF),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Monday – Saturday, 9:00 AM – 10:00 PM',
                        style: TextStyle(
                          fontFamily: 'Regular',
                          fontSize: 10.5,
                          color: Color(0xB3FFFFFF),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Frequently asked questions',
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
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: const Column(
                children: [
                  _FaqTile(
                    question: 'How can I track my order?',
                    answer:
                        'Open Account → My Orders to see your latest order and its status. For live updates, call our support helpline.',
                  ),
                  Divider(height: 1, color: AppColors.border),
                  _FaqTile(
                    question: 'What if an item is missing or damaged?',
                    answer:
                        'Contact us on 0340 6632190 within 24 hours of delivery. Our team will review the issue and arrange a resolution.',
                  ),
                  Divider(height: 1, color: AppColors.border),
                  _FaqTile(
                    question: 'Which payment methods are supported?',
                    answer:
                        'QuickKart supports Cash on Delivery, debit and credit cards, JazzCash, and Easypaisa.',
                  ),
                  Divider(height: 1, color: AppColors.border),
                  _FaqTile(
                    question: 'Where does QuickKart deliver?',
                    answer:
                        'We currently deliver across Islamabad and are expanding to more cities soon. Enter your address at checkout to confirm availability.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.tips_and_updates_outlined,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Have your order ID ready when contacting support so we can help you faster.',
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

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 15),
      childrenPadding: const EdgeInsets.fromLTRB(15, 0, 15, 14),
      iconColor: AppColors.primary,
      collapsedIconColor: AppColors.textSecondary,
      shape: const Border(),
      collapsedShape: const Border(),
      title: Text(
        question,
        style: const TextStyle(
          fontFamily: 'bold',
          fontSize: 12.5,
          color: AppColors.textPrimary,
        ),
      ),
      children: [
        Text(
          answer,
          style: const TextStyle(
            fontFamily: 'Regular',
            fontSize: 11.5,
            height: 1.55,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
