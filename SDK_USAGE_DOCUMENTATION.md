# SDK Usage Documentation - Learn & Grow Mobile App

## Primary SDKs Used

### 1. **Supabase Flutter SDK** (`supabase_flutter: ^2.5.6`)
**Purpose:** Backend-as-a-Service (BaaS) for authentication and database
**Why:**
- **Device-based authentication:** Enables anonymous/device-based user authentication without requiring email/password
- **Email OTP verification:** Powers email linking functionality via Supabase Auth's built-in OTP system
- **Session management:** Handles secure token storage and session management
- **Real-time capabilities:** Provides foundation for future real-time features
- **Alternative to Firebase:** Chosen for better pricing, PostgreSQL database, and Edge Functions support

**Usage:**
- User authentication (device-based and email linking)
- Session token management
- Email OTP sending and verification

---

### 2. **Google Mobile Ads SDK** (`google_mobile_ads: ^5.2.0`)
**Purpose:** Monetization through advertising
**Why:**
- **Primary revenue source:** AdMob revenue funds user payouts (core business model)
- **Rewarded ads:** Users earn XP by watching ads
- **Banner ads:** Display ads throughout the app
- **Interstitial ads:** Show ads between screens
- **Industry standard:** Google AdMob is the most widely used mobile ad platform

**Usage:**
- Rewarded video ads (users earn 15 XP per ad)
- Banner ads on various screens
- Interstitial ads after lesson completion
- Ad bonuses for navigation, profile, quiz screens

---

### 3. **Provider** (`provider: ^6.1.2`)
**Purpose:** State management
**Why:**
- **Flutter best practice:** Recommended state management solution by Flutter team
- **Simple and lightweight:** Easy to use, minimal boilerplate
- **Reactive updates:** Automatically rebuilds UI when state changes
- **Separation of concerns:** Keeps business logic separate from UI

**Usage:**
- Managing app-wide state (XP, lessons, user data)
- Sharing state across screens
- Handling user authentication state

---

### 4. **HTTP** (`http: ^1.1.0`)
**Purpose:** REST API communication
**Why:**
- **Backend API calls:** Communicates with custom Supabase Edge Functions backend
- **Lightweight:** Simple HTTP client without heavy dependencies
- **Standard protocol:** Uses standard HTTP methods (GET, POST, PUT, DELETE)
- **Custom endpoints:** Needed for custom backend logic beyond Supabase Auth

**Usage:**
- Lesson completion tracking
- Quiz submission
- User stats synchronization
- XP ledger updates
- Achievement unlocking
- Daily login tracking

---

## Supporting SDKs/Libraries

### 5. **Shared Preferences** (`shared_preferences: ^2.2.2`)
**Purpose:** Local data persistence
**Why:**
- **Offline support:** Stores user data locally for offline access
- **Session persistence:** Saves authentication tokens and user preferences
- **Simple key-value storage:** Easy to use for storing app settings and user data

**Usage:**
- Storing user session tokens
- Saving lesson progress locally
- Storing app preferences
- Caching user data

---

### 6. **Flutter Local Notifications** (`flutter_local_notifications: ^18.0.1`)
**Purpose:** Push notifications
**Why:**
- **User engagement:** Reminds users to complete daily lessons and claim bonuses
- **Local notifications:** Works without internet connection
- **Scheduled notifications:** Can schedule notifications for specific times

**Usage:**
- Daily login reminders
- Lesson completion notifications
- Streak reminders
- Achievement unlock notifications

---

### 7. **Permission Handler** (`permission_handler: ^11.3.1`)
**Purpose:** Device permissions management
**Why:**
- **Notification permissions:** Required to show push notifications
- **Platform-specific:** Handles iOS and Android permission requests differently
- **User experience:** Properly requests permissions with explanations

**Usage:**
- Requesting notification permissions
- Handling permission status
- Showing permission rationale

---

### 8. **Connectivity Plus** (`connectivity_plus: ^6.0.5`)
**Purpose:** Network connectivity monitoring
**Why:**
- **Offline mode:** Detects when user is offline to show appropriate UI
- **Sync management:** Determines when to sync data with backend
- **User feedback:** Shows connection status to users

**Usage:**
- Detecting online/offline status
- Enabling/disabling backend sync
- Showing connection warnings

---

### 9. **Package Info Plus** (`package_info_plus: ^8.0.0`)
**Purpose:** App version information
**Why:**
- **Version checking:** Enables force update functionality
- **Maintenance mode:** Can check if app is in maintenance mode
- **Update enforcement:** Ensures users are on required app version

**Usage:**
- Getting current app version
- Comparing with backend version requirements
- Enforcing app updates

---

### 10. **URL Launcher** (`url_launcher: ^6.2.5`)
**Purpose:** Opening external URLs
**Why:**
- **Help & support:** Opens help documentation and support links
- **Terms & privacy:** Opens terms of service and privacy policy
- **External resources:** Links to external learning resources

**Usage:**
- Opening help documentation
- Linking to terms of service
- Opening support URLs

---

### 11. **Flutter Markdown** (`flutter_markdown: ^0.7.4+1`)
**Purpose:** Markdown content rendering
**Why:**
- **Lesson content:** Renders lesson content written in Markdown
- **Rich formatting:** Supports headers, lists, links, and code blocks
- **Content flexibility:** Allows easy content updates without app updates

**Usage:**
- Rendering lesson content
- Displaying help documentation
- Showing formatted text content

---

### 12. **Crypto** (`crypto: ^3.0.5`)
**Purpose:** Cryptographic functions
**Why:**
- **Security:** Used for generating secure tokens and hashes
- **Idempotency keys:** Generates unique keys for API calls to prevent duplicates
- **Data integrity:** Ensures secure communication with backend

**Usage:**
- Generating idempotency keys for API calls
- Creating secure tokens
- Hashing sensitive data

---

### 13. **UUID** (`uuid: ^4.5.1`)
**Purpose:** Unique identifier generation
**Why:**
- **Unique IDs:** Generates unique identifiers for transactions and records
- **Data tracking:** Creates unique IDs for lessons, quizzes, and achievements
- **Backend compatibility:** Ensures unique identifiers match backend expectations

**Usage:**
- Generating transaction IDs
- Creating unique lesson/quiz identifiers
- Generating user session IDs

---

### 14. **Timezone** (`timezone: ^0.9.2`)
**Purpose:** Timezone handling
**Why:**
- **Scheduled notifications:** Ensures notifications fire at correct local time
- **Daily reset:** Handles daily reset logic across timezones
- **Streak calculation:** Accurately calculates learning streaks across timezones

**Usage:**
- Scheduling local notifications
- Daily reset timing
- Streak date calculations

---

### 15. **Percent Indicator** (`percent_indicator: ^4.2.3`)
**Purpose:** Progress visualization
**Why:**
- **User feedback:** Shows visual progress indicators for lessons and quizzes
- **Engagement:** Visual progress bars increase user engagement
- **Clear communication:** Makes progress easy to understand

**Usage:**
- Lesson progress bars
- Quiz completion indicators
- Achievement progress displays

---

## Previously Used (Now Disabled)

### Firebase Core & Messaging (Commented Out)
**Why Disabled:**
- **Replaced by Supabase:** Switched to Supabase for backend services
- **Cost optimization:** Supabase offers better pricing for our use case
- **Simplified stack:** Reduced number of SDKs and dependencies
- **Local notifications:** Using flutter_local_notifications instead for notifications

**Previous Usage:**
- Push notifications (now using local notifications)
- Backend services (now using Supabase)

---

## SDK Selection Rationale

### Why These SDKs?

1. **Minimal Dependencies:** Only essential SDKs to reduce app size and complexity
2. **Open Source:** Preference for open-source solutions where possible
3. **Active Maintenance:** All SDKs are actively maintained and updated
4. **Flutter Native:** Preference for Flutter/Dart packages over platform-specific SDKs
5. **Cost Effective:** Chosen solutions that fit within budget constraints
6. **Scalability:** SDKs that can scale with app growth
7. **Security:** SDKs with strong security practices and regular updates

---

## Summary

**Total Active SDKs:** 15 primary and supporting SDKs
**Core SDKs:** 4 (Supabase, Google Mobile Ads, Provider, HTTP)
**Supporting SDKs:** 11 (Storage, Notifications, Permissions, etc.)

All SDKs serve specific purposes in the app's functionality, from authentication and monetization to user experience and data management.

