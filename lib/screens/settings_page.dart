import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notificationsEnabled = true;
  bool soundEnabled = true;
  bool autoSyncEnabled = true;
  bool darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF607D8B),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: const Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notifications Section
            _buildSectionCard(
              'Notifications',
              Icons.notifications,
              const Color(0xFF2196F3),
              [
                _buildSwitchTile(
                  'Push Notifications',
                  'Receive notifications on your device',
                  notificationsEnabled,
                  (value) => setState(() => notificationsEnabled = value),
                ),
                _buildSwitchTile(
                  'Daily Reminders',
                  'Get reminded to learn every day',
                  true,
                  (value) {},
                ),
                _buildSwitchTile(
                  'Achievement Alerts',
                  'Celebrate when you unlock achievements',
                  true,
                  (value) {},
                ),
                _buildSwitchTile(
                  'Learning Updates',
                  'Get notified about new lessons and content',
                  true,
                  (value) {},
                ),
              ],
            ),

            const SizedBox(height: 20),

            // App Preferences Section
            _buildSectionCard(
              'App Preferences',
              Icons.settings,
              const Color(0xFF4CAF50),
              [
                _buildSwitchTile(
                  'Sound Effects',
                  'Play sounds for actions',
                  soundEnabled,
                  (value) => setState(() => soundEnabled = value),
                ),
                _buildSwitchTile(
                  'Dark Mode',
                  'Use dark theme throughout the app',
                  darkModeEnabled,
                  (value) => setState(() => darkModeEnabled = value),
                ),
                _buildSwitchTile(
                  'Auto Sync',
                  'Automatically sync your progress',
                  autoSyncEnabled,
                  (value) => setState(() => autoSyncEnabled = value),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Account Section
            _buildSectionCard(
              'Account',
              Icons.person,
              const Color(0xFFFF9800),
              [
                _buildListTile(
                  'Profile Information',
                  'Manage your personal details',
                  Icons.edit,
                  () => _editProfile(),
                ),
                _buildListTile(
                  'Sign Out',
                  'Sign out of your account',
                  Icons.logout,
                  () => _signOut(),
                  isDestructive: true,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Support Section
            _buildSectionCard('Support', Icons.help, const Color(0xFFE91E63), [
              _buildListTile(
                'Help Center',
                'Get help and support',
                Icons.help_center,
                () => _openHelpCenter(),
              ),
              _buildListTile(
                'Contact Us',
                'Send us feedback or report issues',
                Icons.contact_support,
                () => _contactSupport(),
              ),
              _buildListTile(
                'Rate App',
                'Rate us on the App Store',
                Icons.star,
                () => _rateApp(),
              ),
              _buildListTile(
                'App Version',
                'Version 2.0.0',
                Icons.info,
                () => _showVersionInfo(),
              ),
            ]),

            const SizedBox(height: 20),

            // Legal Section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Legal',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () => _showPrivacyPolicy(),
                          child: const Text('Privacy Policy'),
                        ),
                        TextButton(
                          onPressed: () => _showTermsOfService(),
                          child: const Text('Terms of Service'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '© 2024 Learn & Grow. All rights reserved.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    String title,
    IconData icon,
    Color color,
    List<Widget> children,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildListTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : Colors.grey[600]),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  void _saveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings saved successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _editProfile() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Edit profile coming soon!')));
  }

  void _signOut() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Signed out successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _openHelpCenter() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Opening help center...')));
  }

  void _contactSupport() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Opening contact support...')));
  }

  void _rateApp() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Opening app store...')));
  }

  void _showVersionInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('App Version'),
        content: const Text('Learn & Grow v2.0.0\n\nBuild: 2.0.0+3'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Opening privacy policy...')));
  }

  void _showTermsOfService() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening terms of service...')),
    );
  }
}
