import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class NotificationCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onTap;

  const NotificationCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isUnread = (item['is_unread'] ?? 0) == 1;
    final String type = item['type'] ?? 'system';
    final String title = item['title'] ?? '';
    final String subtitle = item['subtitle'] ?? '';

    // 🎨 แมปไอคอนและสีตามประเภท
    IconData iconData = Icons.notifications_rounded;
    Color iconColor = AppTheme.primaryColor;

    if (type == 'achievement') {
      iconData = Icons.emoji_events_rounded;
      iconColor = Colors.amber.shade700;
    } else if (type == 'doctor') {
      iconData = Icons.medical_services_rounded;
      iconColor = Colors.teal;
    } else if (type == 'reminder') {
      iconData = Icons.alarm_rounded;
      iconColor = Colors.blue;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isUnread ? iconColor.withOpacity(0.3) : Colors.grey.withOpacity(0.12),
          width: isUnread ? 1.5 : 1.0,
        ),
      ),
      color: isUnread ? iconColor.withOpacity(0.02) : Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(iconData, color: iconColor, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: isUnread ? AppTheme.textPrimary : Colors.black87,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
        ),
        trailing: isUnread
            ? Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              )
            : null,
      ),
    );
  }
}