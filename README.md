# Learn & Earn - Complete Learning Platform

A comprehensive learning platform that rewards users with real money for completing educational content. Built with Flutter (mobile), Node.js/Express (backend), and React (admin panel).

## 🎯 Project Overview

Learn & Earn teaches practical ways to earn online through AI, freelancing, content creation, and more. Users earn coins by completing lessons and quizzes, which can be converted to real USD payouts funded by AdMob revenue.

## 🏗️ Architecture

### Components
- **Mobile App (Flutter)**: Cross-platform mobile application
- **Backend API (Node.js/Express)**: RESTful API with MongoDB
- **Admin Panel (React)**: Web-based administration interface
- **Database (MongoDB)**: Data storage and management

### Key Features
- Device-based identity system (Ed25519 cryptography)
- Anti-abuse measures (emulator/root detection)
- Sustainable payout system (revenue-based budgeting)
- AdMob integration for monetization
- Comprehensive admin dashboard

## 📁 Project Structure

```
learn-earn/
├── learn-earn-mobile/          # Flutter mobile app
│   ├── lib/
│   │   ├── models/            # Data models
│   │   ├── services/          # API services
│   │   ├── screens/           # UI screens
│   │   ├── providers/         # State management
│   │   └── utils/             # Utility functions
│   └── pubspec.yaml
├── learn-earn-backend/         # Node.js API server
│   ├── src/
│   │   ├── models/            # MongoDB models
│   │   ├── routes/            # API routes
│   │   ├── controllers/       # Business logic
│   │   ├── middleware/        # Authentication & validation
│   │   ├── utils/             # Helper functions
│   │   └── scripts/           # Database seeding
│   └── package.json
├── learn-earn-admin/           # React admin panel
│   ├── src/
│   │   ├── pages/             # Admin pages
│   │   ├── components/        # Reusable components
│   │   └── App.tsx
│   └── package.json
└── README.md
```

## 🚀 Quick Start

### Prerequisites
- Node.js (v16+)
- MongoDB
- Flutter SDK
- Git

### Backend Setup

1. **Navigate to backend directory**
   ```bash
   cd learn-earn-backend
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Set up environment variables**
   ```bash
   cp env.example .env
   # Edit .env with your configuration
   ```

4. **Start MongoDB**
   ```bash
   # Make sure MongoDB is running on localhost:27017
   ```

5. **Seed the database**
   ```bash
   npm run build
   node dist/scripts/seed.js
   ```

6. **Start the server**
   ```bash
   npm run dev
   ```

The API will be available at `http://localhost:8080`

### Mobile App Setup

1. **Navigate to mobile directory**
   ```bash
   cd learn-earn-mobile
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Admin Panel Setup

1. **Navigate to admin directory**
   ```bash
   cd learn-earn-admin
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Start the development server**
   ```bash
   npm run dev
   ```

The admin panel will be available at `http://localhost:5173`

## 🔧 Configuration

### Backend Environment Variables

```env
PORT=8080
MONGO_URL=mongodb://localhost:27017/learn_earn
SESSION_SECRET=your_secret_here
APP_PEPPER=your_app_pepper_here
SAFETY_MARGIN=0.6
MIN_PAYOUT_USD=5
PAYOUT_COOLDOWN_HOURS=48
MAX_DAILY_EARN_USD=0.5
NUMBER_CHANGE_LOCK_DAYS=30
EMULATOR_PAYOUTS=false
ADMIN_EMAIL=admin@example.com
ADMIN_PASSWORD_HASH=your_bcrypt_hash
JWT_SECRET=your_jwt_secret
```

### Mobile App Configuration

Update the API base URL in `lib/services/api_service.dart`:
```dart
static const String baseUrl = 'http://your-backend-url/api';
```

## 📱 Mobile App Features

### Screens (S0-S20)
- **S0**: Splash/Boot screen
- **S1**: Welcome screen
- **S2**: Onboarding carousel
- **S3**: Device identity creation
- **S4**: Permissions setup
- **S5**: Home with tab navigation
- **S6**: Category & lesson list
- **S7**: Lesson reader with ads
- **S8**: Quiz system
- **S9**: Earn confirmation
- **S10**: Streak/daily bonus
- **S11**: Wallet overview
- **S12**: Mobile number setup
- **S13**: Payout request
- **S14**: Payout submitted
- **S15**: Payout history
- **S16**: Profile/settings
- **S17**: Help/FAQ
- **S18**: Offline mode
- **S19**: Integrity block
- **S20**: Update required

### Key Features
- Device identity generation (Ed25519)
- Emulator/root detection
- AdMob integration
- Offline lesson reading
- Secure payout system
- Multi-language support (EN/SW)

## 🖥️ Admin Panel Features

### Dashboard
- Daily budget overview
- Payout statistics
- Recent earnings
- System health monitoring

### Payout Management
- View all payout requests
- Approve/reject payouts
- Set transaction references
- Filter by status

### Lesson Management
- Create/edit lessons
- Publish/unpublish content
- Manage categories and tags
- Quiz management

### Settings
- Economic parameters
- Security settings
- AdMob configuration
- System preferences

## 🔐 Security Features

### Device Identity
- Ed25519 keypair generation
- Device ID derivation
- Signature verification
- Anti-replay protection

### Anti-Abuse Measures
- Emulator detection
- Root/jailbreak detection
- Daily earning caps
- Payout cooldowns
- Mobile number locking

### Data Protection
- No PII storage
- Encrypted communications
- Secure API endpoints
- Audit logging

## 💰 Economics Model

### Revenue Sources
- AdMob rewarded ads
- Mid-lesson ad placements
- Post-quiz ad rewards
- Daily bonus ads

### Payout System
- Revenue-based budgeting
- Safety margin (60% default)
- Minimum payout ($5)
- 48-hour cooldown
- Daily earning caps

### Coin Economics
- Lesson completion: 10-15 coins
- Quiz passing: 15-20 coins
- Ad rewards: 5-10 coins
- Streak bonuses: 5 coins/day

## 🧪 Testing

### Backend Testing
```bash
cd learn-earn-backend
npm test
```

### Mobile Testing
```bash
cd learn-earn-mobile
flutter test
```

### Admin Panel Testing
```bash
cd learn-earn-admin
npm test
```

## 📊 Monitoring & Analytics

### Key Metrics
- Daily active users
- Lesson completion rates
- Ad impression rates
- Payout success rates
- Revenue per user

### Admin Dashboard
- Real-time budget tracking
- Payout queue management
- User activity monitoring
- System performance metrics

## 🚀 Deployment

### Backend Deployment
1. Build the application
2. Set up MongoDB Atlas
3. Configure environment variables
4. Deploy to your preferred platform (Heroku, AWS, etc.)

### Mobile App Deployment
1. Configure app signing
2. Build release APK/IPA
3. Upload to app stores
4. Configure AdMob (see AdMob Configuration section below)

## 📱 AdMob Configuration

### Android Configuration
- **App ID**: `ca-app-pub-6181092189054832~8209731658`
- **Rewarded Video**: `ca-app-pub-6181092189054832/8716998116` (+15 coins)
- **Interstitial**: `ca-app-pub-6181092189054832/5074116633`
- **Banner**: `ca-app-pub-6181092189054832/8525426424` (320×50)
- **Native**: `ca-app-pub-6181092189054832/4586181410`

### iOS Configuration
- **App ID**: `ca-app-pub-6181092189054832~3807452213`
- **Rewarded Video**: `ca-app-pub-6181092189054832/5470504786` (+15 coins)
- **Interstitial**: `ca-app-pub-6181092189054832/4471481405`
- **Banner**: `ca-app-pub-6181092189054832/1900308326` (320×50)
- **Native**: `ca-app-pub-6181092189054832/2360323384`

### Ad Placement Strategy
- **Rewarded Video**: Full-screen after task completion
- **Interstitial**: Between task navigation screens (with frequency capping)
- **Banner**: Bottom of task list
- **Native**: Embedded in task list items

### Admin Panel Deployment
1. Build for production
2. Deploy to static hosting (Vercel, Netlify, etc.)
3. Configure API endpoints

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For support and questions:
- Create an issue in the repository
- Check the documentation
- Review the FAQ section

## 🔮 Future Enhancements

- Push notifications
- Social features
- Advanced analytics
- A/B testing
- Multi-currency support
- Advanced anti-fraud measures



---

**Note**: This is a comprehensive learning platform designed for educational purposes. Ensure compliance with local regulations and app store policies before deployment.
