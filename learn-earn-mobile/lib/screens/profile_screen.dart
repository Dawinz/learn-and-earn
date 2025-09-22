import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/earning.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile header
                _buildProfileHeader(context, appProvider),
                const SizedBox(height: 24),

                // Stats
                _buildStats(context, appProvider),
                const SizedBox(height: 24),

                // Settings
                _buildSettings(context, appProvider),
                const SizedBox(height: 24),

                // About
                _buildAbout(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, AppProvider appProvider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 16),

            // Device ID
            Text(
              'Device ID',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              appProvider.user?.deviceId.substring(0, 8) ?? 'Unknown',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 16),

            // Status indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatusChip(
                  context,
                  'Mobile Number',
                  appProvider.hasMobileNumber ? 'Set' : 'Not Set',
                  appProvider.hasMobileNumber ? Colors.green : Colors.orange,
                ),
                _buildStatusChip(
                  context,
                  'Device Type',
                  appProvider.isEmulator ? 'Emulator' : 'Physical',
                  appProvider.isEmulator ? Colors.orange : Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: color.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(BuildContext context, AppProvider appProvider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Stats',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Total Coins',
                    '${appProvider.totalCoins}',
                    Icons.monetization_on,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Total USD',
                    '\$${appProvider.totalUsd.toStringAsFixed(2)}',
                    Icons.attach_money,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Today\'s Coins',
                    '${appProvider.todayCoins}',
                    Icons.today,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Lessons Completed',
                    '${appProvider.earnings.where((e) => e.source == EarningSource.lesson).length}',
                    Icons.school,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSettings(BuildContext context, AppProvider appProvider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _buildSettingItem(
            context,
            'Set Mobile Number',
            'Required for payouts',
            Icons.phone,
            appProvider.hasMobileNumber ? Colors.green : Colors.orange,
            () => _setMobileNumber(context),
          ),
          _buildSettingItem(
            context,
            'Language',
            'English',
            Icons.language,
            Colors.blue,
            () => _changeLanguage(context),
          ),
          _buildSettingItem(
            context,
            'Notifications',
            'Enabled',
            Icons.notifications,
            Colors.blue,
            () => _manageNotifications(context),
          ),
          _buildSettingItem(
            context,
            'Privacy',
            'View privacy policy',
            Icons.privacy_tip,
            Colors.blue,
            () => _viewPrivacy(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
      ),
      onTap: onTap,
    );
  }

  Widget _buildAbout(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildAboutItem(context, 'Version', '1.0.0'),
            _buildAboutItem(
              context,
              'Help & Support',
              'Get help and contact support',
              () => _showHelp(context),
            ),
            _buildAboutItem(
              context,
              'Terms of Service',
              'View terms and conditions',
              () => _showTerms(context),
            ),
            _buildAboutItem(
              context,
              'Reset App',
              'Clear all data and start over',
              () => _resetApp(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutItem(
    BuildContext context,
    String title,
    String subtitle, [
    VoidCallback? onTap,
    bool isDestructive = false,
  ]) {
    return ListTile(
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: isDestructive ? Theme.of(context).colorScheme.error : null,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        ),
      ),
      trailing: onTap != null
          ? Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            )
          : null,
      onTap: onTap,
    );
  }

  void _setMobileNumber(BuildContext context) {
    // TODO: Implement mobile number setting
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mobile number setting coming soon!')),
    );
  }

  void _changeLanguage(BuildContext context) {
    // TODO: Implement language change
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Language selection coming soon!')),
    );
  }

  void _manageNotifications(BuildContext context) {
    // TODO: Implement notification management
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification settings coming soon!')),
    );
  }

  void _viewPrivacy(BuildContext context) {
    // TODO: Implement privacy policy view
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Privacy policy coming soon!')),
    );
  }

  void _showHelp(BuildContext context) {
    // TODO: Implement help screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Help & support coming soon!')),
    );
  }

  void _showTerms(BuildContext context) {
    // TODO: Implement terms view
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Terms of service coming soon!')),
    );
  }

  void _resetApp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset App'),
        content: const Text(
          'This will clear all your data and you\'ll need to start over. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AppProvider>().reset();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
