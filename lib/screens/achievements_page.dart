import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final completedLessons = appProvider.lessons
            .where((l) => l.isCompleted)
            .length;
        final quizCompletions = appProvider.transactions
            .where((t) => t.title.contains('Quiz'))
            .length;
        final adViews = appProvider.transactions
            .where((t) => t.title.contains('Ad'))
            .length;
        final totalEarned = appProvider.transactions
            .where((t) => t.type == 'earned')
            .fold(0, (sum, t) => sum + t.amount);

        final achievements = [
          {
            'title': 'First Steps',
            'description': 'Complete your first lesson',
            'icon': Icons.school,
            'color': Colors.green,
            'unlocked': completedLessons >= 1,
            'progress': completedLessons,
            'target': 1,
            'reward': '10 xp',
          },
          {
            'title': 'Quiz Master',
            'description': 'Complete 5 quizzes',
            'icon': Icons.quiz,
            'color': Colors.purple,
            'unlocked': quizCompletions >= 5,
            'progress': quizCompletions,
            'target': 5,
            'reward': '50 xp',
          },
          {
            'title': 'Ad Watcher',
            'description': 'Watch 10 ads',
            'icon': Icons.play_circle,
            'color': Colors.blue,
            'unlocked': adViews >= 10,
            'progress': adViews,
            'target': 10,
            'reward': '25 xp',
          },
          {
            'title': 'Coin Collector',
            'description': 'Earn 1000 xp',
            'icon': Icons.monetization_on,
            'color': Colors.amber,
            'unlocked': totalEarned >= 1000,
            'progress': totalEarned,
            'target': 1000,
            'reward': '100 xp',
          },
          {
            'title': 'Learning Streak',
            'description': 'Learn for 7 days in a row',
            'icon': Icons.local_fire_department,
            'color': Colors.red,
            'unlocked': false, // This would need actual streak tracking
            'progress': 3,
            'target': 7,
            'reward': '200 xp',
          },
          {
            'title': 'Lesson Expert',
            'description': 'Complete 10 lessons',
            'icon': Icons.star,
            'color': Colors.orange,
            'unlocked': completedLessons >= 10,
            'progress': completedLessons,
            'target': 10,
            'reward': '150 xp',
          },
          {
            'title': 'Quiz Champion',
            'description': 'Complete 20 quizzes',
            'icon': Icons.emoji_events,
            'color': Colors.indigo,
            'unlocked': quizCompletions >= 20,
            'progress': quizCompletions,
            'target': 20,
            'reward': '300 xp',
          },
          {
            'title': 'Ad Enthusiast',
            'description': 'Watch 50 ads',
            'icon': Icons.video_library,
            'color': Colors.teal,
            'unlocked': adViews >= 50,
            'progress': adViews,
            'target': 50,
            'reward': '100 xp',
          },
        ];

        final unlockedCount = achievements
            .where((a) => a['unlocked'] as bool)
            .length;
        final totalCount = achievements.length;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Achievements'),
            backgroundColor: const Color(0xFF9C27B0),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress Header
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF9C27B0), Color(0xFFBA68C8)],
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.emoji_events,
                          size: 60,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Achievement Progress',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$unlockedCount of $totalCount achievements unlocked',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 16),
                        LinearProgressIndicator(
                          value: unlockedCount / totalCount,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                          minHeight: 8,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${((unlockedCount / totalCount) * 100).toInt()}% Complete',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Achievements List
                const Text(
                  'All Achievements',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 16),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: achievements.length,
                  itemBuilder: (context, index) {
                    final achievement = achievements[index];
                    final isUnlocked = achievement['unlocked'] as bool;
                    final progress = achievement['progress'] as int;
                    final target = achievement['target'] as int;
                    final progressPercent = (progress / target).clamp(0.0, 1.0);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: isUnlocked ? 4 : 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: isUnlocked
                              ? LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    (achievement['color'] as Color).withOpacity(
                                      0.1,
                                    ),
                                    (achievement['color'] as Color).withOpacity(
                                      0.05,
                                    ),
                                  ],
                                )
                              : null,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              // Achievement Icon
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isUnlocked
                                      ? (achievement['color'] as Color)
                                            .withOpacity(0.2)
                                      : Colors.grey.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  achievement['icon'] as IconData,
                                  color: isUnlocked
                                      ? achievement['color'] as Color
                                      : Colors.grey,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Achievement Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            achievement['title'] as String,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: isUnlocked
                                                  ? Colors.black
                                                  : Colors.grey,
                                            ),
                                          ),
                                        ),
                                        if (isUnlocked)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.green,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: const Text(
                                              'UNLOCKED',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      achievement['description'] as String,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isUnlocked
                                            ? Colors.grey[600]
                                            : Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    // Progress Bar
                                    LinearProgressIndicator(
                                      value: progressPercent,
                                      backgroundColor: Colors.grey[300],
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        isUnlocked
                                            ? achievement['color'] as Color
                                            : Colors.grey,
                                      ),
                                      minHeight: 6,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$progress / $target (${(progressPercent * 100).toInt()}%)',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    // Reward
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.monetization_on,
                                          size: 16,
                                          color: Colors.amber[700],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Reward: ${achievement['reward']}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.amber[700],
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Tips Section
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.lightbulb,
                              color: Colors.orange,
                              size: 24,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Achievement Tips',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF333333),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '• Complete lessons daily to maintain your learning streak\n'
                          '• Take quizzes regularly to improve your knowledge\n'
                          '• Watch ads to earn extra xp and unlock achievements\n'
                          '• Check back daily for new earning opportunities',
                          style: TextStyle(fontSize: 14, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
