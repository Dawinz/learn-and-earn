import express from 'express';
import {
  updateLessonProgress,
  getLessonProgress,
  getAllLessonProgress,
  resetLessonProgress,
  markLessonComplete
} from '../controllers/lessonProgressController';

const router = express.Router();

// Get all lesson progress for user
router.get('/lessons/progress', getAllLessonProgress);

// Get progress for specific lesson
router.get('/lessons/:lessonId/progress', getLessonProgress);

// Update lesson progress
router.post('/lessons/:lessonId/progress', updateLessonProgress);

// Mark lesson as complete
router.post('/lessons/:lessonId/complete', markLessonComplete);

// Reset lesson progress
router.delete('/lessons/:lessonId/progress', resetLessonProgress);

export default router;
