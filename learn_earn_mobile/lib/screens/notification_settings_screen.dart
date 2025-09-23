import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _notificationsEnabled = false;
  bool _dailyReminders = false;
  bool _earningAlerts = false;
  bool _quizReminders = false;
  bool _achievementAlerts = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    try {
      final enabled = await NotificationService.instance
          .areNotificationsEnabled();
      setState(() {
        _notificationsEnabled = enabled;
        _dailyReminders = enabled;
        _earningAlerts = enabled;
        _quizReminders = enabled;
        _achievementAlerts = enabled;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _requestNotificationPermission() async {
    final granted = await NotificationService.instance.requestPermission();
    setState(() {
      _notificationsEnabled = granted;
    });

    if (granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification permission granted!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Notification permission denied. You can enable it in settings.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _openAppSettings() async {
    await NotificationService.instance.openAppSettings();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main notification toggle
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SwitchListTile(
                      title: const Text(
                        'Enable Notifications',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: const Text(
                        'Receive notifications from Learn & Earn',
                      ),
                      value: _notificationsEnabled,
                      onChanged: (value) {
                        if (value) {
                          _requestNotificationPermission();
                        } else {
                          setState(() {
                            _notificationsEnabled = false;
                          });
                        }
                      },
                      activeColor: const Color(0xFF2196F3),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Notification types
                  if (_notificationsEnabled) ...[
                    const Text(
                      'Notification Types',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildNotificationOption(
                      'Daily Reminders',
                      'Get reminded to complete your daily learning goals',
                      Icons.schedule,
                      _dailyReminders,
                      (value) => setState(() => _dailyReminders = value),
                    ),

                    _buildNotificationOption(
                      'Earning Alerts',
                      'Get notified when you earn coins or complete tasks',
                      Icons.monetization_on,
                      _earningAlerts,
                      (value) => setState(() => _earningAlerts = value),
                    ),

                    _buildNotificationOption(
                      'Quiz Reminders',
                      'Reminders to take quizzes and complete lessons',
                      Icons.quiz,
                      _quizReminders,
                      (value) => setState(() => _quizReminders = value),
                    ),

                    _buildNotificationOption(
                      'Achievement Alerts',
                      'Celebrate your achievements and milestones',
                      Icons.emoji_events,
                      _achievementAlerts,
                      (value) => setState(() => _achievementAlerts = value),
                    ),

                    const SizedBox(height: 30),

                    const SizedBox(height: 16),

                    // App settings button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _openAppSettings,
                        icon: const Icon(Icons.settings),
                        label: const Text('Open App Settings'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF2196F3),
                          side: const BorderSide(color: Color(0xFF2196F3)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    // Permission denied state
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.notifications_off,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Notifications Disabled',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Enable notifications to receive updates about your learning progress and earnings.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: _requestNotificationPermission,
                              icon: const Icon(Icons.notifications),
                              label: const Text('Enable Notifications'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2196F3),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildNotificationOption(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SwitchListTile(
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        secondary: Icon(
          icon,
          color: value ? const Color(0xFF2196F3) : Colors.grey,
        ),
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF2196F3),
      ),
    );
  }
}
