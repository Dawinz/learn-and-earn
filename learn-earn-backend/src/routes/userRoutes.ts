import { Router } from 'express';
import {
  registerDevice,
  setMobileMoneyNumber,
  getUserProfile,
  completeLesson,
  getUserProgress,
  performDailyReset
} from '../controllers/userController';
import { authenticateDevice } from '../middleware/auth';
import { authLimiter } from '../middleware/rateLimit';

const router = Router();

// NOTE: Authentication temporarily disabled for testing
// TODO: Re-enable authentication in production

// Public routes
router.post('/register', authLimiter, registerDevice);

// Protected routes - authentication disabled for testing
// router.use(authenticateDevice);

router.get('/profile', getUserProfile);
router.post('/mobile-number', setMobileMoneyNumber);
router.get('/progress', getUserProgress);
router.post('/progress/reset', performDailyReset);
router.post('/lessons/:lessonId/complete', completeLesson);

export default router;
