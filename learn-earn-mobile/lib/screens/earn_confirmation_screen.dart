import 'package:flutter/material.dart';
import '../models/earning.dart';

class EarnConfirmationScreen extends StatelessWidget {
  final EarningSource source;
  final int coins;
  final String? lessonTitle;

  const EarnConfirmationScreen({
    super.key,
    required this.source,
    required this.coins,
    this.lessonTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Earned!'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Success animation/icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                size: 60,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 32),

            // Title
            Text(
              'Congratulations!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Description
            Text(
              _getDescription(),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Coins earned
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.monetization_on,
                    size: 40,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Coins Earned',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '+$coins',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Action buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _goToWallet(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('View Wallet'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _continueLearning(context),
                child: const Text('Continue Learning'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDescription() {
    switch (source) {
      case EarningSource.lesson:
        return 'You completed the lesson${lessonTitle != null ? ' "$lessonTitle"' : ''} and earned coins!';
      case EarningSource.quiz:
        return 'You passed the quiz${lessonTitle != null ? ' for "$lessonTitle"' : ''} and earned coins!';
      case EarningSource.streak:
        return 'You maintained your learning streak and earned bonus coins!';
      case EarningSource.dailyBonus:
        return 'You claimed your daily bonus and earned extra coins!';
      case EarningSource.adReward:
        return 'You watched an ad and earned coins!';
    }
  }

  void _goToWallet(BuildContext context) {
    // Navigate to wallet tab (index 2)
    Navigator.of(context).popUntil((route) => route.isFirst);
    // This would need to be implemented with a proper navigation system
  }

  void _continueLearning(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
