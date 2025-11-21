import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final completedLessons = appProvider.lessons
            .where((l) => l.isCompleted)
            .length;
        final totalLessons = appProvider.lessons.length;
        final earnedTransactions = appProvider.transactions
            .where((t) => t.type == 'earned')
            .length;
        final totalEarned = appProvider.transactions
            .where((t) => t.type == 'earned')
            .fold(0, (sum, t) => sum + t.amount);
        final quizCompletions = appProvider.transactions
            .where((t) => t.title.contains('Quiz'))
            .length;
        final adViews = appProvider.transactions
            .where((t) => t.title.contains('Ad'))
            .length;
        final spentTransactions = appProvider.transactions
            .where((t) => t.type == 'spent')
            .length;
        final totalSpent = appProvider.transactions
            .where((t) => t.type == 'spent')
            .fold(0, (sum, t) => sum + t.amount);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Learning Statistics'),
            backgroundColor: const Color(0xFF2196F3),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress Overview Card
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
                        const Text(
                          'Learning Progress',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$completedLessons of $totalLessons lessons completed',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 8),
                                  LinearProgressIndicator(
                                    value: totalLessons > 0
                                        ? completedLessons / totalLessons
                                        : 0.0,
                                    backgroundColor: Colors.grey[300],
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                          Color(0xFF4CAF50),
                                        ),
                                    minHeight: 8,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${totalLessons > 0 ? ((completedLessons / totalLessons) * 100).toInt() : 0}% Complete',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4CAF50).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.school,
                                color: Color(0xFF4CAF50),
                                size: 32,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Coins Overview
                const Text(
                  'Coins Overview',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Current Balance',
                        '${appProvider.coins}',
                        Icons.account_balance_wallet,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Total Earned',
                        '$totalEarned',
                        Icons.trending_up,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total Spent',
                        '$totalSpent',
                        Icons.trending_down,
                        Colors.red,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Net Profit',
                        '${totalEarned - totalSpent}',
                        Icons.analytics,
                        Colors.purple,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Activity Overview
                const Text(
                  'Activity Overview',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Quizzes Taken',
                        '$quizCompletions',
                        Icons.quiz,
                        Colors.purple,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Ads Watched',
                        '$adViews',
                        Icons.play_circle,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Transactions',
                        '${appProvider.transactions.length}',
                        Icons.history,
                        Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Earning Events',
                        '$earnedTransactions',
                        Icons.monetization_on,
                        Colors.amber,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Learning Streak
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
                        const Text(
                          'Learning Streak',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(
                              Icons.local_fire_department,
                              color: Colors.red,
                              size: 32,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '7 Days',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                  const Text(
                                    'Current streak',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Keep it up!',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Recent Activity
                const Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: appProvider.transactions.take(5).length,
                    itemBuilder: (context, index) {
                      final transaction = appProvider.transactions[index];
                      final isEarned = transaction.type == 'earned';
                      return ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isEarned
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            isEarned ? Icons.add_circle : Icons.remove_circle,
                            color: isEarned ? Colors.green : Colors.red,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          transaction.title,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(transaction.formattedTime),
                        trailing: Text(
                          '${isEarned ? '+' : ''}${transaction.amount}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isEarned ? Colors.green : Colors.red,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
