import 'package:flutter/material.dart';

import '../models/app_notification.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

String _timeAgo(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 1) return 'à l\'instant';
  if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'il y a ${diff.inHours} h';
  return 'il y a ${diff.inDays} j';
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) AppStateScope.of(context).markAllNotificationsRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          if (appState.notifications.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Column(
                children: [
                  Icon(Icons.notifications_none, color: AppColors.creamMuted.withValues(alpha: 0.6), size: 40),
                  const SizedBox(height: 12),
                  Text('Aucune notification pour le moment', style: textTheme.bodyMedium),
                ],
              ),
            )
          else
            ...appState.notifications.map((n) => _NotificationTile(notification: n)),

          const SizedBox(height: 24),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Text('PRÉFÉRENCES', style: textTheme.titleSmall?.copyWith(color: AppColors.creamMuted, letterSpacing: 1.0)),
          const SizedBox(height: 4),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: appState.emailOptIn,
            onChanged: (v) => appState.setOptIns(email: v, sms: appState.smsOptIn),
            activeThumbColor: AppColors.orange,
            title: Text('Offres par e-mail', style: textTheme.bodyLarge),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: appState.smsOptIn,
            onChanged: (v) => appState.setOptIns(email: appState.emailOptIn, sms: v),
            activeThumbColor: AppColors.orange,
            title: Text('Offres par SMS', style: textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.charcoalSoft,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: AppColors.orange.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: const Icon(Icons.notifications_outlined, color: AppColors.orange, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notification.title, style: textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(notification.message, style: textTheme.bodySmall),
                const SizedBox(height: 6),
                Text(_timeAgo(notification.date), style: textTheme.bodySmall?.copyWith(color: AppColors.creamMuted.withValues(alpha: 0.7))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
