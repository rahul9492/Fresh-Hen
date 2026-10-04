import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/open_link.dart';
import '../../../core/widgets/app_card.dart';
import '../../checkout/providers/checkout_providers.dart';

/// Help & Support: reach the store by phone call or WhatsApp. The number comes
/// from the admin app's settings, falling back to the built-in one.
class SupportScreen extends ConsumerWidget {
  const SupportScreen({super.key});

  static const _whatsAppGreen = Color(0xFF25D366);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fromAdmin = ref.watch(currentStoreSettingsProvider.select((s) => s.supportPhone.trim()));
    final phone = fromAdmin.isNotEmpty ? fromAdmin : AppConstants.supportPhone;
    final digits = supportDigits(phone);
    final display = supportDisplay(phone);

    return Scaffold(
      backgroundColor: AppColors.page,
      appBar: AppBar(title: const Text('Help & Support')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        children: [
          const Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.accentSoft,
              child: Icon(Icons.support_agent_rounded, size: 42, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'How can we help?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            'Questions about your order, cut quality, weight or refunds? Talk to us directly.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.body, fontSize: 13.5, height: 1.4),
          ),
          const SizedBox(height: 28),
          _ContactOption(
            icon: const Icon(Icons.call_rounded, color: Colors.white, size: 26),
            color: AppColors.primary,
            title: 'Call us',
            subtitle: display,
            onTap: () => openLink(
              context,
              Uri(scheme: 'tel', path: '+$digits'),
              error: 'Could not open the dialer.',
            ),
          ),
          const SizedBox(height: 12),
          _ContactOption(
            icon: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.white, size: 26),
            color: _whatsAppGreen,
            title: 'Chat on WhatsApp',
            subtitle: display,
            // wa.me opens the WhatsApp app when installed, otherwise WhatsApp Web.
            onTap: () => openLink(
              context,
              Uri.https('wa.me', '/$digits', {'text': 'Hi Fresh Hen, I need help with my order.'}),
              error: 'Could not open WhatsApp.',
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactOption extends StatelessWidget {
  const _ContactOption({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  /// White icon shown on the coloured tile.
  final Widget icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(14)),
            alignment: Alignment.center,
            child: icon,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: AppColors.body, fontSize: 13.5)),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded, size: 16, color: color),
        ],
      ),
    );
  }
}
