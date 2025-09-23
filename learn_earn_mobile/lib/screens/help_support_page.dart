import 'package:flutter/material.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search for help...',
                    prefixIcon: const Icon(Icons.search),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    // Implement search functionality
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Quick Help Section
            const Text(
              'Quick Help',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 16),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildQuickHelpItem(
                    'How do I earn coins?',
                    'Learn about different ways to earn coins',
                    Icons.monetization_on,
                    Colors.amber,
                    () => _showEarningHelp(context),
                  ),
                  const Divider(height: 1),
                  _buildQuickHelpItem(
                    'How do I request a payout?',
                    'Step-by-step guide to withdraw your earnings',
                    Icons.account_balance_wallet,
                    Colors.green,
                    () => _showPayoutHelp(context),
                  ),
                  const Divider(height: 1),
                  _buildQuickHelpItem(
                    'Why aren\'t ads showing?',
                    'Troubleshoot ad display issues',
                    Icons.play_circle,
                    Colors.blue,
                    () => _showAdHelp(context),
                  ),
                  const Divider(height: 1),
                  _buildQuickHelpItem(
                    'How do I sync my data?',
                    'Keep your progress saved across devices',
                    Icons.sync,
                    Colors.purple,
                    () => _showSyncHelp(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // FAQ Section
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 16),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildFAQItem(
                    'What is the minimum payout amount?',
                    'The minimum payout amount is 1000 coins. You can request a payout once you have earned at least this amount.',
                  ),
                  const Divider(height: 1),
                  _buildFAQItem(
                    'How long does it take to process payouts?',
                    'Payouts are typically processed within 24-48 hours. You will receive a notification once your payout is complete.',
                  ),
                  const Divider(height: 1),
                  _buildFAQItem(
                    'Can I use the app offline?',
                    'Yes! The app works offline and will sync your progress when you\'re back online. Your data is automatically saved locally.',
                  ),
                  const Divider(height: 1),
                  _buildFAQItem(
                    'How do I reset my progress?',
                    'To reset your progress, go to Settings > Account > Reset Progress. This action cannot be undone.',
                  ),
                  const Divider(height: 1),
                  _buildFAQItem(
                    'Is my data secure?',
                    'Yes, we take your privacy seriously. All data is encrypted and stored securely. We never share your personal information.',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Contact Support Section
            const Text(
              'Contact Support',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 16),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildContactItem(
                    'Email Support',
                    'Get help via email',
                    'support@learnearn.com',
                    Icons.email,
                    Colors.blue,
                    () => _openEmailSupport(context),
                  ),
                  const Divider(height: 1),
                  _buildContactItem(
                    'Live Chat',
                    'Chat with our support team',
                    'Available 24/7',
                    Icons.chat,
                    Colors.orange,
                    () => _openLiveChat(context),
                  ),
                  const Divider(height: 1),
                  _buildContactItem(
                    'Report a Bug',
                    'Help us improve the app',
                    'Report issues and bugs',
                    Icons.bug_report,
                    Colors.red,
                    () => _reportBug(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Community Section
            const Text(
              'Community',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 16),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildContactItem(
                    'User Forum',
                    'Connect with other learners',
                    'Share tips and experiences',
                    Icons.forum,
                    Colors.purple,
                    () => _openForum(context),
                  ),
                  const Divider(height: 1),
                  _buildContactItem(
                    'Social Media',
                    'Follow us for updates',
                    '@learnearn_official',
                    Icons.share,
                    Colors.indigo,
                    () => _openSocialMedia(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Feedback Section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Icon(
                      Icons.feedback,
                      size: 48,
                      color: Color(0xFF2196F3),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'We Value Your Feedback',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Help us improve Learn & Earn by sharing your thoughts and suggestions.',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _sendFeedback(context),
                      icon: const Icon(Icons.send),
                      label: const Text('Send Feedback'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        foregroundColor: Colors.white,
                      ),
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

  Widget _buildQuickHelpItem(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            answer,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
        ),
      ],
    );
  }

  Widget _buildContactItem(
    String title,
    String subtitle,
    String value,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subtitle),
          Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.w500),
          ),
        ],
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _showEarningHelp(BuildContext context) {
    _showHelpDialog(
      context,
      'How to Earn Coins',
      'You can earn coins in several ways:\n\n'
          '• Complete lessons: 50-150 coins per lesson\n'
          '• Take quizzes: 20-50 coins per quiz\n'
          '• Watch ads: 10-15 coins per ad\n'
          '• Daily login: 5 coins per day\n'
          '• Complete challenges: 25-100 coins per challenge\n\n'
          'The more you learn, the more you earn!',
    );
  }

  void _showPayoutHelp(BuildContext context) {
    _showHelpDialog(
      context,
      'How to Request a Payout',
      'To request a payout:\n\n'
          '1. Go to your Profile\n'
          '2. Tap on "Wallet"\n'
          '3. Enter your mobile money number\n'
          '4. Enter the amount you want to withdraw\n'
          '5. Confirm your request\n\n'
          'Minimum payout: 1000 coins\n'
          'Processing time: 24-48 hours',
    );
  }

  void _showAdHelp(BuildContext context) {
    _showHelpDialog(
      context,
      'Ad Display Issues',
      'If ads aren\'t showing:\n\n'
          '• Check your internet connection\n'
          '• Make sure you\'re not using an ad blocker\n'
          '• Try refreshing the app\n'
          '• Restart your device\n'
          '• Update the app to the latest version\n\n'
          'Ads may not be available in all regions.',
    );
  }

  void _showSyncHelp(BuildContext context) {
    _showHelpDialog(
      context,
      'Data Synchronization',
      'To sync your data:\n\n'
          '1. Go to your Profile\n'
          '2. Tap on "Data Sync"\n'
          '3. Tap "Sync Now"\n\n'
          'Your progress will be saved to the cloud and available on other devices. '
          'Auto-sync is enabled by default and runs every 30 minutes.',
    );
  }

  void _showHelpDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: Text(content)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _openEmailSupport(BuildContext context) {
    _showHelpDialog(
      context,
      'Email Support',
      'For support inquiries, please email us at:\n\nsupport@learnearn.com\n\nWe typically respond within 24 hours.',
    );
  }

  void _openLiveChat(BuildContext context) {
    _showHelpDialog(
      context,
      'Live Chat',
      'Live chat support is currently being set up. For immediate assistance, please use email support or check our FAQ section.',
    );
  }

  void _reportBug(BuildContext context) {
    _showHelpDialog(
      context,
      'Report a Bug',
      'To report a bug or issue:\n\n1. Go to your device settings\n2. Find "Learn & Earn" app\n3. Tap "Report a Problem"\n\nOr email us at: support@learnearn.com\n\nPlease include:\n• Device model\n• App version\n• Steps to reproduce the issue',
    );
  }

  void _openForum(BuildContext context) {
    _showHelpDialog(
      context,
      'User Forum',
      'Our community forum is coming soon! In the meantime, you can:\n\n• Check our FAQ section\n• Email us for support\n• Follow us on social media for updates',
    );
  }

  void _openSocialMedia(BuildContext context) {
    _showHelpDialog(
      context,
      'Social Media',
      'Follow us for updates and tips:\n\n• Twitter: @learnearn_official\n• Instagram: @learnearn_official\n• Facebook: Learn & Earn App\n\nWe share learning tips, app updates, and success stories!',
    );
  }

  void _sendFeedback(BuildContext context) {
    _showHelpDialog(
      context,
      'Send Feedback',
      'We\'d love to hear from you!\n\nTo send feedback:\n\n1. Email us at: feedback@learnearn.com\n2. Include your suggestions\n3. Tell us what you love about the app\n\nYour feedback helps us improve Learn & Earn for everyone!',
    );
  }
}
