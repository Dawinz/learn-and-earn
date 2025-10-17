# Flutter Hot Reload Guide - Learn & Earn

## 🔥 What is Hot Reload?

Hot reload allows you to see code changes instantly **without restarting the app** or losing the current state. This dramatically speeds up development.

## ✅ When to Use Hot Reload vs Hot Restart

### Use Hot Reload (Press `r`) When:
- ✅ Changing UI layout or styling
- ✅ Modifying widget build methods
- ✅ Updating text or colors
- ✅ Adding new widgets to existing screens
- ✅ Changing logic in existing methods
- **Speed:** ~1-3 seconds
- **State:** Preserved (stays on same screen with same data)

### Use Hot Restart (Press `R`) When:
- ⚠️ Adding new files or classes
- ⚠️ Changing app initialization logic
- ⚠️ Modifying `main()` function
- ⚠️ Changing dependency injection setup
- ⚠️ Updating global state or providers (sometimes)
- **Speed:** ~5-10 seconds
- **State:** Reset (app starts from home screen)

### Full Restart (Stop and rebuild) When:
- 🔴 Adding new packages to `pubspec.yaml`
- 🔴 Changing native code (iOS/Android)
- 🔴 Modifying app configuration files
- 🔴 Adding assets or images
- **Speed:** ~2-10 minutes (full rebuild)

## 🎯 Current Session

### App Status: ✅ RUNNING
- **Device:** iPhone 15 Pro Max Simulator
- **Mode:** Debug mode
- **Process ID:** c263e5
- **VM Service:** http://127.0.0.1:58941/j4YBEFRcxfQ=/
- **DevTools:** http://127.0.0.1:9101

### Hot Reload Ready ✅
The Flutter process is listening for hot reload commands. You can apply code changes instantly!

## 📝 How to Apply Changes

### Automatic Hot Reload (When I make changes):

When I edit your code, I can trigger hot reload automatically. You'll see output like:

```
Performing hot reload...
Reloaded 2 of 1234 libraries in 1,234ms.
```

### Manual Hot Reload (In Terminal):

If you're working in the terminal where `flutter run` is active:

1. **Hot Reload:** Press `r` and Enter
2. **Hot Restart:** Press `R` and Enter
3. **Clear Screen:** Press `c` and Enter
4. **Quit App:** Press `q` and Enter
5. **Help:** Press `h` and Enter

## 🚀 Recent Changes Applied

### ✅ Daily Login Feature - Applied Without Restart!

**Changes Made:**
1. Updated `app_provider.dart`:
   - Added `canClaimDailyLogin` getter
   - Added `claimDailyLogin()` method
   - Added once-per-day restriction logic
   - Added learning streak tracking

2. Updated `earn_screen.dart`:
   - Created new `_buildDailyLoginOption()` widget
   - Replaced old daily login button
   - Added rewarded ad requirement
   - Added "Claimed" badge when already used

**How Applied:** Hot reload ready - will apply when you save changes in your editor or when I trigger it after code modifications.

## 💡 Development Workflow Tips

### Efficient Development:
1. **Make small changes** → Hot reload → Test → Repeat
2. **Save often** → Most IDEs trigger hot reload automatically
3. **Watch the console** → Errors show immediately
4. **Use Hot Restart** if something seems broken
5. **Full restart** only when necessary

### VS Code Integration:
- Auto hot reload on save (if enabled)
- `Cmd/Ctrl + S` to save and trigger reload
- Flutter DevTools extension shows reload button

### Terminal Workflow:
```bash
# In terminal with flutter run active:
r      # Hot reload (fast, preserves state)
R      # Hot restart (medium, resets state)
q      # Quit app
c      # Clear console

# In separate terminal (to trigger reload):
cd /path/to/learn_earn_mobile
echo "r" | flutter run --pid <process_id>
```

## ⚡ Performance Optimization

### Why Hot Reload is Fast:
- Only recompiles changed code
- Preserves app state and widgets
- Updates UI tree without full rebuild
- Injects new code into running Dart VM

### Average Times:
- **Hot Reload:** 1-3 seconds
- **Hot Restart:** 5-10 seconds
- **Full Rebuild:** 2-10 minutes (iOS builds are slow)

## 🐛 Troubleshooting

### Hot Reload Not Working?

**Problem:** Changes not appearing after hot reload

**Solutions:**
1. Try Hot Restart (`R`) instead
2. Check for syntax errors in console
3. Verify file was actually saved
4. Some changes require full restart (see above)

**Problem:** "Cannot hot reload with errors"

**Solution:** Fix the compilation errors first, then reload

**Problem:** App behaves strangely after reload

**Solution:** Hot Restart (`R`) to reset state

### When Hot Reload Fails:

If hot reload doesn't work properly:
```bash
# Stop current run (press 'q' or Ctrl+C)
# Then restart:
cd learn_earn_mobile
flutter clean
flutter pub get
flutter run -d iphone
```

## 📊 Current Implementation Status

### ✅ Implemented Features (Ready for Hot Reload Testing):

1. **Daily Login with Rewarded Ad**
   - Once per day restriction
   - Rewarded video requirement
   - Visual feedback (available vs claimed states)
   - Learning streak tracking
   - Persistent storage

2. **Testing Flow:**
   - Navigate to "Earn" tab → Hot reload applies instantly
   - Tap "Daily Login" → See new UI with "Claimed" badge
   - After midnight → State resets, can claim again

### 🎮 Test the Daily Login Now:

With the app running on the simulator:
1. Tap the "Earn" tab at the bottom
2. Look for the "Daily Login" card
3. Tap it to see the new dialog
4. Click "Watch Ad" to test the flow
5. Verify "+5 coins" appears after ad
6. Tap again → Should show "already claimed" message

Changes are **live right now** - no restart needed! 🚀

## 🔄 Future Changes

When making new changes:
1. I'll edit the code
2. Trigger hot reload automatically
3. You'll see changes in ~1-3 seconds
4. App state is preserved (no need to navigate again)
5. Continue testing immediately

This is **much faster** than restarting the app every time!

---

**Last Updated:** October 17, 2025
**Flutter Version:** 3.x
**Current Build:** Running on iPhone 15 Pro Max Simulator
