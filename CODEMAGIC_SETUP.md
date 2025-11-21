# Codemagic iOS Deployment Setup Guide

This guide will help you set up Codemagic for automated iOS App Store deployment.

## Prerequisites

1. **Apple Developer Account** ($99/year)
   - Active Apple Developer Program membership
   - Access to App Store Connect

2. **Codemagic Account**
   - Sign up at https://codemagic.io
   - Free tier available with limited build minutes

## Step 1: Create App Store Connect API Key

1. Go to [App Store Connect](https://appstoreconnect.apple.com/)
2. Navigate to **Users and Access** → **Keys** tab
3. Click the **+** button to create a new key
4. Provide a name (e.g., "Codemagic CI/CD")
5. Select **App Manager** role
6. Click **Generate**
7. **Download the `.p8` key file** (you can only download it once!)
8. Note the **Key ID** and **Issuer ID** displayed on the page

## Step 2: Configure Codemagic

### 2.1 Connect Your Repository

1. Log in to [Codemagic](https://codemagic.io)
2. Click **Add application**
3. Connect your Git repository (GitHub, GitLab, Bitbucket, etc.)
4. Select the repository: `learn_earn_mobile`
5. Select **Flutter** as the project type

### 2.2 Set Up App Store Connect Integration

1. In Codemagic, go to **Teams** → **Your Team** → **Team integrations**
2. Click **Connect** next to **Apple Developer Portal**
3. Enter the following:
   - **Issuer ID**: (from Step 1)
   - **Key ID**: (from Step 1)
   - **Auth key file**: Upload the `.p8` file downloaded in Step 1
4. Click **Save**

### 2.3 Configure Code Signing

1. In your app settings on Codemagic, go to **Distribution** → **iOS code signing**
2. Select **Automatic** code signing
3. Ensure the correct **App Store Connect API key** is selected
4. Codemagic will automatically manage certificates and provisioning profiles

### 2.4 Set Up Environment Variables (Optional)

If you need any environment variables, add them in:
- **Teams** → **Your Team** → **Environment variables**

## Step 3: Update codemagic.yaml

The `codemagic.yaml` file is already configured, but you may need to:

1. **Update email notification** (line 48):
   ```yaml
   recipients:
     - your-email@example.com  # Replace with your email
   ```

2. **Configure App Store submission** (lines 52-55):
   ```yaml
   submit_to_testflight: false  # Set to true to auto-submit to TestFlight
   submit_to_app_store: false    # Set to true to auto-submit to App Store
   ```

## Step 4: Create App in App Store Connect

1. Go to [App Store Connect](https://appstoreconnect.apple.com/)
2. Click **My Apps** → **+** → **New App**
3. Fill in:
   - **Platform**: iOS
   - **Name**: Learn & Grow
   - **Primary Language**: English
   - **Bundle ID**: `com.qwantumtech.learnandgrow`
   - **SKU**: `learn-and-grow-ios` (or any unique identifier)
   - **User Access**: Full Access
4. Click **Create**

## Step 5: Configure App Store Listing

Complete the following in App Store Connect:

1. **App Information**
   - Category: Education
   - Privacy Policy URL: (required for AdMob)
   - Support URL

2. **Pricing and Availability**
   - Price: Free
   - Availability: All countries (or select specific)

3. **App Privacy**
   - **Data Collection**: Yes (because of AdMob)
   - **Advertising Data**: Yes
   - **Device ID**: Yes
   - **Product Interaction**: Yes
   - **Other Diagnostic Data**: Yes

4. **App Store Listing**
   - Screenshots (required):
     - iPhone 6.7" (iPhone 14 Pro Max)
     - iPhone 6.5" (iPhone 11 Pro Max)
     - iPhone 5.5" (iPhone 8 Plus)
   - Description
   - Keywords
   - Support URL
   - Marketing URL (optional)

## Step 6: Trigger Your First Build

1. In Codemagic, go to your app
2. Click **Start new build**
3. Select:
   - **Branch**: `main` (or your main branch)
   - **Workflow**: `ios-workflow`
4. Click **Start new build**

## Step 7: Monitor Build and Upload

1. Watch the build progress in Codemagic
2. Once complete, the IPA will be automatically uploaded to App Store Connect
3. Go to App Store Connect → **TestFlight** or **App Store** to see your build

## Troubleshooting

### Build Fails with Code Signing Error
- Ensure App Store Connect API key is properly configured
- Check that Bundle ID matches: `com.qwantumtech.learnandgrow`
- Verify automatic code signing is enabled

### Build Succeeds but Upload Fails
- Check App Store Connect API key permissions
- Ensure the app exists in App Store Connect
- Verify Bundle ID matches exactly

### SKAdNetwork Warning
- The Info.plist now includes all required SKAdNetwork identifiers for AdMob
- This warning should be resolved

## Next Steps After First Build

1. **TestFlight Testing**:
   - Add internal/external testers
   - Test the app thoroughly

2. **App Store Submission**:
   - Complete all required App Store Connect sections
   - Submit for review
   - Wait for Apple's review (typically 24-48 hours)

## Automated Workflow

Once set up, Codemagic will:
- ✅ Build your app automatically on every push/PR
- ✅ Increment build numbers automatically
- ✅ Upload to App Store Connect
- ✅ Send email notifications on success/failure

## Support

- Codemagic Docs: https://docs.codemagic.io
- App Store Connect: https://appstoreconnect.apple.com
- Flutter iOS Deployment: https://docs.flutter.dev/deployment/ios

