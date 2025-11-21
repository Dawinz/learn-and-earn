import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/quiz.dart';
import '../services/ad_service.dart';
import 'quiz_detail_screen.dart';
import 'lesson_detail_screen.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Learn'),
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              elevation: 0,
              bottom: const TabBar(
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: [
                  Tab(icon: Icon(Icons.book), text: 'Lessons'),
                  Tab(icon: Icon(Icons.quiz), text: 'Quizzes'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                // Lessons Tab
                _buildLessonsTab(context, appProvider),
                // Quizzes Tab
                _buildQuizzesTab(context, appProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLessonsTab(BuildContext context, AppProvider appProvider) {
    final completedLessons = appProvider.lessons
        .where((l) => l.isCompleted)
        .length;
    final totalLessons = appProvider.lessons.length;
    final progress = totalLessons > 0 ? completedLessons / totalLessons : 0.0;

    return Column(
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
          // Progress Header
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Learning Progress',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$completedLessons of $totalLessons lessons completed',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.school,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                    minHeight: 8,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(progress * 100).toInt()}% Complete',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Daily Reset Info Banner
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Lessons reset daily! Complete them again to earn more XP.',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Lessons List
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Available Lessons',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: appProvider.lessons.length,
                  itemBuilder: (context, index) {
                    final lesson = appProvider.lessons[index];
                    return _buildLessonCard(context, lesson, appProvider);
                  },
                ),
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
    );
  }

  Widget _buildQuizzesTab(BuildContext context, AppProvider appProvider) {
    return Column(
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
          const Text(
            'Test Your Knowledge',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Complete quizzes to earn extra coins and test your understanding',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _getQuizzes().length,
              itemBuilder: (context, index) {
                final quiz = _getQuizzes()[index];
                return _buildQuizCard(context, quiz, appProvider);
              },
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
    );
  }

  Widget _buildLessonCard(
    BuildContext context,
    lesson,
    AppProvider appProvider,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          // Navigate to lesson detail screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LessonDetailScreen(lesson: lesson),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: lesson.isCompleted
                      ? Colors.green.withOpacity(0.1)
                      : const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  lesson.isCompleted ? Icons.check_circle : Icons.school,
                  color: lesson.isCompleted
                      ? Colors.green
                      : const Color(0xFF4CAF50),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lesson.description,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${lesson.duration} min',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.amber[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${lesson.coinReward} XP',
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
              if (lesson.isCompleted)
                const Icon(Icons.check_circle, color: Colors.green, size: 24)
              else
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey,
                  size: 16,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuizCard(
    BuildContext context,
    Quiz quiz,
    AppProvider appProvider,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () async {
          // Show ad before starting quiz
          final adShown = await appProvider.showQuizAd();

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuizDetailScreen(quiz: quiz),
            ),
          );

          if (adShown) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Quiz ad bonus! +5 coins earned'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF9C27B0).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.quiz,
                      color: const Color(0xFF9C27B0),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                quiz.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (quiz.isPremium)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'PREMIUM',
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
                          quiz.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  // Difficulty Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: quiz.difficultyColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      quiz.difficultyText,
                      style: TextStyle(
                        color: quiz.difficultyColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Category
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF9C27B0).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      quiz.category,
                      style: const TextStyle(
                        color: Color(0xFF9C27B0),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.quiz, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${quiz.questions.length} questions',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${quiz.timeLimit} min',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.monetization_on,
                    size: 16,
                    color: Colors.amber[700],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${quiz.coinReward} coins',
                    style: TextStyle(
                      color: Colors.amber[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Quiz> _getQuizzes() {
    return [
      Quiz(
        id: '1',
        title: 'Programming Basics',
        description: 'Test your fundamental programming knowledge',
        coinReward: 20,
        category: 'Programming',
        difficulty: QuizDifficulty.easy,
        timeLimit: 5,
        questions: [
          QuizQuestion(
            id: '1',
            question: 'What does HTML stand for?',
            options: [
              'HyperText Markup Language',
              'High Tech Modern Language',
              'Home Tool Markup Language',
              'Hyperlink and Text Markup Language',
            ],
            correctAnswerIndex: 0,
            explanation:
                'HTML stands for HyperText Markup Language, the standard markup language for creating web pages.',
          ),
          QuizQuestion(
            id: '2',
            question:
                'Which programming language is known for its simplicity and readability?',
            options: ['Java', 'Python', 'C++', 'Assembly'],
            correctAnswerIndex: 1,
            explanation:
                'Python is widely known for its simple, readable syntax that makes it beginner-friendly.',
          ),
          QuizQuestion(
            id: '3',
            question: 'What is the purpose of CSS?',
            options: [
              'To create web pages',
              'To style web pages',
              'To add interactivity',
              'To store data',
            ],
            correctAnswerIndex: 1,
            explanation:
                'CSS (Cascading Style Sheets) is used to style and format web pages.',
          ),
        ],
      ),
      Quiz(
        id: '2',
        title: 'Web Development',
        description: 'Test your web development skills',
        coinReward: 30,
        category: 'Web Development',
        difficulty: QuizDifficulty.medium,
        timeLimit: 8,
        questions: [
          QuizQuestion(
            id: '1',
            question: 'What does API stand for?',
            options: [
              'Application Programming Interface',
              'Advanced Programming Integration',
              'Automated Program Interface',
              'Application Process Integration',
            ],
            correctAnswerIndex: 0,
            explanation:
                'API stands for Application Programming Interface, which allows different software applications to communicate.',
          ),
          QuizQuestion(
            id: '2',
            question: 'Which HTTP method is used to retrieve data?',
            options: ['POST', 'PUT', 'GET', 'DELETE'],
            correctAnswerIndex: 2,
            explanation:
                'GET is used to retrieve data from a server, while POST is for sending data.',
          ),
        ],
      ),
      Quiz(
        id: '3',
        title: 'Mobile Development',
        description: 'Test your mobile app development knowledge',
        coinReward: 25,
        category: 'Mobile Development',
        difficulty: QuizDifficulty.medium,
        timeLimit: 7,
        questions: [
          QuizQuestion(
            id: '1',
            question: 'What is Flutter?',
            options: [
              'A programming language',
              'A UI framework for building mobile apps',
              'A database system',
              'A web browser',
            ],
            correctAnswerIndex: 1,
            explanation:
                'Flutter is Google\'s UI framework for building natively compiled applications for mobile, web, and desktop.',
          ),
          QuizQuestion(
            id: '2',
            question: 'Which language does Flutter use?',
            options: ['Java', 'Swift', 'Dart', 'Kotlin'],
            correctAnswerIndex: 2,
            explanation: 'Flutter uses Dart as its programming language.',
          ),
        ],
      ),
    ];
  }
}
