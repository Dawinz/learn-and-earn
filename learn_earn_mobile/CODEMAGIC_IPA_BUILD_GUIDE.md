# Complete Guide: Building IPA with Codemagic (No Auto-Publishing)

This guide will walk you through building an IPA file using Codemagic WITHOUT automatically publishing to the App Store. You'll download the IPA and upload it manually when ready.

---

## Prerequisites Checklist

- [ ] Apple Developer Account ($99/year) - [Sign up here](https://developer.apple.com/programs/)
- [ ] GitHub account with your repository
- [ ] Codemagic account (free tier available) - [Sign up here](https://codemagic.io)
- [ ] Your code pushed to GitHub

---

## Part A: Set Up Apple Developer Account & API Key

### A1. Create App Store Connect API Key

1. **Go to App Store Connect**
   - Visit: https://appstoreconnect.apple.com/
   - Sign in with your Apple Developer account

2. **Navigate to Keys Section**
   - Click **Users and Access** in the top menu
   - Click the **Keys** tab
   - Click the **+** button (top left)

3. **Create New Key**
   - **Key Name**: `Codemagic CI/CD` (or any name you prefer)
   - **Access**: Select **App Manager** role
   - Click **Generate**

4. **Download and Save Credentials**
   - **IMPORTANT**: Download the `.p8` key file immediately (you can only download it once!)
   - **Save these details** (you'll need them):
     - **Key ID**: (e.g., `ABC123DEFG`) - shown on the page
     - **Issuer ID**: (e.g., `12345678-1234-1234-1234-123456789012`) - shown at top of Keys page
     - **Auth Key File**: The `.p8` file you just downloaded

5. **Store Securely**
   - Keep the `.p8` file safe - you'll upload it to Codemagic
   - Note the Key ID and Issuer ID - you'll need them in Codemagic

---

## Part B: Set Up Codemagic Account & Connect Repository

### B1. Create Codemagic Account

1. **Sign Up**
   - Go to: https://codemagic.io
   - Click **Sign up** (top right)
   - Choose **Sign up with GitHub** (recommended) or email

2. **Complete Registration**
   - Follow the sign-up process
   - Verify your email if required

### B2. Connect Your GitHub Repository

1. **Add Application**
   - In Codemagic dashboard, click **Add application** (or **+** button)
   - Select **GitHub** (or your Git provider)

2. **Authorize Codemagic** (if first time)
   - Click **Authorize Codemagic** to access your GitHub
   - Select repositories: Choose **Only select repositories**
   - Select: `Dawinz/learn-and-earn`
   - Click **Install & Authorize**

3. **Select Repository**
   - Find and select: `learn-and-earn`
   - Click **Next**

4. **Configure Project Type**
   - **Project type**: Select **Flutter**
   - Codemagic will auto-detect `codemagic.yaml`
   - Click **Finish**

---

## Part C: Configure App Store Connect Integration

### C1. Add Apple Developer Portal Integration

1. **Navigate to Team Settings**
   - In Codemagic, click your **profile/team name** (top right)
   - Click **Team integrations** (or go to Teams → Your Team → Team integrations)

2. **Connect Apple Developer Portal**
   - Find **Apple Developer Portal** section
   - Click **Connect** button

3. **Enter API Key Details**
   - **Issuer ID**: Paste your Issuer ID (from Part A1, step 4)
   - **Key ID**: Paste your Key ID (from Part A1, step 4)
   - **Auth key file**: Click **Choose file** and upload your `.p8` file
   - Click **Save**

4. **Verify Connection**
   - You should see a green checkmark or "Connected" status
   - If there's an error, double-check your credentials

---

## Part D: Configure Code Signing

### D1. Set Up Automatic Code Signing

1. **Go to App Settings**
   - In Codemagic dashboard, click on your app (`learn-and-earn`)
   - Click **Settings** (gear icon) or go to **Distribution** tab

2. **Configure iOS Code Signing**
   - Navigate to **Distribution** → **iOS code signing**
   - Select **Automatic** code signing
   - **Bundle identifier**: `com.qwantumtech.learnandgrow`
   - **App Store Connect API key**: Select the one you just created
   - Click **Save**

3. **Codemagic Will Handle**
   - Certificates (Apple Distribution Certificate)
   - Provisioning profiles (App Store profile)
   - All automatically managed!

---

## Part E: Update Email in Configuration

### E1. Update codemagic.yaml Email

1. **Edit codemagic.yaml**
   - In Codemagic, go to your app
   - Click **codemagic.yaml** tab (or go to Settings → codemagic.yaml)
   - Click **Edit** button

2. **Update Email Address**
   - Find line 39: `recipients:`
   - Replace `your-email@example.com` with your actual email
   - Example:
     ```yaml
     recipients:
       - yourname@example.com
     ```

3. **Save Changes**
   - Click **Save** or **Commit changes**
   - Changes will be committed to your repository

---

## Part F: Create App in App Store Connect (Required for Code Signing)

### F1. Create New App

1. **Go to App Store Connect**
   - Visit: https://appstoreconnect.apple.com/
   - Click **My Apps** → **+** → **New App**

2. **Fill App Information**
   - **Platform**: Select **iOS**
   - **Name**: `Learn & Grow`
   - **Primary Language**: English (or your preferred language)
   - **Bundle ID**: Select `com.qwantumtech.learnandgrow` (must match exactly)
   - **SKU**: `learn-and-grow-ios` (any unique identifier)
   - **User Access**: Full Access

3. **Create App**
   - Click **Create**
   - You'll see a message that the app was created
   - **Note**: You don't need to complete all App Store Connect sections yet - just creating the app is enough for code signing

---

## Part G: Build Your IPA

### G1. Start a Build

1. **Go to Your App in Codemagic**
   - In Codemagic dashboard, click on your app

2. **Start New Build**
   - Click **Start new build** button (top right)
   - Or click **Builds** tab → **Start new build**

3. **Configure Build**
   - **Branch**: Select `main` (or your main branch)
   - **Workflow**: Select `ios-workflow`
   - **Build configuration**: Leave as default (uses codemagic.yaml)

4. **Start Build**
   - Click **Start new build** button
   - Build will start immediately

### G2. Monitor Build Progress

1. **Watch Build Logs**
   - You'll see real-time build logs
   - Build typically takes **10-15 minutes**
   - You'll see steps:
     - Installing dependencies
     - Installing CocoaPods
     - Setting up code signing
     - Building IPA

2. **Build Status**
   - **Green checkmark** = Build successful ✅
   - **Red X** = Build failed ❌
   - If failed, check logs for errors

---

## Part H: Download Your IPA File

### H1. Access Build Artifacts

1. **Go to Completed Build**
   - Once build completes successfully, click on the build
   - Or go to **Builds** tab → Click on completed build

2. **Download IPA**
   - Scroll down to **Artifacts** section
   - You'll see: `app-release.ipa` (or similar)
   - Click **Download** button next to the IPA file
   - File will download to your computer

3. **Verify Download**
   - Check your Downloads folder
   - File should be named: `app-release.ipa`
   - Size: Approximately **40-50 MB**

---

## Part I: Upload IPA to App Store Connect (Manual)

### I1. Using Transporter App (Recommended)

1. **Download Transporter**
   - Go to Mac App Store
   - Search for **Transporter**
   - Install (free app by Apple)

2. **Open Transporter**
   - Launch Transporter app
   - Sign in with your Apple Developer account

3. **Upload IPA**
   - Drag and drop your `app-release.ipa` file into Transporter
   - Or click **+** button and select the IPA file
   - Click **Deliver** button
   - Wait for upload to complete (5-10 minutes)

4. **Verify Upload**
   - Go to App Store Connect → **My Apps** → **Learn & Grow**
   - Click **TestFlight** tab (or **App Store** tab)
   - Your build should appear in **Builds** section
   - Status will show "Processing" → "Ready to Submit"

### I2. Alternative: Using Xcode Organizer

1. **Open Xcode**
   - Launch Xcode on your Mac

2. **Open Organizer**
   - Go to **Window** → **Organizer**
   - Or press `Cmd + Shift + 9`

3. **Import IPA**
   - Click **+** button (bottom left)
   - Select **Import** → Choose your IPA file
   - Xcode will validate and import

4. **Upload to App Store Connect**
   - Right-click on the imported archive
   - Select **Distribute App**
   - Choose **App Store Connect**
   - Follow the wizard to upload

---

## Part J: Troubleshooting Common Issues

### J1. Build Fails - Code Signing Error

**Problem**: "No valid code signing certificates found"

**Solution**:
- Ensure App Store Connect API key is properly configured
- Check that Bundle ID matches: `com.qwantumtech.learnandgrow`
- Verify automatic code signing is enabled
- Make sure app exists in App Store Connect

### J2. Build Fails - CocoaPods Error

**Problem**: Pod install fails

**Solution**:
- This is usually handled automatically by Codemagic
- If it fails, check that `Podfile` is correct
- Try running `pod install` locally to test

### J3. IPA Not Available for Download

**Problem**: Can't find IPA in artifacts

**Solution**:
- Ensure build completed successfully (green checkmark)
- Check **Artifacts** section at bottom of build page
- Look for files with `.ipa` extension
- If not there, check build logs for errors

### J4. Upload Fails - Invalid Bundle

**Problem**: Transporter says bundle is invalid

**Solution**:
- Ensure IPA was built for App Store distribution (not Ad Hoc)
- Check that Bundle ID matches App Store Connect app
- Verify code signing was successful (check build logs)

---

## Part K: Quick Reference Checklist

Use this checklist to ensure everything is set up:

- [ ] Apple Developer account created
- [ ] App Store Connect API key created and downloaded
- [ ] Codemagic account created
- [ ] GitHub repository connected to Codemagic
- [ ] Apple Developer Portal integrated in Codemagic
- [ ] Code signing configured (automatic)
- [ ] Email updated in codemagic.yaml
- [ ] App created in App Store Connect
- [ ] First build started
- [ ] Build completed successfully
- [ ] IPA downloaded
- [ ] IPA uploaded to App Store Connect (manual)

---

## Summary

**What Codemagic Does:**
- ✅ Builds your iOS app
- ✅ Handles code signing automatically
- ✅ Creates IPA file
- ✅ Makes IPA available for download
- ❌ Does NOT upload to App Store (disabled)

**What You Do:**
- ✅ Set up accounts and integrations
- ✅ Trigger builds
- ✅ Download IPA file
- ✅ Upload IPA manually to App Store Connect

---

## Next Steps After Getting IPA

1. **TestFlight Testing** (Optional)
   - Upload IPA to App Store Connect
   - Add testers in TestFlight
   - Test before App Store submission

2. **App Store Submission** (When Ready)
   - Complete App Store Connect listing
   - Add screenshots, description, privacy policy
   - Submit for Apple review

---

## Support Resources

- **Codemagic Docs**: https://docs.codemagic.io
- **App Store Connect**: https://appstoreconnect.apple.com
- **Apple Developer**: https://developer.apple.com

---

**Your codemagic.yaml is already configured to build IPA without auto-publishing!**

Just follow the steps above to set up Codemagic and start building. 🚀

