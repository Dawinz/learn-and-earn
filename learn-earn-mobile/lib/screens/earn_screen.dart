import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/earning.dart';

class EarnScreen extends StatelessWidget {
  const EarnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Earn'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Daily earnings summary
                _buildDailySummary(context, appProvider),
                const SizedBox(height: 24),

                // Earning opportunities
                _buildEarningOpportunities(context, appProvider),
                const SizedBox(height: 24),

                // Recent earnings
                _buildRecentEarnings(context, appProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDailySummary(BuildContext context, AppProvider appProvider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s Earnings',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Coins',
                    '${appProvider.todayCoins}',
                    Icons.monetization_on,
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'USD',
                    '\$${appProvider.totalUsd.toStringAsFixed(2)}',
                    Icons.attach_money,
                    Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningOpportunities(
    BuildContext context,
    AppProvider appProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Earning Opportunities',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildOpportunityCard(
          context,
          'Complete Lessons',
          'Learn new skills and earn coins',
          Icons.school,
          '10-15 coins per lesson',
          () => _navigateToLearn(context),
        ),
        const SizedBox(height: 12),
        _buildOpportunityCard(
          context,
          'Pass Quizzes',
          'Test your knowledge and earn rewards',
          Icons.quiz,
          '15-20 coins per quiz',
          () => _navigateToLearn(context),
        ),
        const SizedBox(height: 12),
        _buildOpportunityCard(
          context,
          'Watch Ads',
          'Earn coins by watching short ads',
          Icons.play_circle_outline,
          '5-10 coins per ad',
          () => _showAd(context),
        ),
        const SizedBox(height: 12),
        _buildOpportunityCard(
          context,
          'Daily Streak',
          'Maintain your learning streak',
          Icons.local_fire_department,
          '5 coins per day',
          () => _claimStreak(context, appProvider),
        ),
      ],
    );
  }

  Widget _buildOpportunityCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    String reward,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    reward,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.3),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentEarnings(BuildContext context, AppProvider appProvider) {
    final recentEarnings = appProvider.earnings.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Earnings',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (recentEarnings.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.trending_up_outlined,
                    size: 48,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No earnings yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start learning to earn your first coins!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.5),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          ...recentEarnings.map(
            (earning) => _buildEarningItem(context, earning),
          ),
      ],
    );
  }

  Widget _buildEarningItem(BuildContext context, Earning earning) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getEarningIcon(earning.source),
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
        ),
        title: Text(
          _getEarningTitle(earning.source),
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          _formatDate(earning.createdAt),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        trailing: Text(
          '+${earning.coins}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  IconData _getEarningIcon(EarningSource source) {
    switch (source) {
      case EarningSource.lesson:
        return Icons.school;
      case EarningSource.quiz:
        return Icons.quiz;
      case EarningSource.streak:
        return Icons.local_fire_department;
      case EarningSource.dailyBonus:
        return Icons.card_giftcard;
      case EarningSource.adReward:
        return Icons.play_circle_outline;
    }
  }

  String _getEarningTitle(EarningSource source) {
    switch (source) {
      case EarningSource.lesson:
        return 'Lesson Completed';
      case EarningSource.quiz:
        return 'Quiz Passed';
      case EarningSource.streak:
        return 'Streak Bonus';
      case EarningSource.dailyBonus:
        return 'Daily Bonus';
      case EarningSource.adReward:
        return 'Ad Reward';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  void _navigateToLearn(BuildContext context) {
    // Navigate to learn tab (index 0)
    // This would need to be implemented with a proper navigation system
  }

  void _showAd(BuildContext context) {
    // TODO: Implement AdMob integration
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ad integration coming soon!')),
    );
  }

  void _claimStreak(BuildContext context, AppProvider appProvider) {
    // TODO: Implement streak claiming
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Streak feature coming soon!')),
    );
  }
}
