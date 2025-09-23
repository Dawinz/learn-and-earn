import 'package:shared_preferences/shared_preferences.dart';

class AdFrequencyService {
  static AdFrequencyService? _instance;
  static AdFrequencyService get instance =>
      _instance ??= AdFrequencyService._();
  AdFrequencyService._();

  // Frequency limits (per hour)
  static const int maxInterstitialAdsPerHour = 3;
  static const int maxRewardedAdsPerHour = 5;
  static const int maxBannerRefreshesPerHour = 10;

  // Keys for SharedPreferences
  static const String _interstitialCountKey = 'interstitial_ad_count';
  static const String _rewardedCountKey = 'rewarded_ad_count';
  static const String _bannerRefreshCountKey = 'banner_refresh_count';
  static const String _lastResetKey = 'ad_frequency_last_reset';

  // Check if we can show an interstitial ad
  Future<bool> canShowInterstitialAd() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final lastReset = DateTime.parse(
      prefs.getString(_lastResetKey) ?? now.toIso8601String(),
    );

    // Reset counters if it's been more than an hour
    if (now.difference(lastReset).inHours >= 1) {
      await _resetCounters();
      return true;
    }

    final count = prefs.getInt(_interstitialCountKey) ?? 0;
    return count < maxInterstitialAdsPerHour;
  }

  // Check if we can show a rewarded ad
  Future<bool> canShowRewardedAd() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final lastReset = DateTime.parse(
      prefs.getString(_lastResetKey) ?? now.toIso8601String(),
    );

    // Reset counters if it's been more than an hour
    if (now.difference(lastReset).inHours >= 1) {
      await _resetCounters();
      return true;
    }

    final count = prefs.getInt(_rewardedCountKey) ?? 0;
    return count < maxRewardedAdsPerHour;
  }

  // Check if we can refresh banner ads
  Future<bool> canRefreshBannerAd() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final lastReset = DateTime.parse(
      prefs.getString(_lastResetKey) ?? now.toIso8601String(),
    );

    // Reset counters if it's been more than an hour
    if (now.difference(lastReset).inHours >= 1) {
      await _resetCounters();
      return true;
    }

    final count = prefs.getInt(_bannerRefreshCountKey) ?? 0;
    return count < maxBannerRefreshesPerHour;
  }

  // Record that an interstitial ad was shown
  Future<void> recordInterstitialAdShown() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(_interstitialCountKey) ?? 0;
    await prefs.setInt(_interstitialCountKey, count + 1);
  }

  // Record that a rewarded ad was shown
  Future<void> recordRewardedAdShown() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(_rewardedCountKey) ?? 0;
    await prefs.setInt(_rewardedCountKey, count + 1);
  }

  // Record that a banner ad was refreshed
  Future<void> recordBannerAdRefreshed() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(_bannerRefreshCountKey) ?? 0;
    await prefs.setInt(_bannerRefreshCountKey, count + 1);
  }

  // Reset all counters
  Future<void> _resetCounters() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();

    await prefs.setInt(_interstitialCountKey, 0);
    await prefs.setInt(_rewardedCountKey, 0);
    await prefs.setInt(_bannerRefreshCountKey, 0);
    await prefs.setString(_lastResetKey, now.toIso8601String());
  }

  // Get current ad counts (for debugging)
  Future<Map<String, int>> getCurrentCounts() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'interstitial': prefs.getInt(_interstitialCountKey) ?? 0,
      'rewarded': prefs.getInt(_rewardedCountKey) ?? 0,
      'banner_refreshes': prefs.getInt(_bannerRefreshCountKey) ?? 0,
    };
  }

  // Get time until next reset
  Future<Duration> getTimeUntilReset() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final lastReset = DateTime.parse(
      prefs.getString(_lastResetKey) ?? now.toIso8601String(),
    );
    final nextReset = lastReset.add(const Duration(hours: 1));

    if (now.isAfter(nextReset)) {
      return Duration.zero;
    }

    return nextReset.difference(now);
  }
}
