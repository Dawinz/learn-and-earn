import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static bool _isInitialized = false;
  static InterstitialAd? _interstitialAd;
  static bool _isInterstitialAdReady = false;
  static RewardedAd? _rewardedAd;
  static bool _isRewardedAdReady = false;

  // Test ad unit IDs (for development)
  static const String _testInterstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _testRewardedAdUnitId =
      'ca-app-pub-3940256099942544/5224354917';
  static const String _testBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';

  // Production ad unit IDs (replace with your actual AdMob unit IDs)
  static const String _androidInterstitialAdUnitId =
      'ca-app-pub-6181092189054832/5074116633';
  static const String _iosInterstitialAdUnitId =
      'ca-app-pub-6181092189054832/4471481405';
  static const String _androidRewardedAdUnitId =
      'ca-app-pub-6181092189054832/8716998116';
  static const String _iosRewardedAdUnitId =
      'ca-app-pub-6181092189054832/5470504786';

  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      print('AdMob initialized successfully');
    } catch (e) {
      print('Failed to initialize AdMob: $e');
    }
  }

  static Future<void> loadInterstitialAd() async {
    try {
      print('Loading interstitial ad with test ID: $_testInterstitialAdUnitId');
      await InterstitialAd.load(
        adUnitId: _testInterstitialAdUnitId, // Use test ad for development
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;
            _isInterstitialAdReady = true;
            print('✅ Interstitial ad loaded successfully');
          },
          onAdFailedToLoad: (error) {
            print('❌ Failed to load interstitial ad: $error');
            _isInterstitialAdReady = false;
          },
        ),
      );
    } catch (e) {
      print('❌ Error loading interstitial ad: $e');
      _isInterstitialAdReady = false;
    }
  }

  static Future<bool> showInterstitialAd() async {
    print('🎯 Attempting to show interstitial ad...');
    print(
      'Ad ready: $_isInterstitialAdReady, Ad object: ${_interstitialAd != null}',
    );

    if (!_isInterstitialAdReady || _interstitialAd == null) {
      print('❌ Interstitial ad not ready - loading new ad first');
      await loadInterstitialAd();
      return false;
    }

    try {
      print('🎬 Showing interstitial ad...');
      await _interstitialAd!.show();
      _isInterstitialAdReady = false;
      _interstitialAd = null;
      print('✅ Interstitial ad shown successfully');

      // Load next ad
      loadInterstitialAd();
      return true;
    } catch (e) {
      print('❌ Error showing interstitial ad: $e');
      _isInterstitialAdReady = false;
      _interstitialAd = null;
      return false;
    }
  }

  static Future<void> loadRewardedAd() async {
    try {
      print('Loading rewarded ad with test ID: $_testRewardedAdUnitId');
      await RewardedAd.load(
        adUnitId: _testRewardedAdUnitId, // Use test ad for development
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;
            _isRewardedAdReady = true;
            print('✅ Rewarded ad loaded successfully');
          },
          onAdFailedToLoad: (error) {
            print('❌ Failed to load rewarded ad: $error');
            _isRewardedAdReady = false;
          },
        ),
      );
    } catch (e) {
      print('❌ Error loading rewarded ad: $e');
      _isRewardedAdReady = false;
    }
  }

  static Future<bool> showRewardedAd() async {
    print('🎯 Attempting to show rewarded ad...');
    print(
      'Rewarded ad ready: $_isRewardedAdReady, Ad object: ${_rewardedAd != null}',
    );

    if (!_isRewardedAdReady || _rewardedAd == null) {
      print('❌ Rewarded ad not ready - loading new ad first');
      await loadRewardedAd();
      return false;
    }

    try {
      print('🎬 Showing rewarded ad...');
      await _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          print('✅ User earned reward: ${reward.amount} ${reward.type}');
        },
      );
      _isRewardedAdReady = false;
      _rewardedAd = null;
      print('✅ Rewarded ad shown successfully');

      // Load next ad
      loadRewardedAd();
      return true;
    } catch (e) {
      print('❌ Error showing rewarded ad: $e');
      _isRewardedAdReady = false;
      _rewardedAd = null;
      return false;
    }
  }

  // Banner ad widget
  static Widget getBannerAd() {
    return Container(
      alignment: Alignment.center,
      width: 320,
      height: 50,
      child: AdWidget(
        ad: BannerAd(
          adUnitId: _testBannerAdUnitId,
          size: AdSize.banner,
          request: const AdRequest(),
          listener: BannerAdListener(
            onAdLoaded: (ad) {
              print('✅ Banner ad loaded');
            },
            onAdFailedToLoad: (ad, error) {
              print('❌ Banner ad failed to load: $error');
              ad.dispose();
            },
          ),
        )..load(),
      ),
    );
  }

  static Future<void> preloadAds() async {
    try {
      print('🔄 Preloading ads...');
      await loadInterstitialAd();
      await loadRewardedAd();
      print('✅ Ads preloaded successfully');
    } catch (e) {
      print('❌ Failed to preload ads: $e');
    }
  }
}
