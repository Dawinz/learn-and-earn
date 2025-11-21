import 'package:flutter/material.dart';
import '../utils/app_strings.dart';

class RewardsPolicyScreen extends StatelessWidget {
  const RewardsPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rewards Policy'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Icon(
              Icons.policy,
              size: 80,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            Text(
              'Rewards & XP Policy',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Main policy
            Text(
              AppStrings.rewardsPolicyDescription,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),

            // What is XP
            _buildSection(
              context,
              'What is XP?',
              'XP (Experience Points) is a virtual progress tracking system used within Learn & Grow to gamify your learning experience. XP helps you:',
              [
                'Track your learning progress',
                'Compete on leaderboards',
                'Unlock achievements and badges',
                'Monitor your growth over time',
              ],
            ),

            // What XP is NOT
            _buildSection(
              context,
              'What XP is NOT',
              'It\'s important to understand that XP:',
              [
                'Is NOT redeemable for cash or money',
                'Has NO monetary value',
                'Cannot be withdrawn or cashed out',
                'Cannot be transferred or sold',
                'Is NOT a form of currency or payment',
              ],
              isWarning: true,
            ),

            // In-App Payments
            _buildSection(
              context,
              'In-App Payments',
              'Learn & Grow:',
              [
                'Does NOT process any payments',
                'Does NOT collect financial information',
                'Does NOT offer in-app purchases',
                'Does NOT facilitate money transfers',
                'Is a FREE educational platform',
              ],
            ),

            // External Events
            _buildSection(
              context,
              'Community Events & Prizes',
              'Our learning community may organize optional external events:',
              [
                'Events are managed by community organizers',
                'Prizes (if any) are distributed externally',
                'Learn & Grow is NOT responsible for event prizes',
                'Participation is completely optional',
                'Event terms are set by organizers, not this app',
              ],
            ),

            // Data & Privacy
            _buildSection(
              context,
              'Your Data',
              'We collect:',
              [
                'Learning progress and XP',
                'Achievement unlocks',
                'Account information (email, profile)',
                'Usage analytics',
              ],
            ),

            Text(
              'We do NOT collect:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
            ),
            const SizedBox(height: 8),
            ...['Payment information', 'Bank details', 'Credit card numbers', 'Financial data']
                .map((item) => _buildListItem(item, Colors.red))
                .toList(),
            const SizedBox(height: 24),

            // Contact
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.contact_support, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        'Questions?',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'If you have questions about this policy or how XP works, please contact us through the Help & Support section.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Last updated
            Center(
              child: Text(
                'Last Updated: October 2025',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    String description,
    List<String> items, {
    bool isWarning = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isWarning ? Colors.orange.shade900 : null,
              ),
        ),
        const SizedBox(height: 8),
        Text(description),
        const SizedBox(height: 8),
        ...items.map((item) => _buildListItem(item, isWarning ? Colors.orange : Colors.green)).toList(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildListItem(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.circle, size: 8, color: color),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
