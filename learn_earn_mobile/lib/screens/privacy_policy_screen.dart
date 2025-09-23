import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Privacy Policy',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Last updated: ${DateTime.now().toString().split(' ')[0]}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),

            _buildSection('1. Information We Collect', [
              'We collect information you provide directly to us, such as when you create an account, complete lessons, or contact us for support.',
              'We automatically collect certain information about your device and usage of our app, including:',
              '• Device information (device type, operating system, unique device identifiers)',
              '• Usage data (app interactions, lesson progress, quiz results)',
              '• Advertising data (ad interactions, ad identifiers)',
              '• Location data (if you grant permission)',
            ]),

            _buildSection('2. How We Use Your Information', [
              'We use the information we collect to:',
              '• Provide and improve our educational services',
              '• Personalize your learning experience',
              '• Process coin rewards and payouts',
              '• Display relevant advertisements',
              '• Analyze app usage and performance',
              '• Communicate with you about updates and features',
              '• Ensure app security and prevent fraud',
            ]),

            _buildSection('3. Advertising and Data Collection', [
              'Our app displays advertisements through Google AdMob. AdMob may collect and use data for advertising purposes, including:',
              '• Ad personalization and targeting',
              '• Ad performance measurement',
              '• Fraud prevention and security',
              '• Analytics and reporting',
              '',
              'You can opt out of personalized advertising in your device settings.',
              'We do not sell your personal information to third parties.',
            ]),

            _buildSection('4. Data Sharing', [
              'We may share your information with:',
              '• Service providers who assist us in operating our app',
              '• Advertising partners (Google AdMob) for ad delivery',
              '• Legal authorities when required by law',
              '• Business partners in case of merger or acquisition',
              '',
              'We do not share your personal information with third parties for their own marketing purposes.',
            ]),

            _buildSection('5. Data Security', [
              'We implement appropriate security measures to protect your information:',
              '• Encryption of sensitive data',
              '• Secure data transmission',
              '• Regular security audits',
              '• Access controls and monitoring',
              '',
              'However, no method of transmission over the internet is 100% secure.',
            ]),

            _buildSection('6. Your Rights', [
              'You have the right to:',
              '• Access your personal information',
              '• Correct inaccurate information',
              '• Delete your account and data',
              '• Opt out of certain data collection',
              '• Withdraw consent for data processing',
              '',
              'To exercise these rights, contact us at privacy@learnandearn.com',
            ]),

            _buildSection('7. Children\'s Privacy', [
              'Our app is not intended for children under 13. We do not knowingly collect personal information from children under 13.',
              'If you are a parent and believe your child has provided us with personal information, please contact us.',
            ]),

            _buildSection('8. Changes to This Policy', [
              'We may update this Privacy Policy from time to time. We will notify you of any changes by:',
              '• Posting the new Privacy Policy in the app',
              '• Sending you an email notification',
              '• Updating the "Last updated" date',
              '',
              'Your continued use of the app after changes constitutes acceptance of the new policy.',
            ]),

            _buildSection('9. Contact Us', [
              'If you have any questions about this Privacy Policy, please contact us:',
              '',
              'Email: privacy@learnandearn.com',
              'Address: Learn & Earn App Support',
              'Phone: +1 (555) 123-4567',
              '',
              'We will respond to your inquiry within 30 days.',
            ]),

            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: const Text(
                'By using our app, you acknowledge that you have read and understood this Privacy Policy and agree to the collection, use, and disclosure of your information as described herein.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF333333),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<String> content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2196F3),
          ),
        ),
        const SizedBox(height: 8),
        ...content.map(
          (text) => Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF333333),
                height: 1.4,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
