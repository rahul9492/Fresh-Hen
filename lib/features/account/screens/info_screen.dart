import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../data/info_content.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key, required this.title, required this.sections});

  final String title;
  final List<InfoSection> sections;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: sections.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, i) => Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(sections[i].heading, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(
                sections[i].body,
                style: const TextStyle(color: AppColors.body, height: 1.45),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
