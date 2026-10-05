import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/utils/context_x.dart';
import '../data/info_content.dart';
import '../../../core/constants/spacing.dart';

/// Terms of Service and Privacy Policy, one tab each. Every tab ends with a
/// link that opens the full page in the browser.
class TermsPrivacyScreen extends StatelessWidget {
  const TermsPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Terms & Privacy'),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
        ),
        body: Column(
          children: [
            Container(
              // Space below the app bar grows a little on taller screens.
              margin: EdgeInsets.fromLTRB(
                16,
                (MediaQuery.sizeOf(context).height * 0.02).clamp(12.0, 20.0),
                16,
                12,
              ),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.border),
              ),
              child: TabBar(
                indicator: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.body,
                labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                splashBorderRadius: BorderRadius.circular(AppRadius.md),
                tabs: const [
                  Tab(height: 40, text: 'Terms of Service'),
                  Tab(height: 40, text: 'Privacy Policy'),
                ],
              ),
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  _SectionList(sections: termsTabSections, linkLabel: 'Read the full Terms of Service'),
                  _SectionList(sections: privacyTabSections, linkLabel: 'Read the full Privacy Policy'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionList extends StatelessWidget {
  const _SectionList({required this.sections, required this.linkLabel});

  final List<InfoSection> sections;
  final String linkLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 24 + MediaQuery.viewPaddingOf(context).bottom),
      children: [
        for (var i = 0; i < sections.length; i++) ...[
          Text(
            '${i + 1}. ${sections[i].heading}',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            sections[i].body,
            style: const TextStyle(color: AppColors.body, height: 1.5),
          ),
          const SizedBox(height: 16),
        ],
        _WebLink(label: linkLabel),
      ],
    );
  }
}

class _WebLink extends StatelessWidget {
  const _WebLink({required this.label});

  final String label;

  Future<void> _open(BuildContext context) async {
    var opened = false;
    try {
      opened = await launchUrl(Uri.parse(legalPageUrl), mode: LaunchMode.externalApplication);
    } catch (_) {}
    if (!opened && context.mounted) context.showError('Could not open the page.');
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceMuted,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: () => _open(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.public, color: AppColors.primary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w600),
                ),
              ),
              const Icon(Icons.open_in_new, color: AppColors.muted, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
