import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import '../models/lesson.dart';
import '../providers/app_provider.dart';
import '../services/api_service.dart';
import '../services/ad_service.dart';
import '../widgets/banner_ad_widget.dart';

class LessonDetailScreen extends StatefulWidget {
  final Lesson lesson;

  const LessonDetailScreen({super.key, required this.lesson});

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  Timer? _progressTimer;
  Timer? _saveTimer;
  DateTime? _sessionStartTime;
  int _totalReadingTimeSeconds = 0;
  double _currentScrollPosition = 0.0;
  bool _isLoading = true;
  bool _isSaving = false;
  Map<String, dynamic>? _progressData;

  @override
  void initState() {
    super.initState();
    _sessionStartTime = DateTime.now();
    _scrollController.addListener(_onScroll);
    _loadProgress();
    _startProgressTracking();
    _startAutoSave();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _progressTimer?.cancel();
    _saveTimer?.cancel();
    _saveProgress(); // Save one last time before leaving
    super.dispose();
  }

  /// Load existing progress from backend
  Future<void> _loadProgress() async {
    try {
      final progress = await ApiService.getLessonProgress(widget.lesson.id);
      setState(() {
        _progressData = progress;
        _totalReadingTimeSeconds = progress['timeSpentSeconds'] ?? 0;
        _currentScrollPosition = (progress['scrollPosition'] ?? 0).toDouble();
        _isLoading = false;
      });

      // Scroll to last read position after loading
      if (_currentScrollPosition > 0 && _scrollController.hasClients) {
        Future.delayed(const Duration(milliseconds: 500), () {
          final maxScroll = _scrollController.position.maxScrollExtent;
          final targetPosition = (maxScroll * _currentScrollPosition / 100.0);
          _scrollController.animateTo(
            targetPosition,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        });
      }
    } catch (e) {
      print('Error loading progress: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Track scroll position
  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (maxScroll > 0) {
      setState(() {
        _currentScrollPosition = (currentScroll / maxScroll * 100).clamp(0.0, 100.0);
      });
    }
  }

  /// Start tracking reading time (every second)
  void _startProgressTracking() {
    _progressTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _totalReadingTimeSeconds++;
      });
    });
  }

  /// Auto-save progress every 5 seconds
  void _startAutoSave() {
    _saveTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _saveProgress();
    });
  }

  /// Save progress to backend
  Future<void> _saveProgress() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final sessionDuration = DateTime.now().difference(_sessionStartTime!).inSeconds;

      await ApiService.updateLessonProgress(
        lessonId: widget.lesson.id,
        scrollPosition: _currentScrollPosition,
        timeSpentSeconds: _totalReadingTimeSeconds,
        sessionStartedAt: _sessionStartTime,
        sessionEndedAt: DateTime.now(),
        sessionDuration: sessionDuration,
      );
    } catch (e) {
      print('Error saving progress: $e');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  /// Mark lesson as complete manually
  Future<void> _markComplete() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);

    try {
      // Show ad before marking complete
      final adShown = await appProvider.showLessonAd();

      // Mark as complete in backend
      await ApiService.completeLesson(widget.lesson.id);

      // Update local state
      await appProvider.completeLesson(widget.lesson.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              adShown
                  ? 'Lesson completed! +${widget.lesson.coinReward + 5} coins (with ad bonus)'
                  : 'Lesson completed! +${widget.lesson.coinReward} coins',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // Navigate back to lessons list
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error completing lesson: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes}m ${remainingSeconds}s';
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.lesson.isCompleted;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.lesson.title,
          style: const TextStyle(fontSize: 16),
        ),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        actions: [
          // Reading time display
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                _formatDuration(_totalReadingTimeSeconds),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Progress indicator
                LinearProgressIndicator(
                  value: _currentScrollPosition / 100,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                  minHeight: 6,
                ),

                // Lesson content
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Lesson info card
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.lesson.title,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.lesson.summary,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(Icons.access_time, color: Colors.white70, size: 18),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${widget.lesson.estMinutes} min read',
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                  const SizedBox(width: 16),
                                  const Icon(Icons.monetization_on, color: Colors.amber, size: 18),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${widget.lesson.coinReward} coins',
                                    style: const TextStyle(
                                      color: Colors.amber,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (isCompleted)
                                    const Icon(Icons.check_circle, color: Colors.greenAccent, size: 24),
                                ],
                              ),
                              if (_currentScrollPosition > 0)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12.0),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.bookmark, color: Colors.white70, size: 18),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${_currentScrollPosition.toInt()}% read',
                                        style: const TextStyle(color: Colors.white70),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Markdown content
                        MarkdownBody(
                          data: widget.lesson.contentMD,
                          selectable: true,
                          styleSheet: MarkdownStyleSheet(
                            h1: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                            h2: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4CAF50),
                            ),
                            h3: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF666666),
                            ),
                            p: const TextStyle(
                              fontSize: 16,
                              height: 1.6,
                              color: Color(0xFF333333),
                            ),
                            listBullet: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF4CAF50),
                            ),
                            code: const TextStyle(
                              backgroundColor: Color(0xFFF5F5F5),
                              fontFamily: 'monospace',
                            ),
                            codeblockDecoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            blockquote: const TextStyle(
                              color: Color(0xFF666666),
                              fontStyle: FontStyle.italic,
                            ),
                            blockquoteDecoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              border: Border(
                                left: BorderSide(
                                  color: const Color(0xFF4CAF50),
                                  width: 4,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Complete lesson button
                        if (!isCompleted)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _currentScrollPosition >= 80 ? _markComplete : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4CAF50),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                              ),
                              child: Text(
                                _currentScrollPosition >= 80
                                    ? 'Complete Lesson & Earn ${widget.lesson.coinReward} Coins'
                                    : 'Read ${(80 - _currentScrollPosition).toInt()}% more to complete',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                        if (isCompleted)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle, color: Colors.green),
                                SizedBox(width: 8),
                                Text(
                                  'Lesson Completed!',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                // Bottom ad
                BannerAdWidget(),
              ],
            ),
    );
  }
}
