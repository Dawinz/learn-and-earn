# Complete Tracking Checklist - What Needs to Be Tracked

## ✅ CURRENTLY TRACKED IN BACKEND

### 1. **XP System**
- ✅ XP Balance (`user_xp_balance.xp`)
- ✅ All XP Transactions (`xp_ledger`)
  - Lesson completion XP
  - Daily login XP
  - Ad reward XP
  - Quiz completion XP
  - Daily reset bonus XP
  - Navigation ad bonus XP
  - Profile ad bonus XP
  - Lesson ad bonus XP
  - Quiz ad bonus XP
  - Payout ad bonus XP
  - Daily challenge ad bonus XP

### 2. **Lessons**
- ✅ Lesson completion status (`lesson_progress.is_completed`)
- ✅ Lesson progress percentage (`lesson_progress.progress_percent`)
- ✅ Time spent on lessons (`lesson_progress.time_spent_seconds`)
- ✅ Completion timestamp (`lesson_progress.completed_at`)
- ✅ Total lessons completed count (`user_stats.total_lessons_completed`)

### 3. **Learning Streak**
- ✅ Current streak (`user_stats.learning_streak`)
- ✅ Last streak date (`user_stats.last_streak_date`)
- ✅ Longest streak (`user_stats.longest_streak`)

### 4. **Daily Login**
- ✅ Daily login history (`daily_logins`)
- ✅ Last daily login date (`user_stats.last_daily_login_date`)
- ✅ XP awarded per login (`daily_logins.xp_awarded`)
- ✅ Ad watched status (`daily_logins.ad_watched`)

### 5. **Ads**
- ✅ Total ad views (`user_stats.total_ad_views`)
- ✅ Ad XP rewards (via `xp_ledger` with source='ad_reward')

### 6. **User Profile**
- ✅ Email (`users_public.email`)
- ✅ Phone (`users_public.phone`)
- ✅ KYC level (`users_public.kyc_level`)
- ✅ Account status (`users_public.status`)

### 7. **Referrals**
- ✅ Referral codes (`referral_codes`)
- ✅ Referral relationships (`referrals`)
- ✅ Referral status and rewards

### 8. **Withdrawals**
- ✅ Withdrawal requests (`withdrawals`)
- ✅ XP debited
- ✅ Payout status

## ⚠️ PARTIALLY TRACKED (Needs Implementation)

### 9. **Quiz Submissions** ⚠️ MISSING
**What's tracked:** XP from quiz completion (via `xp_ledger`)
**What's MISSING:**
- ❌ Quiz answers (`quiz_submissions.answers`)
- ❌ Quiz scores (`quiz_submissions.score_percent`)
- ❌ Quiz pass/fail status (`quiz_submissions.passed`)
- ❌ Time spent on quiz (`quiz_submissions.time_spent_seconds`)
- ❌ Total quizzes completed count (`user_stats.total_quizzes_completed`) - not updated

**Action Needed:**
- Create `/quiz-submit` endpoint
- Update mobile app to submit quiz results
- Update `total_quizzes_completed` when quiz is submitted

### 10. **Achievements/Badges** ⚠️ MISSING
**What's tracked:** Table exists (`achievements`)
**What's MISSING:**
- ❌ Achievement unlock tracking
- ❌ Achievement XP rewards
- ❌ Achievement progress calculation
- ❌ Auto-unlock when conditions met

**Action Needed:**
- Create `/achievements/unlock` endpoint
- Create `/achievements` GET endpoint
- Auto-check and unlock achievements when:
  - First lesson completed
  - 5/10/20 quizzes completed
  - 10/50 ads watched
  - 7-day streak achieved
  - 1000+ XP earned

### 11. **Daily Reset** ⚠️ MISSING
**What's tracked:** Nothing in backend
**What's MISSING:**
- ❌ Daily reset history
- ❌ Daily reset bonus tracking
- ❌ Reset date tracking

**Action Needed:**
- Add `last_daily_reset_date` to `user_stats`
- Track daily reset bonus in `xp_ledger`
- Optionally create `daily_resets` table for history

## 📊 STATISTICS THAT CAN BE COMPUTED

### From Existing Data:
- ✅ Total XP earned (sum `xp_ledger.xp_delta` where positive)
- ✅ Total XP spent (sum `xp_ledger.xp_delta` where negative)
- ✅ XP by source (group by `xp_ledger.source`)
- ✅ Lessons completed count (count `lesson_progress` where `is_completed=true`)
- ✅ Average time per lesson (avg `lesson_progress.time_spent_seconds`)
- ✅ Daily login streak (from `daily_logins`)
- ✅ Total days logged in (count `daily_logins`)
- ✅ Ad views count (`user_stats.total_ad_views`)

### Missing Computations:
- ❌ Quiz completion count (need quiz submissions)
- ❌ Average quiz score (need quiz submissions)
- ❌ Quiz pass rate (need quiz submissions)
- ❌ Achievement progress (need achievement unlocks)
- ❌ Daily reset count (need daily reset tracking)

## 🎯 ACTION ITEMS TO COMPLETE TRACKING

### ✅ COMPLETED

1. **Quiz Submissions Tracking** ✅
   - [x] Create `/quiz-submit` endpoint
   - [x] Update mobile app to submit quiz results
   - [x] Update `total_quizzes_completed` in stats
   - [x] Track quiz answers, scores, time spent

2. **Achievement Unlocking** ✅
   - [x] Create `/achievements` GET endpoint
   - [x] Create `/achievements` POST endpoint
   - [x] Auto-check achievements on:
     - [x] Lesson completion
     - [x] Quiz completion
     - [x] Ad view
     - [x] Daily login (via streak check)
     - [x] XP milestones

### ⏳ REMAINING (Optional Enhancements)

3. **Daily Reset Tracking** (Optional)
   - [x] Add `last_daily_reset_date` to `user_stats` (migration applied)
   - [x] Create `daily_resets` table (migration applied)
   - [ ] Track daily reset bonus in `xp_ledger` via backend
   - [ ] Sync daily reset with backend endpoint

### Priority 2: Enhancements

4. **Quiz Statistics**
   - [ ] Track quiz completion count
   - [ ] Calculate average quiz score
   - [ ] Track quiz pass rate

5. **Achievement Progress**
   - [ ] Track progress toward each achievement
   - [ ] Show progress in UI
   - [ ] Award XP when achievements unlock

6. **Leaderboard Data**
   - [ ] Total XP (already tracked)
   - [ ] Learning streak (already tracked)
   - [ ] Lessons completed (already tracked)
   - [ ] Quizzes completed (needs quiz submissions)

## 📝 SUMMARY

### Fully Tracked ✅
- ✅ XP balance and all transactions
- ✅ Lesson completion and progress
- ✅ Learning streak
- ✅ Daily login
- ✅ Ad views
- ✅ User profile
- ✅ Quiz submissions (answers, scores, time spent)
- ✅ Achievement unlocks (auto-checked and unlocked)
- ✅ Total quizzes completed count
- ✅ Total lessons completed count
- ✅ Total ad views count

### Partially Tracked ⚠️
- Daily reset (local only, not synced to backend)

### Not Tracked ❌
- Daily reset history (table exists but not used)

## 🚀 Next Steps

1. **Deploy remaining functions:**
   - `user-stats`
   - `daily-login`

2. **Create missing endpoints:**
   - `/quiz-submit` - Submit quiz results
   - `/achievements` - Get user achievements
   - `/achievements/unlock` - Unlock achievement

3. **Update mobile app:**
   - Submit quiz results to backend
   - Sync achievement unlocks
   - Track daily reset in backend

