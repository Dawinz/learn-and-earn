/// Global app strings for Learn & Grow
///
/// This file contains all user-facing strings to ensure consistent terminology
/// and make it easy to update copy across the entire app.
class AppStrings {
  // App Identity
  static const String appName = 'Learn & Grow';
  static const String appTagline = 'Gamified learning with XP, badges, and community events';

  // XP & Progress Terms (replacing coins/money)
  static const String xp = 'XP';
  static const String totalXp = 'Total XP';
  static const String dailyXp = 'Daily XP';
  static const String earnXp = 'Earn XP';
  static const String gainXp = 'Gain XP';
  static const String xpGained = 'XP Gained';
  static const String xpEarned = 'XP Earned';
  static const String yourXp = 'Your XP';
  static const String currentXp = 'Current XP';

  // Achievements & Badges
  static const String achievements = 'Achievements';
  static const String badges = 'Badges';
  static const String unlocked = 'Unlocked';
  static const String locked = 'Locked';
  static const String badgeEarned = 'Badge Earned';
  static const String unlock = 'Unlock';
  static const String progress = 'Progress';

  // Leaderboard
  static const String leaderboard = 'Leaderboard';
  static const String rank = 'Rank';
  static const String yourRank = 'Your Rank';
  static const String topLearners = 'Top Learners';
  static const String globalRank = 'Global Rank';
  static const String localRank = 'Local Rank';

  // Learning
  static const String lessons = 'Lessons';
  static const String lesson = 'Lesson';
  static const String quiz = 'Quiz';
  static const String quizzes = 'Quizzes';
  static const String completeLesson = 'Complete Lesson';
  static const String takeQuiz = 'Take Quiz';
  static const String lessonsCompleted = 'Lessons Completed';
  static const String quizzesCompleted = 'Quizzes Completed';
  static const String coursesCompleted = 'Courses Completed';

  // Streak
  static const String streak = 'Learning Streak';
  static const String dailyStreak = 'Daily Streak';
  static const String keepStreak = 'Keep Your Streak';
  static const String streakDays = 'Day Streak';
  static const String streakMaintained = 'Streak Maintained';

  // Community & Events
  static const String community = 'Community';
  static const String events = 'Events';
  static const String rewardsPolicy = 'Rewards Policy';
  static const String joinCommunity = 'Join Community';
  static const String viewEvents = 'View Events';
  static const String eventEligibility = 'Event Eligibility';

  // General Progress
  static const String myProgress = 'My Progress';
  static const String statistics = 'Statistics';
  static const String profile = 'Profile';
  static const String settings = 'Settings';
  static const String about = 'About';
  static const String help = 'Help & Support';

  // Actions
  static const String start = 'Start';
  static const String continue_ = 'Continue';
  static const String complete = 'Complete';
  static const String view = 'View';
  static const String learn = 'Learn';
  static const String practice = 'Practice';
  static const String master = 'Master';

  // Messages
  static const String congratulations = 'Congratulations!';
  static const String wellDone = 'Well Done!';
  static const String keepGoing = 'Keep Going!';
  static const String niceWork = 'Nice Work!';
  static const String excellent = 'Excellent!';

  // Ad-related (XP rewards)
  static const String watchAdForXp = 'Watch Ad for XP';
  static const String adReward = 'Ad Reward';
  static const String bonusXp = 'Bonus XP';
  static const String watchVideo = 'Watch Video';

  // Navigation
  static const String home = 'Home';
  static const String learn_ = 'Learn';
  static const String progressTab = 'Progress';
  static const String more = 'More';

  // Common
  static const String ok = 'OK';
  static const String cancel = 'Cancel';
  static const String close = 'Close';
  static const String done = 'Done';
  static const String save = 'Save';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String share = 'Share';
  static const String logout = 'Logout';

  // Error Messages
  static const String error = 'Error';
  static const String tryAgain = 'Try Again';
  static const String somethingWentWrong = 'Something went wrong';
  static const String noInternet = 'No internet connection';
  static const String loading = 'Loading...';

  // Empty States
  static const String noLessonsYet = 'No lessons yet';
  static const String noAchievementsYet = 'No achievements unlocked yet';
  static const String startLearning = 'Start learning to unlock achievements!';
  static const String noProgress = 'No progress data available';

  // Policy & Info
  static const String privacyPolicy = 'Privacy Policy';
  static const String termsOfService = 'Terms of Service';
  static const String contactUs = 'Contact Us';
  static const String version = 'Version';

  // Login/Signup
  static const String login = 'Login';
  static const String signup = 'Sign Up';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String createAccount = 'Create Account';
  static const String alreadyHaveAccount = 'Already have an account?';
  static const String dontHaveAccount = "Don't have an account?";

  // Notifications
  static const String notifications = 'Notifications';
  static const String enableNotifications = 'Enable Notifications';
  static const String dailyReminder = 'Daily Reminder';
  static const String streakReminder = 'Streak Reminder';

  // Community Messages
  static const String communityDescription =
      'Join our learning community to connect with fellow learners, share tips, and participate in events!';
  static const String eventsDescription =
      'Participate in community tournaments and challenges. Top performers may be eligible for external prizes managed by the community.';
  static const String rewardsPolicyDescription =
      'XP and badges are virtual rewards for tracking your learning progress. They are not redeemable for cash or prizes within the app. External events may offer prizes, which are managed separately by event organizers.';

  // Specific XP amounts (templates)
  static String xpAmount(int amount) => '$amount XP';
  static String xpGainedMessage(int amount) => 'You gained $amount XP!';
  static String dailyXpMessage(int current, int goal) => 'Daily XP: $current / $goal';
  static String rankMessage(int rank) => 'Rank #$rank';
  static String streakMessage(int days) => '$days day${days == 1 ? "" : "s"}';
  static String lessonsCompletedMessage(int count) => '$count lesson${count == 1 ? "" : "s"} completed';
  static String quizzesCompletedMessage(int count) => '$count quiz${count == 1 ? "" : "zes"} completed';
  static String achievementsUnlockedMessage(int count) => '$count achievement${count == 1 ? "" : "s"} unlocked';
}
