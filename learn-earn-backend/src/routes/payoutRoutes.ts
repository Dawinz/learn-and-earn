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

// Admin payout routes (no auth required for now - TODO: add admin auth)
router.get('/admin/all', getAllPayouts);
router.patch('/admin/:payoutId/status', updatePayoutStatus);

// User payout routes require device authentication
router.use(authenticateDevice);
router.post('/request', payoutLimiter, checkEmulatorPayoutPolicy, requestPayout);
router.get('/history', getPayoutHistory);
router.get('/status/:payoutId', getPayoutStatus);
router.get('/cooldown', getCooldownStatus);

export default router;
