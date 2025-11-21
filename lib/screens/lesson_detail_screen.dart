import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import '../models/lesson.dart';
import '../providers/app_provider.dart';
import '../services/api_service.dart';
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
  Timer? _adTimer;
  DateTime? _sessionStartTime;
  int _totalReadingTimeSeconds = 0;
  double _currentScrollPosition = 0.0;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _sessionStartTime = DateTime.now();
    _scrollController.addListener(_onScroll);
    _loadProgress();
    _startProgressTracking();
    _startAutoSave();
    _showInitialAd();
    _startPeriodicAds();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _progressTimer?.cancel();
    _saveTimer?.cancel();
    _adTimer?.cancel();
    // Save progress without state updates since widget is being disposed
    _saveProgress(skipStateUpdate: true);
    super.dispose();
  }

  /// Load existing progress from backend
  Future<void> _loadProgress() async {
    try {
      // Note: getLessonProgress doesn't exist in new API
      // Progress is tracked via updateLessonProgress
      // For now, we'll start fresh or use local storage
      setState(() {
        _totalReadingTimeSeconds = 0;
        _currentScrollPosition = 0.0;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
  Future<void> _saveProgress({bool skipStateUpdate = false}) async {
    if (_isSaving) return;

    // Only update state if widget is still mounted and we're not skipping state updates
    if (!skipStateUpdate && mounted) {
      setState(() {
        _isSaving = true;
      });
    }

    try {
      // Calculate progress percentage based on scroll position
      double progressPercent = 0.0;
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        if (maxScroll > 0) {
          progressPercent = (_currentScrollPosition / 100.0).clamp(0.0, 1.0) * 100.0;
        }
      }

      await ApiService.updateLessonProgress(
        lessonId: widget.lesson.id,
        progressPercent: progressPercent,
        timeSpentSeconds: _totalReadingTimeSeconds,
      );
    } catch (e) {
      if (mounted && !skipStateUpdate) {
        // Error saving progress - continue silently
      }
    } finally {
      // Only update state if widget is still mounted and we're not skipping state updates
      if (!skipStateUpdate && mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  /// Show ad when lesson opens
  Future<void> _showInitialAd() async {
    // Wait a moment for the screen to render
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    try {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      await appProvider.showLessonAd();
    } catch (e) {
      print('Error showing initial lesson ad: $e');
    }
  }

  /// Start periodic ads every 3 minutes
  void _startPeriodicAds() {
    _adTimer = Timer.periodic(const Duration(minutes: 3), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }

      try {
        final appProvider = Provider.of<AppProvider>(context, listen: false);
        await appProvider.showLessonAd();
      } catch (e) {
        print('Error showing periodic lesson ad: $e');
      }
    });
  }

  /// Mark lesson as complete manually
  Future<void> _markComplete() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);

    try {
      // Show ad before marking complete
      final adShown = await appProvider.showLessonAd();

      // Mark as complete in backend
      // Send xpReward (coinReward) so backend knows the XP amount for mobile app lessons
      await ApiService.completeLesson(
        lessonId: widget.lesson.id,
        timeSpentSeconds: _totalReadingTimeSeconds,
        xpReward: widget.lesson.coinReward, // Send XP reward for mobile app local lessons
      );

      // Update local state
      await appProvider.completeLesson(widget.lesson.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              adShown
                  ? 'Lesson completed! +${widget.lesson.coinReward + 5} XP (with ad bonus)'
                  : 'Lesson completed! +${widget.lesson.coinReward} XP',
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
                                  const Icon(Icons.star, color: Colors.amber, size: 18),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${widget.lesson.coinReward} XP',
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
                                    ? 'Complete Lesson & Earn ${widget.lesson.coinReward} XP'
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
