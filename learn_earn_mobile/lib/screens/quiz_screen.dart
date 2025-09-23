import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/quiz.dart';
import '../services/ad_service.dart';
import 'quiz_detail_screen.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Quiz'),
            backgroundColor: const Color(0xFF2196F3),
            foregroundColor: Colors.white,
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
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Test Your Knowledge',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                    itemCount: _getQuizzes().length,
                    itemBuilder: (context, index) {
                      final quiz = _getQuizzes()[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () async {
                            // Show ad before starting quiz
                            final adShown = await appProvider.showQuizAd();

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    QuizDetailScreen(quiz: quiz),
                              ),
                            );

                            if (adShown) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Quiz ad bonus! +5 coins earned',
                                  ),
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
                                        color: const Color(
                                          0xFF9C27B0,
                                        ).withOpacity(0.1),
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.amber,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  child: const Text(
                                                    'PREMIUM',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                        color: quiz.difficultyColor.withOpacity(
                                          0.1,
                                        ),
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
                                        color: const Color(
                                          0xFF9C27B0,
                                        ).withOpacity(0.1),
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
                                    Icon(
                                      Icons.quiz,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${quiz.questions.length} questions',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Icon(
                                      Icons.access_time,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${quiz.timeLimit} min',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
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
          ),
        );
      },
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
      Quiz(
        id: '4',
        title: 'Advanced Algorithms',
        description: 'Challenge yourself with complex algorithms',
        coinReward: 50,
        category: 'Programming',
        difficulty: QuizDifficulty.hard,
        timeLimit: 15,
        isPremium: true,
        questions: [
          QuizQuestion(
            id: '1',
            question: 'What is the time complexity of binary search?',
            options: ['O(n)', 'O(log n)', 'O(n²)', 'O(1)'],
            correctAnswerIndex: 1,
            explanation:
                'Binary search has O(log n) time complexity because it eliminates half of the search space in each iteration.',
          ),
          QuizQuestion(
            id: '2',
            question:
                'Which sorting algorithm has the best average-case time complexity?',
            options: [
              'Bubble Sort',
              'Quick Sort',
              'Selection Sort',
              'Insertion Sort',
            ],
            correctAnswerIndex: 1,
            explanation:
                'Quick Sort has O(n log n) average-case time complexity, making it one of the most efficient sorting algorithms.',
          ),
        ],
      ),
      Quiz(
        id: '5',
        title: 'Database Design',
        description: 'Test your database knowledge',
        coinReward: 35,
        category: 'Databases',
        difficulty: QuizDifficulty.medium,
        timeLimit: 10,
        questions: [
          QuizQuestion(
            id: '1',
            question: 'What does ACID stand for in database transactions?',
            options: [
              'Atomicity, Consistency, Isolation, Durability',
              'Accuracy, Consistency, Integrity, Durability',
              'Atomicity, Correctness, Isolation, Durability',
              'Accuracy, Consistency, Integrity, Data',
            ],
            correctAnswerIndex: 0,
            explanation:
                'ACID stands for Atomicity, Consistency, Isolation, and Durability - the four key properties of database transactions.',
          ),
        ],
      ),
      Quiz(
        id: '6',
        title: 'Cloud Computing',
        description: 'Test your cloud platform knowledge',
        coinReward: 40,
        category: 'Cloud',
        difficulty: QuizDifficulty.hard,
        timeLimit: 12,
        questions: [
          QuizQuestion(
            id: '1',
            question: 'What is the main advantage of serverless computing?',
            options: [
              'Lower cost',
              'No server management',
              'Better performance',
              'More security',
            ],
            correctAnswerIndex: 1,
            explanation:
                'Serverless computing eliminates the need for server management, allowing developers to focus on code rather than infrastructure.',
          ),
        ],
      ),
    ];
  }
}
