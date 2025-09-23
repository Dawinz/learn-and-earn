import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../constants/app_constants.dart';
import '../services/ad_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  String _selectedPeriod = 'All Time';
  final List<String> _periods = [
    'Today',
    'This Week',
    'This Month',
    'All Time',
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Leaderboard'),
            backgroundColor: const Color(0xFF2196F3),
            foregroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  // Refresh leaderboard data
                  setState(() {});
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // Top Banner Ad
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8.0),
                color: Colors.grey[100],
                child: AdService.getBannerAd(),
              ),

              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Header Section
                      Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF2196F3), Color(0xFF21CBF3)],
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.emoji_events,
                                size: 60,
                                color: Colors.amber,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Top Learners',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Compete with other learners and climb the ranks!',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),

                              // Period Selector
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: _periods.map((period) {
                                    final isSelected =
                                        period == _selectedPeriod;
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedPeriod = period;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          period,
                                          style: TextStyle(
                                            color: isSelected
                                                ? const Color(0xFF2196F3)
                                                : Colors.white,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Current User Rank Card
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Your Rank',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '#${_getUserRank(appProvider.coins)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${appProvider.coins} coins (${AppConstants.formatCashShort(AppConstants.coinsToCash(appProvider.coins))})',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
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
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'YOU',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Leaderboard List
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Top Performers',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ..._buildLeaderboardList(appProvider.coins),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Bottom Banner Ad
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8.0),
                        color: Colors.grey[100],
                        child: AdService.getBannerAd(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildLeaderboardList(int userCoins) {
    // Mock leaderboard data - in real app, this would come from backend
    final leaderboardData = _getMockLeaderboardData();

    return leaderboardData.asMap().entries.map((entry) {
      final index = entry.key;
      final user = entry.value;
      final isCurrentUser = user['coins'] == userCoins;

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Card(
          elevation: isCurrentUser ? 8 : 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isCurrentUser
                ? const BorderSide(color: Color(0xFF4CAF50), width: 2)
                : BorderSide.none,
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: isCurrentUser
                  ? const LinearGradient(
                      colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
                    )
                  : null,
            ),
            child: Row(
              children: [
                // Rank Badge
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getRankColor(index + 1).withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _getRankColor(index + 1),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: _getRankColor(index + 1),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            user['name'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isCurrentUser ? Colors.white : null,
                            ),
                          ),
                          if (isCurrentUser) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'YOU',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${user['coins']} coins (${AppConstants.formatCashShort(AppConstants.coinsToCash(user['coins']))})',
                        style: TextStyle(
                          fontSize: 14,
                          color: isCurrentUser
                              ? Colors.white70
                              : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${user['lessons']} lessons completed',
                        style: TextStyle(
                          fontSize: 12,
                          color: isCurrentUser
                              ? Colors.white60
                              : Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),

                // Trophy Icon
                if (index < 3)
                  Icon(
                    Icons.emoji_events,
                    color: _getRankColor(index + 1),
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  List<Map<String, dynamic>> _getMockLeaderboardData() {
    // Mock data - in real app, this would come from backend API
    return [
      {'name': 'Alex Johnson', 'coins': 15420, 'lessons': 28},
      {'name': 'Sarah Chen', 'coins': 12850, 'lessons': 24},
      {'name': 'Mike Rodriguez', 'coins': 11200, 'lessons': 22},
      {'name': 'Emma Wilson', 'coins': 9850, 'lessons': 20},
      {'name': 'David Kim', 'coins': 8750, 'lessons': 18},
      {'name': 'Lisa Brown', 'coins': 7200, 'lessons': 16},
      {'name': 'James Taylor', 'coins': 6800, 'lessons': 15},
      {'name': 'Anna Garcia', 'coins': 5900, 'lessons': 14},
      {'name': 'Tom Anderson', 'coins': 5200, 'lessons': 13},
      {'name': 'Maria Lopez', 'coins': 4800, 'lessons': 12},
    ];
  }

  int _getUserRank(int userCoins) {
    final leaderboardData = _getMockLeaderboardData();
    for (int i = 0; i < leaderboardData.length; i++) {
      if (userCoins >= leaderboardData[i]['coins']) {
        return i + 1;
      }
    }
    return leaderboardData.length + 1;
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey[400]!;
      case 3:
        return Colors.orange[300]!;
      default:
        return Colors.blue;
    }
  }
}
