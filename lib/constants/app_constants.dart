class AppConstants {
  // Backend API Configuration
  static const String SUPABASE_BASE_URL =
      'https://iscqpvwtikwqquvxlpsr.supabase.co/functions/v1';
  static const String SUPABASE_ANON_KEY =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlzY3Fwdnd0aWt3cXF1dnhscHNyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI2MTc3MDMsImV4cCI6MjA3ODE5MzcwM30.bl0H3HJ4n3wYWSL0I_100IS3fBr5yjv5Okzm_0ziAS0';

  // XP System Constants
  static const int DEFAULT_STARTING_XP = 1000;

  // XP Rewards
  static const int XP_PER_LESSON = 100;
  static const int XP_PER_QUIZ = 50;
  static const int XP_DAILY_LOGIN = 10;
  static const int XP_STREAK_BONUS = 5; // per day of streak

  // Achievement Thresholds
  static const int BEGINNER_XP = 1000;
  static const int INTERMEDIATE_XP = 5000;
  static const int ADVANCED_XP = 10000;
  static const int EXPERT_XP = 25000;
  static const int MASTER_XP = 50000;

  // Level Calculation
  static int calculateLevel(int xp) {
    return (xp / 100).floor() + 1;
  }

  static String getLevelTitle(int level) {
    if (level >= 100) return 'Master Learner';
    if (level >= 50) return 'Expert Learner';
    if (level >= 25) return 'Advanced Learner';
    if (level >= 10) return 'Intermediate Learner';
    return 'Beginner Learner';
  }
}
