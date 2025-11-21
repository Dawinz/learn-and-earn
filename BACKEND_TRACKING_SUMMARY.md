# Backend Tracking Summary - Learn & Grow Mobile App

## Overview
This document outlines everything that is tracked in the backend for the Learn & Grow mobile app, from badges to XP and all user progress.

## Database Tables

### 1. `users_public`
**Purpose:** User profile information
- `id` (UUID) - User ID
- `phone` (TEXT) - Phone number (optional)
- `email` (TEXT) - Email address (unique)
- `kyc_level` (TEXT) - KYC verification level
- `status` (TEXT) - Account status (active/inactive)
- `created_at` (TIMESTAMPTZ)
- `updated_at` (TIMESTAMPTZ)

### 2. `user_xp_balance`
**Purpose:** Current XP balance for each user
- `user_id` (UUID) - User ID
- `xp` (INTEGER) - Current XP balance

### 3. `xp_ledger`
**Purpose:** Complete history of all XP transactions
- `id` (UUID)
- `user_id` (UUID)
- `source` (TEXT) - Source of XP (lesson_completion, daily_login, ad_reward, quiz_completion, etc.)
- `xp_delta` (INTEGER) - Amount of XP (positive for earned, negative for spent)
- `metadata` (JSONB) - Additional metadata (lesson_id, completion_id, etc.)
- `created_at` (TIMESTAMPTZ)

### 4. `lesson_progress`
**Purpose:** Track user progress through lessons
- `id` (UUID)
- `user_id` (UUID)
- `lesson_id` (TEXT/UUID) - Can be UUID or mobile app lesson ID
- `progress_percent` (INTEGER) - 0-100
- `time_spent_seconds` (INTEGER)
- `is_completed` (BOOLEAN)
- `completed_at` (TIMESTAMPTZ)
- `metadata` (JSONB) - Additional data (is_mobile_app_lesson, etc.)
- `created_at` (TIMESTAMPTZ)
- `updated_at` (TIMESTAMPTZ)

### 5. `user_stats` ⭐ NEW
**Purpose:** User statistics and learning metrics
- `id` (UUID)
- `user_id` (UUID) - Unique per user
- `learning_streak` (INTEGER) - Current consecutive days streak
- `last_streak_date` (DATE) - Last date streak was updated
- `last_daily_login_date` (DATE) - Last daily login date
- `total_lessons_completed` (INTEGER) - Total lessons completed
- `total_quizzes_completed` (INTEGER) - Total quizzes completed
- `total_ad_views` (INTEGER) - Total ads watched
- `longest_streak` (INTEGER) - Longest streak achieved
- `created_at` (TIMESTAMPTZ)
- `updated_at` (TIMESTAMPTZ)

### 6. `daily_logins` ⭐ NEW
**Purpose:** Track daily login history
- `id` (UUID)
- `user_id` (UUID)
- `login_date` (DATE) - Date of login (YYYY-MM-DD)
- `xp_awarded` (INTEGER) - XP awarded for this login
- `ad_watched` (BOOLEAN) - Whether ad was watched
- `created_at` (TIMESTAMPTZ)
- **Unique constraint:** (user_id, login_date)

### 7. `quiz_submissions` ⭐ NEW
**Purpose:** Track quiz completions
- `id` (UUID)
- `user_id` (UUID)
- `lesson_id` (TEXT) - Can be UUID or mobile app lesson ID
- `quiz_id` (TEXT) - Optional quiz identifier
- `answers` (INTEGER[]) - Array of selected answer indices
- `correct_answers` (INTEGER) - Number of correct answers
- `total_questions` (INTEGER) - Total questions in quiz
- `score_percent` (INTEGER) - Score percentage (0-100)
- `time_spent_seconds` (INTEGER)
- `xp_awarded` (INTEGER)
- `passed` (BOOLEAN)
- `metadata` (JSONB)
- `submitted_at` (TIMESTAMPTZ)
- `created_at` (TIMESTAMPTZ)

### 8. `achievements` ⭐ NEW
**Purpose:** Track user achievements/badges
- `id` (UUID)
- `user_id` (UUID)
- `achievement_type` (TEXT) - Type of achievement (first_lesson, quiz_master, streak_7, etc.)
- `achievement_name` (TEXT) - Display name
- `unlocked_at` (TIMESTAMPTZ) - When achievement was unlocked
- `xp_reward` (INTEGER) - XP reward for achievement
- `metadata` (JSONB) - Additional data
- **Unique constraint:** (user_id, achievement_type)

### 9. `lessons` (Backend lessons - optional)
**Purpose:** Backend-managed lessons (mobile app has local lessons)
- `id` (UUID)
- `title` (TEXT)
- `description` (TEXT)
- `category` (TEXT)
- `content` (TEXT)
- `xp_reward` (INTEGER)
- `duration_minutes` (INTEGER)
- `published_at` (TIMESTAMPTZ)
- `created_at` (TIMESTAMPTZ)
- `updated_at` (TIMESTAMPTZ)

### 10. `devices`
**Purpose:** Device registration and tracking
- `id` (UUID)
- `user_id` (UUID)
- `device_fingerprint` (TEXT)
- `device_name` (TEXT)
- `platform` (TEXT)
- `os_version` (TEXT)
- `app_version` (TEXT)
- `is_emulator` (BOOLEAN)
- `is_rooted` (BOOLEAN)
- `is_debug` (BOOLEAN)
- `created_at` (TIMESTAMPTZ)
- `updated_at` (TIMESTAMPTZ)

### 11. `referrals` & `referral_codes`
**Purpose:** Referral system tracking
- Referrer/referred relationships
- Referral codes
- Referral status and rewards

### 12. `withdrawals`
**Purpose:** Track withdrawal requests
- User withdrawals
- XP to currency conversion
- Payout status

## Backend API Endpoints

### User Profile & Stats
- `GET /me` - Get user profile, XP balance, referral code, and stats
- `PUT /me` - Update user email
- `GET /user-stats` - Get detailed user statistics
- `PUT /user-stats` - Update user statistics

### XP Management
- `POST /xp-credit` - Credit XP (idempotent, batched)
- `GET /xp-history` - Get XP transaction history

### Lessons
- `GET /lessons` - Get available lessons
- `POST /lessons-progress` - Update lesson progress
- `POST /lessons-complete` - Complete lesson (awards XP, idempotent)
  - Accepts `xp_reward` for mobile app local lessons

### Daily Login
- `POST /daily-login` ⭐ NEW - Record daily login (idempotent)
  - Updates learning streak automatically
  - Awards XP via ledger
  - Tracks ad watched status

### Quizzes
- `POST /quiz-submit` ✅ - Submit quiz results (idempotent)
  - Tracks answers, scores, time spent
  - Awards XP if passed (70%+)
  - Updates total quizzes completed count

### Achievements
- `GET /achievements` ✅ - Get user achievements
- `POST /achievements` ✅ - Unlock achievement
  - Auto-checked on lesson completion, quiz completion, ad view, daily login
  - Awards XP when unlocked

## Mobile App Data Sync

### On App Launch
1. ✅ Load user profile (`/me`)
2. ✅ Load XP balance (`/me`)
3. ✅ Load learning streak (`/me` stats)
4. ✅ Load daily login date (`/me` stats)
5. ✅ Load lessons (from backend or local)
6. ✅ Load XP history (`/xp-history`)
7. ✅ Load achievements (can be added)

### When User Completes Lesson
1. ✅ Update lesson progress (`/lessons-progress`)
2. ✅ Complete lesson (`/lessons-complete`)
3. ✅ Award XP (via `/lessons-complete`)
4. ✅ Update total lessons completed (`/user-stats`)

### When User Claims Daily Login
1. ✅ Record daily login (`/daily-login`)
2. ✅ Update learning streak (automatic via `/daily-login`)
3. ✅ Award XP (via `/daily-login`)
4. ✅ Update last daily login date (automatic)

### When User Watches Ad
1. ✅ Credit XP (`/xp-credit`)
2. ✅ Update ad views count (`/user-stats`)

### When Learning Streak Updates
1. ✅ Update learning streak (`/user-stats`)
2. ✅ Update longest streak (automatic if current > longest)

## Achievement Types Tracked

Based on mobile app achievements:
1. **First Steps** - Complete first lesson
2. **Quiz Master** - Complete 5 quizzes
3. **Ad Watcher** - Watch 10 ads
4. **Coin Collector** - Earn 1000 XP
5. **Learning Streak** - Learn for 7 days in a row
6. **Lesson Expert** - Complete 10 lessons
7. **Quiz Champion** - Complete 20 quizzes
8. **Ad Enthusiast** - Watch 50 ads

## Statistics Computed

### From `user_stats`:
- Learning streak (current)
- Longest streak (all-time)
- Total lessons completed
- Total quizzes completed
- Total ad views
- Last daily login date

### From `xp_ledger`:
- Total XP earned (sum of positive xp_delta)
- Total XP spent (sum of negative xp_delta)
- XP by source (lesson_completion, daily_login, ad_reward, etc.)
- XP over time (for charts/graphs)

### From `lesson_progress`:
- Lessons completed count
- Average time spent per lesson
- Completion rate
- Progress percentage per lesson

### From `daily_logins`:
- Daily login streak
- Login frequency
- Total days logged in

### From `quiz_submissions`:
- Quiz completion count
- Average quiz score
- Quiz pass rate
- Time spent on quizzes

## Mobile App Local Data (Synced to Backend)

### Currently Synced:
- ✅ XP balance
- ✅ XP transactions (ledger)
- ✅ Lesson completion status
- ✅ Lesson progress
- ✅ Learning streak
- ✅ Daily login date
- ✅ Total lessons completed
- ✅ Total ad views

### Now Synced:
- ✅ Quiz submissions (answers, scores, time spent)
- ✅ Achievement unlocks (auto-checked and unlocked)
- ✅ Total quizzes completed count

### Can Be Synced (Future):
- Device information updates
- Daily reset history

## Notes

1. **Mobile App Lessons:** The app stores lessons locally. When completing a lesson, the app sends `xp_reward` to the backend so XP can be awarded even if the lesson doesn't exist in the backend database.

2. **Idempotency:** Critical endpoints (`/lessons-complete`, `/daily-login`, `/xp-credit`) use idempotency keys to prevent duplicate processing.

3. **RLS Policies:** All tables have Row Level Security enabled, ensuring users can only access their own data.

4. **Auto-creation:** User stats are automatically created when a user is created via trigger.

5. **Streak Calculation:** Learning streak is automatically calculated and updated by the `/daily-login` endpoint.

## Deployment Checklist

To deploy the new tracking features:

1. ✅ Database migration applied (`add_user_stats_and_tracking`)
2. ✅ Database migration applied (`add_daily_reset_tracking`)
3. ✅ Deploy `/user-stats` Edge Function
4. ✅ Deploy `/daily-login` Edge Function
5. ✅ Deploy `/quiz-submit` Edge Function
6. ✅ Deploy `/achievements` Edge Function
7. ✅ Update `/me` endpoint (includes stats)
8. ✅ Update mobile app API service
9. ✅ Update mobile app provider (syncs stats)
10. ✅ Add achievement auto-unlock logic

## Testing

After deployment, verify:
- [ ] User stats are created on user creation
- [ ] Daily login updates streak correctly
- [ ] Lesson completion increments lesson count
- [ ] Ad views are tracked
- [ ] Stats sync from backend to mobile app
- [ ] Stats sync from mobile app to backend

