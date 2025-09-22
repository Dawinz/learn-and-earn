import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/lesson.dart';
import '../models/earning.dart';
import 'quiz_screen.dart';

class LessonDetailScreen extends StatefulWidget {
  final Lesson lesson;

  const LessonDetailScreen({super.key, required this.lesson});

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _splitContentIntoPages();
  }

  List<String> _contentPages = [];

  void _splitContentIntoPages() {
    // Split content by ad slots or create natural breaks
    final content = widget.lesson.contentMD;
    final adSlots = widget.lesson.adSlots
        .where((slot) => slot.position == 'mid-lesson')
        .toList();

    if (adSlots.isEmpty) {
      // Split by paragraphs or create 2-3 pages
      final paragraphs = content.split('\n\n');
      _contentPages = paragraphs;
    } else {
      // Split content around ad slots
      _contentPages = [content]; // Simplified for now
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lesson.title),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showLessonInfo,
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: (_currentPage + 1) / _contentPages.length,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '${_currentPage + 1}/${_contentPages.length}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _contentPages.length,
              itemBuilder: (context, index) {
                return _buildContentPage(_contentPages[index], index);
              },
            ),
          ),

          // Navigation
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (_currentPage > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: const Text('Previous'),
                    ),
                  ),
                if (_currentPage > 0) const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _currentPage == _contentPages.length - 1
                        ? _completeLesson
                        : _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      _currentPage == _contentPages.length - 1
                          ? 'Complete Lesson'
                          : 'Next',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentPage(String content, int pageIndex) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Content
          MarkdownBody(
            data: content,
            styleSheet: MarkdownStyleSheet(
              p: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
              h1: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              h2: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              h3: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),

          // Ad slot placeholder (if applicable)
          if (pageIndex < _contentPages.length - 1) ...[
            const SizedBox(height: 24),
            _buildAdSlot(),
          ],
        ],
      ),
    );
  }

  Widget _buildAdSlot() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.play_circle_outline,
            size: 40,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 8),
          Text(
            'Watch Ad to Continue',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Earn coins by watching a short ad',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _showAd,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Watch Ad'),
          ),
        ],
      ),
    );
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _completeLesson() {
    // Record earning for lesson completion
    context.read<AppProvider>().recordEarning(
      source: EarningSource.lesson,
      lessonId: widget.lesson.id,
    );

    // Navigate to quiz
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QuizScreen(lesson: widget.lesson),
      ),
    );
  }

  void _showAd() {
    // TODO: Implement AdMob integration
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ad integration coming soon!')),
    );
  }

  void _showLessonInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.lesson.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category: ${widget.lesson.category}'),
            Text('Duration: ${widget.lesson.formattedDuration}'),
            Text('Questions: ${widget.lesson.quiz.length}'),
            if (widget.lesson.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Tags: ${widget.lesson.tags.join(', ')}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
