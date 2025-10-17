import { Router } from 'express';
import {
  getLessons,
  getLessonById,
  getCategories,
  getTags,
  searchLessons
} from '../controllers/lessonController';
import { authenticateDevice } from '../middleware/auth';

const router = Router();

// NOTE: Authentication temporarily disabled for testing
// TODO: Re-enable authentication in production
// All lesson routes require authentication
// router.use(authenticateDevice);

router.get('/', getLessons);
router.get('/search', searchLessons);
router.get('/categories', getCategories);
router.get('/tags', getTags);
router.get('/:lessonId', getLessonById);

export default router;
