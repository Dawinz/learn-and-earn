import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../constants/app_constants.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final completedLessons = appProvider.lessons.where((l) => l.isCompleted).length;
        final totalLessons = appProvider.lessons.length;
        final progressPercent = totalLessons > 0 ? (completedLessons / totalLessons) : 0.0;
        final level = AppConstants.calculateLevel(appProvider.xp);
        final levelTitle = AppConstants.getLevelTitle(level);

        return Scaffold(
          appBar: AppBar(
            title: const Text('My Progress'),
            backgroundColor: const Color(0xFFFF9800),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Header with Level Info
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
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.stars,
                          size: 60,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          levelTitle,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Level $level',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.stars, color: Colors.white, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                '${appProvider.xp} XP',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Stats Cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Learning Statistics',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Lessons Progress Card
                      _buildStatCard(
                        icon: Icons.book,
                        color: Colors.blue,
                        title: 'Lessons Completed',
                        value: '$completedLessons / $totalLessons',
                        progress: progressPercent,
                      ),

                      const SizedBox(height: 16),

                      // Learning Streak Card
                      _buildStreakCard(appProvider),

                      const SizedBox(height: 16),

                      // XP Breakdown
                      _buildXpBreakdown(appProvider),

                      const SizedBox(height: 16),

                      // Achievements Preview
                      _buildAchievementsPreview(context, appProvider),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
    double? progress,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF666666),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (progress != null) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${(progress * 100).toStringAsFixed(0)}% Complete',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCard(AppProvider appProvider) {
    final streak = appProvider.learningStreak;
    final streakText = streak == 0 ? 'Start today!' : '$streak ${streak == 1 ? 'day' : 'days'}';

    String message;
    IconData icon;
    Color color;

    if (streak == 0) {
      message = 'Complete a lesson to start your streak!';
      icon = Icons.local_fire_department_outlined;
      color = Colors.grey;
    } else if (streak >= 30) {
      message = 'Legendary! You\'re unstoppable! 🔥';
      icon = Icons.local_fire_department;
      color = Colors.red;
    } else if (streak >= 14) {
      message = 'Amazing! Keep the momentum going!';
      icon = Icons.local_fire_department;
      color = Colors.deepOrange;
    } else if (streak >= 7) {
      message = 'Excellent! One week strong!';
      icon = Icons.local_fire_department;
      color = Colors.orange;
    } else {
      message = 'Keep learning daily to build your streak!';
      icon = Icons.local_fire_department;
      color = Colors.orange;
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
              color.withValues(alpha: 0.1),
              color.withValues(alpha: 0.05),
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
                      color: color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 24),
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
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF666666),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          streakText,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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

  Widget _buildXpBreakdown(AppProvider appProvider) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                    color: Colors.purple.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.trending_up, color: Colors.purple, size: 24),
                ),
                const SizedBox(width: 16),
                const Text(
                  'XP Breakdown',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildXpItem(
              'Lessons Completed',
              '${appProvider.lessons.where((l) => l.isCompleted).length}',
              Icons.book,
              Colors.blue,
            ),
            const Divider(height: 24),
            _buildXpItem(
              'Daily Login Streaks',
              '${appProvider.learningStreak} days',
              Icons.calendar_today,
              Colors.green,
            ),
            const Divider(height: 24),
            _buildXpItem(
              'Total XP Earned',
              '${appProvider.xp} XP',
              Icons.stars,
              Colors.amber,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildXpItem(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementsPreview(BuildContext context, AppProvider appProvider) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/achievements');
        },
        borderRadius: BorderRadius.circular(16),
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
                      color: Colors.amber.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.emoji_events, color: Colors.amber, size: 24),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Achievements',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Unlock badges and achievements as you progress!',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildMiniAchievement(Icons.school, Colors.blue, appProvider.xp >= 1000),
                  const SizedBox(width: 12),
                  _buildMiniAchievement(Icons.star, Colors.amber, appProvider.xp >= 5000),
                  const SizedBox(width: 12),
                  _buildMiniAchievement(Icons.emoji_events, Colors.purple, appProvider.xp >= 10000),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniAchievement(IconData icon, Color color, bool unlocked) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: unlocked ? color.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: unlocked ? color : Colors.grey,
          width: 2,
        ),
      ),
      child: Icon(
        icon,
        color: unlocked ? color : Colors.grey,
        size: 24,
      ),
    );
  }
}
