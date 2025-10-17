import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/ad_service.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/rewarded_ad_button.dart';

class EarnScreen extends StatelessWidget {
  const EarnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Earn'),
            backgroundColor: const Color(0xFFFF9800),
            foregroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.leaderboard),
                onPressed: () => _showLeaderboard(context),
              ),
            ],
          ),
          body: Column(
            children: [
              // Top Banner Ad
              const BannerAdWidget(height: 60, margin: EdgeInsets.all(8.0)),

              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Daily Challenge Header
                      Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Daily Challenge',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Complete daily tasks to earn bonus coins!',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildDailyChallenge(
                                      'Watch 3 Ads',
                                      '3/3',
                                      Icons.play_circle,
                                      Colors.green,
                                      true,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildDailyChallenge(
                                      'Complete 2 Lessons',
                                      '1/2',
                                      Icons.book,
                                      Colors.blue,
                                      false,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Earning Methods
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Earning Methods',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF333333),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Quick Earning Actions
                            GridView.count(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              childAspectRatio: 1.2,
                              children: [
                                _buildRewardedAdOption(
                                  context,
                                  'Watch Ad',
                                  Icons.play_circle,
                                  Colors.orange,
                                  'Earn 15 coins',
                                ),
                                _buildCompleteQuizOption(
                                  context,
                                  appProvider,
                                ),
                                _buildDailyLoginOption(
                                  context,
                                  appProvider,
                                ),
                                _buildEarnOption(
                                  context,
                                  'Refer Friend',
                                  Icons.share,
                                  Colors.green,
                                  'Earn 50 coins',
                                  () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Referral feature coming soon!',
                                        ),
                                        backgroundColor: Colors.blue,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Streak Section
                            _buildLearningStreak(appProvider),

                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Banner Ad
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8.0),
                color: Colors.grey[100],
                child: AdService.getBannerAd(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDailyChallenge(
    String title,
    String progress,
    IconData icon,
    Color color,
    bool isCompleted,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted ? Colors.green : Colors.white.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: isCompleted ? Colors.green : Colors.white,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            progress,
            style: TextStyle(
              color: isCompleted ? Colors.green : Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarnOption(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 32, color: color),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompleteQuizOption(
    BuildContext context,
    AppProvider appProvider,
  ) {
    final color = Colors.purple;
    // Get lessons that have quizzes and haven't been completed yet
    final availableLessons = appProvider.lessons.where((lesson) =>
      lesson.quiz.isNotEmpty && !lesson.isCompleted
    ).toList();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          if (availableLessons.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'No quizzes available! Complete some lessons first.',
                ),
                backgroundColor: Colors.orange,
              ),
            );
            return;
          }

          // Show dialog to select a lesson
          _showQuizSelectionDialog(context, availableLessons);
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.quiz, size: 32, color: color),
                ),
                const SizedBox(height: 12),
                Text(
                  'Complete Quiz',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  availableLessons.isEmpty
                    ? 'No quizzes available'
                    : 'Earn 20 coins',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                if (availableLessons.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${availableLessons.length} available',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showQuizSelectionDialog(BuildContext context, List lessons) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select a Lesson Quiz'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: lessons.length,
            itemBuilder: (context, index) {
              final lesson = lessons[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.purple.withOpacity(0.2),
                  child: const Icon(Icons.quiz, color: Colors.purple),
                ),
                title: Text(
                  lesson.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  '${lesson.quiz.length} questions • ${lesson.coinReward} coins',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to lesson detail screen
                  Navigator.pushNamed(
                    context,
                    '/lesson-detail',
                    arguments: lesson,
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyLoginOption(
    BuildContext context,
    AppProvider appProvider,
  ) {
    final canClaim = appProvider.canClaimDailyLogin;
    final color = Colors.blue;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: canClaim
            ? () async {
                // Show confirmation dialog with rewarded ad
                final result = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Daily Login Bonus'),
                    content: const Text(
                      'Watch a short ad to claim your daily login bonus of 5 coins!',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Watch Ad'),
                      ),
                    ],
                  ),
                );

                if (result == true && context.mounted) {
                  // Show loading indicator
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );

                  // Claim daily login (will show rewarded ad)
                  final claimResult = await appProvider.claimDailyLogin();

                  if (context.mounted) {
                    // Close loading indicator
                    Navigator.pop(context);

                    // Show result
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(claimResult['message'] ?? 'Unknown error'),
                        backgroundColor: claimResult['success'] == true
                            ? Colors.green
                            : Colors.orange,
                      ),
                    );
                  }
                }
              }
            : () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Daily login already claimed! Come back tomorrow.',
                    ),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: canClaim
                  ? [color.withOpacity(0.1), color.withOpacity(0.05)]
                  : [Colors.grey.withOpacity(0.1), Colors.grey.withOpacity(0.05)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: canClaim
                        ? color.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.calendar_today,
                    size: 32,
                    color: canClaim ? color : Colors.grey,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Daily Login',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: canClaim ? color : Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  canClaim ? 'Earn 5 coins' : 'Come back tomorrow',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                if (!canClaim)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Claimed',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRewardedAdOption(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                // Show rewarded ad dialog
                _showRewardedAdDialog(context, appProvider);
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 32, color: color),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showRewardedAdDialog(BuildContext context, AppProvider appProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Watch Ad to Earn'),
        content: const Text('Watch a short ad to earn 15 coins!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          RewardedAdButton(
            text: 'Watch Ad',
            onRewardEarned: () {
              Navigator.pop(context);
              // Add coins to user's balance (15 coins for rewarded video as per README)
              appProvider.addCoins(15, 'Ad Watched');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ad watched! +15 coins'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            onAdFailed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ad not available. Please try again later.'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showLeaderboard(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leaderboard'),
        content: const Text('Leaderboard feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildLearningStreak(AppProvider appProvider) {
    final streak = appProvider.learningStreak;
    final streakText = streak == 0
        ? 'Start today!'
        : '$streak ${streak == 1 ? 'day' : 'days'}';

    // Calculate progress for weekly streak (0-7 days = 0-1.0 progress)
    final progress = streak == 0 ? 0.0 : (streak % 7) / 7.0;

    // Determine message based on streak length
    String message;
    if (streak == 0) {
      message = 'Complete a lesson to start your streak!';
    } else if (streak >= 30) {
      message = 'Legendary! You\'re unstoppable! 🔥';
    } else if (streak >= 14) {
      message = 'Amazing! Keep the momentum going!';
    } else if (streak >= 7) {
      message = 'Excellent! One week strong!';
    } else {
      message = 'Keep learning daily to build your streak!';
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.orange.withOpacity(0.1),
              Colors.orange.withOpacity(0.05),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.local_fire_department,
                      color: Colors.orange,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Learning Streak',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          streakText,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
