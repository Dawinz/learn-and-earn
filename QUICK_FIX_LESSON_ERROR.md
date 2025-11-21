# Quick Fix: "Lesson not found" Error

## Problem
You're getting `"Lesson not found"` error when completing lessons because the backend function hasn't been deployed with the updated code that handles mobile app local lessons.

## Solution: Deploy the Updated Backend Function

The code is already updated in your files. You just need to deploy it.

### Option 1: Install Supabase CLI and Deploy (Recommended)

```bash
# Install Supabase CLI
brew install supabase/tap/supabase
# OR if you have npm:
npm install -g supabase

# Login to Supabase
supabase login

# Navigate to web portal directory
cd "/Users/abdulazizgossage/MY PROJECTS DAWSON/LEARN AND GROW WEB PORTAL"

# Link to your project
supabase link --project-ref iscqpvwtikwqquvxlpsr

# Deploy the updated function
supabase functions deploy lessons-complete --project-ref iscqpvwtikwqquvxlpsr
```

### Option 2: Deploy via Supabase Dashboard

1. Go to: https://supabase.com/dashboard/project/iscqpvwtikwqquvxlpsr/functions
2. Click on `lessons-complete` function
3. Click "Edit" or "Update"
4. Copy the entire contents from: `/Users/abdulazizgossage/MY PROJECTS DAWSON/LEARN AND GROW WEB PORTAL/supabase/functions/lessons-complete/index.ts`
5. Paste it into the editor
6. Click "Deploy" or "Save"

### What the Updated Code Does

The updated `lessons-complete` function now:
- ✅ Accepts `xp_reward` parameter from mobile app
- ✅ Handles mobile app local lessons (lessons not in database)
- ✅ Awards XP even if lesson doesn't exist in backend database
- ✅ Uses the `xp_reward` sent by mobile app (from `coinReward`)

### Verify It Works

After deployment:
1. Complete a lesson in the mobile app
2. You should see:
   - ✅ Lesson completes successfully
   - ✅ XP is awarded (check your balance)
   - ✅ No "Lesson not found" error
   - ✅ Success message shows correct coin amount

### Current Status

- ✅ Mobile app code: **UPDATED** - Sends `xp_reward` correctly
- ✅ Backend code: **UPDATED** - Handles mobile app lessons
- ⏳ Backend deployment: **PENDING** - Needs to be deployed

Once deployed, the error will be resolved!

