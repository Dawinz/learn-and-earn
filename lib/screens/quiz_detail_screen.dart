import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/quiz.dart';

class QuizDetailScreen extends StatefulWidget {
  final Quiz quiz;

  const QuizDetailScreen({super.key, required this.quiz});

  @override
  State<QuizDetailScreen> createState() => _QuizDetailScreenState();
}

class _QuizDetailScreenState extends State<QuizDetailScreen> {
  int _currentQuestionIndex = 0;
  List<int?> _selectedAnswers = [];
  bool _showResults = false;
  QuizResult? _result;
  late DateTime _startTime;

  @override
  void initState() {
    super.initState();
    _selectedAnswers = List.filled(widget.quiz.questions.length, null);
    _startTime = DateTime.now();
  }

  void _selectAnswer(int answerIndex) {
    setState(() {
      _selectedAnswers[_currentQuestionIndex] = answerIndex;
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < widget.quiz.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      _submitQuiz();
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  void _submitQuiz() async {
    final answers = _selectedAnswers.map((answer) => answer != null).toList();
    final correctAnswers = widget.quiz.questions
        .asMap()
        .entries
        .map(
          (entry) =>
              entry.value.correctAnswerIndex == _selectedAnswers[entry.key],
        )
        .toList();

    final score = correctAnswers.where((isCorrect) => isCorrect).length;

    setState(() {
      _result = QuizResult(
        quizId: widget.quiz.id,
        score: score,
        totalQuestions: widget.quiz.questions.length,
        answers: correctAnswers,
        completedAt: DateTime.now(),
      );
      _showResults = true;
    });

    // Sync with backend if this is a lesson quiz
    if (widget.quiz.id.startsWith('lesson_')) {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      final lessonId = widget.quiz.id.replaceFirst('lesson_', '');
      final timeSpent = DateTime.now().difference(_startTime).inSeconds;

      // Calculate correct answers count
      final correctCount = correctAnswers.where((isCorrect) => isCorrect).length;

      final result = await appProvider.submitQuizToBackend(
        lessonId,
        _selectedAnswers.map((answer) => answer ?? 0).toList(),
        timeSpent,
        correctAnswers: correctCount,
        totalQuestions: widget.quiz.questions.length,
        xpReward: _result!.passed ? widget.quiz.coinReward : 0,
      );

      if (result['success'] == true || result['passed'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Quiz synced with backend! Earned ${result['xpEarned'] ?? widget.quiz.coinReward} XP!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      // Award XP locally for non-lesson quizzes
      if (_result!.passed) {
        final appProvider = Provider.of<AppProvider>(context, listen: false);
        appProvider.addXp(widget.quiz.coinReward, 'Quiz Completed');
      }
    }
  }

  void _restartQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _selectedAnswers = List.filled(widget.quiz.questions.length, null);
      _showResults = false;
      _result = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showResults && _result != null) {
      return _buildResultsScreen();
    }

    final question = widget.quiz.questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / widget.quiz.questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quiz.title),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progress bar
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF2196F3),
              ),
            ),

            const SizedBox(height: 16),

            // Question counter
            Text(
              'Question ${_currentQuestionIndex + 1} of ${widget.quiz.questions.length}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 24),

            // Question
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  question.question,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Answer options
            Expanded(
              child: ListView.builder(
                itemCount: question.options.length,
                itemBuilder: (context, index) {
                  final isSelected =
                      _selectedAnswers[_currentQuestionIndex] == index;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: isSelected ? 4 : 2,
                    color: isSelected
                        ? const Color(0xFF2196F3).withOpacity(0.1)
                        : null,
                    child: ListTile(
                      title: Text(
                        question.options[index],
                        style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected ? const Color(0xFF2196F3) : null,
                        ),
                      ),
                      leading: Radio<int>(
                        value: index,
                        groupValue: _selectedAnswers[_currentQuestionIndex],
                        onChanged: (value) => _selectAnswer(value!),
                        activeColor: const Color(0xFF2196F3),
                      ),
                      onTap: () => _selectAnswer(index),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Navigation buttons
            Row(
              children: [
                if (_currentQuestionIndex > 0)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _previousQuestion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[600],
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Previous'),
                    ),
                  ),
                if (_currentQuestionIndex > 0) const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _selectedAnswers[_currentQuestionIndex] != null
                        ? _nextQuestion
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      _currentQuestionIndex == widget.quiz.questions.length - 1
                          ? 'Submit Quiz'
                          : 'Next',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Results'),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Icon(
                      _result!.passed ? Icons.check_circle : Icons.cancel,
                      size: 80,
                      color: _result!.passed ? Colors.green : Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _result!.passed ? 'Congratulations!' : 'Try Again',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _result!.passed ? Colors.green : Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You scored ${_result!.score}/${_result!.totalQuestions} (${_result!.percentage.toStringAsFixed(1)}%)',
                      style: const TextStyle(fontSize: 18),
                    ),
                    if (_result!.passed) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '+${widget.quiz.coinReward} XP Earned!',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Question review
            const Text(
              'Question Review',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: ListView.builder(
                itemCount: widget.quiz.questions.length,
                itemBuilder: (context, index) {
                  final question = widget.quiz.questions[index];
                  final isCorrect = _result!.answers[index];
                  final selectedAnswer = _selectedAnswers[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    color: isCorrect
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isCorrect ? Icons.check : Icons.close,
                                color: isCorrect ? Colors.green : Colors.red,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Question ${index + 1}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            question.question,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your answer: ${selectedAnswer != null ? question.options[selectedAnswer] : "Not answered"}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (!isCorrect) ...[
                            Text(
                              'Correct answer: ${question.options[question.correctAnswerIndex]}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              question.explanation,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _restartQuiz,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[600],
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Retake Quiz'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Back to Quizzes'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
