import { Router } from 'express';
import {
  requestPayout,
  getPayoutHistory,
  getPayoutStatus,
  getCooldownStatus,
  getAllPayouts,
  updatePayoutStatus
} from '../controllers/payoutController';
import { authenticateDevice, checkEmulatorPayoutPolicy } from '../middleware/auth';
import { payoutLimiter } from '../middleware/rateLimit';

const router = Router();

// All payout routes require authentication
router.use(authenticateDevice);

// User payout routes
router.post('/request', payoutLimiter, checkEmulatorPayoutPolicy, requestPayout);
router.get('/history', getPayoutHistory);
router.get('/status/:payoutId', getPayoutStatus);
router.get('/cooldown', getCooldownStatus);

// Admin payout routes (add admin middleware when available)
router.get('/admin/all', getAllPayouts);
router.patch('/admin/:payoutId/status', updatePayoutStatus);

export default router;
