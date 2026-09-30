import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../models/app_notification.dart';

extension NotificationTypeStyle on NotificationType {
  IconData get icon => switch (this) {
        NotificationType.order => Icons.receipt_long_rounded,
        NotificationType.delivery => Icons.delivery_dining_rounded,
        NotificationType.offer => Icons.local_offer_rounded,
        NotificationType.system => Icons.notifications_rounded,
      };

  Color get color => switch (this) {
        NotificationType.order => AppColors.primary,
        NotificationType.delivery => AppColors.success,
        NotificationType.offer => const Color(0xFFE08A00),
        NotificationType.system => AppColors.body,
      };
}

class NotificationTile extends StatelessWidget {
  const NotificationTile({super.key, required this.notification, required this.onTap});

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final n = notification;
    final color = n.type.color;

    return Material(
      color: n.isRead ? Colors.white : AppColors.accentSoft.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: n.isRead ? AppColors.border : const Color(0xFFF4C9C4)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(n.type.icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            n.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: n.isRead ? FontWeight.w600 : FontWeight.w700,
                            ),
                          ),
                        ),
                        if (!n.isRead) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 9,
                            height: 9,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      n.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.body, fontSize: 13, height: 1.35),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      timeAgo(n.createdAt),
                      style: const TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
