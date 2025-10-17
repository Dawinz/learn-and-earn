import { Request, Response } from 'express';
import User, { ILessonProgress, IReadingSession } from '../models/User';

/**
 * Update lesson reading progress
 * POST /api/users/lessons/:lessonId/progress
 */
export const updateLessonProgress = async (req: Request, res: Response) => {
  try {
    const { lessonId } = req.params;
    const deviceId = req.headers['x-device-id'] as string;
    const {
      scrollPosition,
      timeSpentSeconds,
      sessionStartedAt,
      sessionEndedAt,
      sessionDuration
    } = req.body;

    if (!deviceId) {
      return res.status(401).json({ error: 'Device ID required' });
    }

    const user = await User.findOne({ deviceId });
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Find existing progress for this lesson
    const existingProgressIndex = user.lessonProgress.findIndex(
      (p) => p.lessonId === lessonId
    );

    const now = new Date();

    if (existingProgressIndex >= 0) {
      // Update existing progress
      const progress = user.lessonProgress[existingProgressIndex];

      // Update scroll position (only if it's higher)
      if (scrollPosition > progress.scrollPosition) {
        progress.scrollPosition = scrollPosition;
      }

      // Update time spent
      if (timeSpentSeconds) {
        progress.timeSpentSeconds = timeSpentSeconds;
      }

      // Update last read time
      progress.lastReadAt = now;

      // Add reading session if provided
      if (sessionStartedAt && sessionDuration) {
        const newSession: IReadingSession = {
          startedAt: new Date(sessionStartedAt),
          endedAt: sessionEndedAt ? new Date(sessionEndedAt) : now,
          durationSeconds: sessionDuration
        };
        progress.readingSessions.push(newSession);
      }

      // Check if lesson should be marked as completed
      // Criteria: 80% scrolled and at least 70% of estimated time spent
      if (scrollPosition >= 80 && !progress.isCompleted) {
        progress.isCompleted = true;
        progress.completedAt = now;

        // Also update completedLessons array for backward compatibility
        if (!user.completedLessons.includes(lessonId)) {
          user.completedLessons.push(lessonId);
        }
      }

      user.lessonProgress[existingProgressIndex] = progress;
    } else {
      // Create new progress entry
      const newProgress: ILessonProgress = {
        lessonId,
        scrollPosition: scrollPosition || 0,
        timeSpentSeconds: timeSpentSeconds || 0,
        lastReadAt: now,
        isCompleted: false,
        readingSessions: []
      };

      // Add reading session if provided
      if (sessionStartedAt && sessionDuration) {
        newProgress.readingSessions.push({
          startedAt: new Date(sessionStartedAt),
          endedAt: sessionEndedAt ? new Date(sessionEndedAt) : now,
          durationSeconds: sessionDuration
        });
      }

      // Check if should be marked completed immediately
      if (scrollPosition >= 80) {
        newProgress.isCompleted = true;
        newProgress.completedAt = now;

        if (!user.completedLessons.includes(lessonId)) {
          user.completedLessons.push(lessonId);
        }
      }

      user.lessonProgress.push(newProgress);
    }

    await user.save();

    // Return the updated progress
    const updatedProgress = user.lessonProgress.find(p => p.lessonId === lessonId);

    res.json({
      success: true,
      progress: updatedProgress
    });
  } catch (error) {
    console.error('Error updating lesson progress:', error);
    res.status(500).json({ error: 'Failed to update lesson progress' });
  }
};

/**
 * Get progress for a specific lesson
 * GET /api/users/lessons/:lessonId/progress
 */
export const getLessonProgress = async (req: Request, res: Response) => {
  try {
    const { lessonId } = req.params;
    const deviceId = req.headers['x-device-id'] as string;

    if (!deviceId) {
      return res.status(401).json({ error: 'Device ID required' });
    }

    const user = await User.findOne({ deviceId });
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    const progress = user.lessonProgress.find(p => p.lessonId === lessonId);

    if (!progress) {
      // Return default progress if none exists
      return res.json({
        lessonId,
        scrollPosition: 0,
        timeSpentSeconds: 0,
        lastReadAt: null,
        isCompleted: false,
        readingSessions: []
      });
    }

    res.json(progress);
  } catch (error) {
    console.error('Error getting lesson progress:', error);
    res.status(500).json({ error: 'Failed to get lesson progress' });
  }
};

/**
 * Get all lesson progress for a user
 * GET /api/users/lessons/progress
 */
export const getAllLessonProgress = async (req: Request, res: Response) => {
  try {
    const deviceId = req.headers['x-device-id'] as string;

    if (!deviceId) {
      return res.status(401).json({ error: 'Device ID required' });
    }

    const user = await User.findOne({ deviceId });
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json({
      progress: user.lessonProgress,
      completedCount: user.lessonProgress.filter(p => p.isCompleted).length,
      totalProgress: user.lessonProgress.length
    });
  } catch (error) {
    console.error('Error getting all lesson progress:', error);
    res.status(500).json({ error: 'Failed to get lesson progress' });
  }
};

/**
 * Reset progress for a specific lesson
 * DELETE /api/users/lessons/:lessonId/progress
 */
export const resetLessonProgress = async (req: Request, res: Response) => {
  try {
    const { lessonId } = req.params;
    const deviceId = req.headers['x-device-id'] as string;

    if (!deviceId) {
      return res.status(401).json({ error: 'Device ID required' });
    }

    const user = await User.findOne({ deviceId });
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    // Remove progress for this lesson
    user.lessonProgress = user.lessonProgress.filter(p => p.lessonId !== lessonId);

    // Also remove from completedLessons array
    user.completedLessons = user.completedLessons.filter(id => id !== lessonId);

    await user.save();

    res.json({
      success: true,
      message: 'Lesson progress reset successfully'
    });
  } catch (error) {
    console.error('Error resetting lesson progress:', error);
    res.status(500).json({ error: 'Failed to reset lesson progress' });
  }
};

/**
 * Mark lesson as completed manually
 * POST /api/users/lessons/:lessonId/complete
 */
export const markLessonComplete = async (req: Request, res: Response) => {
  try {
    const { lessonId } = req.params;
    const deviceId = req.headers['x-device-id'] as string;

    if (!deviceId) {
      return res.status(401).json({ error: 'Device ID required' });
    }

    const user = await User.findOne({ deviceId });
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    const existingProgressIndex = user.lessonProgress.findIndex(
      (p) => p.lessonId === lessonId
    );

    const now = new Date();

    if (existingProgressIndex >= 0) {
      // Update existing progress
      user.lessonProgress[existingProgressIndex].isCompleted = true;
      user.lessonProgress[existingProgressIndex].completedAt = now;
      user.lessonProgress[existingProgressIndex].scrollPosition = 100;
    } else {
      // Create new completed progress
      user.lessonProgress.push({
        lessonId,
        scrollPosition: 100,
        timeSpentSeconds: 0,
        lastReadAt: now,
        completedAt: now,
        isCompleted: true,
        readingSessions: []
      });
    }

    // Update completedLessons array
    if (!user.completedLessons.includes(lessonId)) {
      user.completedLessons.push(lessonId);
    }

    await user.save();

    res.json({
      success: true,
      message: 'Lesson marked as completed'
    });
  } catch (error) {
    console.error('Error marking lesson complete:', error);
    res.status(500).json({ error: 'Failed to mark lesson complete' });
  }
};
