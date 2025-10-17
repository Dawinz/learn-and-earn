import { Router } from 'express';
import {
  adminLogin,
  getDashboard,
  getPayoutQueue,
  updatePayoutStatus,
  getSettings,
  updateSettings,
  getAuditLogs,
  getUsers,
  blockUser,
  unblockUser,
  getAnalytics
} from '../controllers/adminController';
import {
  getAdminLessons,
  updateLesson,
  createLesson,
  deleteLesson
} from '../controllers/lessonController';
import { authenticateAdmin } from '../middleware/auth';

const router = Router();

// NOTE: Authentication temporarily disabled for testing
// TODO: Re-enable authentication in production

// Login route (no auth required)
router.post('/login', adminLogin);

// All admin routes - authentication disabled for testing
// router.use(authenticateAdmin);

router.get('/dashboard', getDashboard);
router.get('/payouts', getPayoutQueue);
router.put('/payouts/:payoutId', updatePayoutStatus);
router.get('/lessons', getAdminLessons);
router.post('/lessons', createLesson);
router.put('/lessons/:lessonId', updateLesson);
router.delete('/lessons/:lessonId', deleteLesson);
router.get('/settings', getSettings);
router.put('/settings', updateSettings);
router.get('/audits', getAuditLogs);
router.get('/users', getUsers);
router.put('/users/:userId/block', blockUser);
router.put('/users/:userId/unblock', unblockUser);
router.get('/analytics', getAnalytics);

export default router;
