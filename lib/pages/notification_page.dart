import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../api/notification_service.dart';
import '../widgets/notification/notification_card.dart'; // 👈 นำเข้า Card Widget ที่แยกไว้
import 'achievement_page.dart';

class NotificationPage extends StatefulWidget {
  final int userId;

  const NotificationPage({super.key, required this.userId});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() => _isLoading = true);
    final list = await NotificationService.getNotifications(widget.userId);
    if (mounted) {
      setState(() {
        _notifications = list;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'การแจ้งเตือนและความสำเร็จ',
          style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : _notifications.isEmpty
              ? const Center(child: Text('ยังไม่มีการแจ้งเตือนในขณะนี้'))
              : RefreshIndicator(
                  onRefresh: _fetchNotifications,
                  color: AppTheme.primaryColor,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final item = _notifications[index];
                      return NotificationCard(
                        item: item,
                        onTap: () async {
                          final bool isUnread = (item['is_unread'] ?? 0) == 1;
                          final String type = item['type'] ?? 'system';

                          if (isUnread && item['notification_id'] != null) {
                            await NotificationService.markAsRead(item['notification_id']);
                            _fetchNotifications();
                          }
                          if (type == 'achievement' && context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AchievementPage(userId: widget.userId),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
    );
  }
}