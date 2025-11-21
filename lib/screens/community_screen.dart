import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/app_strings.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Icon(
              Icons.people,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.joinCommunity,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Description
            Text(
              AppStrings.communityDescription,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),

            // Benefits
            Text(
              'Community Benefits:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _buildBenefit(Icons.chat, 'Connect with fellow learners'),
            _buildBenefit(Icons.tips_and_updates, 'Share learning tips and strategies'),
            _buildBenefit(Icons.event, 'Get notified about community events'),
            _buildBenefit(Icons.help, 'Get help and support from the community'),
            _buildBenefit(Icons.emoji_events, 'Participate in challenges and tournaments'),
            const SizedBox(height: 24),

            // Join buttons
            ElevatedButton.icon(
              onPressed: () => _launchURL('https://chat.whatsapp.com/your-group-link'),
              icon: const Icon(Icons.chat_bubble),
              label: const Text('Join WhatsApp Community'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: const Color(0xFF25D366),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _launchURL('https://discord.gg/your-server'),
              icon: const Icon(Icons.discord),
              label: const Text('Join Discord Server'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 24),

            // Disclaimer
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: Colors.amber, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Community groups are managed externally and independently from this app. Event prizes and rewards are managed by community organizers.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefit(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }
}
