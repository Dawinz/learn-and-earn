import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';
import '../widgets/banner_ad_widget.dart';
import 'ad_frequency_service.dart';

class AdService {
  static AdService? _instance;
  static AdService get instance => _instance ??= AdService._();
  AdService._();

  // Ad Unit IDs - Production AdMob unit IDs from README.md
  static String get _bannerAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-6181092189054832/8525426424' // Android Banner (320×50)
      : 'ca-app-pub-6181092189054832/1900308326'; // iOS Banner (320×50)

  static String get _interstitialAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-6181092189054832/5074116633' // Android Interstitial
      : 'ca-app-pub-6181092189054832/4471481405'; // iOS Interstitial

  static String get _rewardedAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-6181092189054832/8716998116' // Android Rewarded Video (+15 coins)
      : 'ca-app-pub-6181092189054832/5470504786'; // iOS Rewarded Video (+15 coins)

  // Native Ad Unit IDs (for future use)
  static String get _nativeAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-6181092189054832/4586181410' // Android Native
      : 'ca-app-pub-6181092189054832/2360323384'; // iOS Native

  bool _isInitialized = false;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  bool _isInterstitialAdReady = false;
  bool _isRewardedAdReady = false;

  // Initialize AdMob
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;

      // Load initial ads
      _loadInterstitialAd();
      _loadRewardedAd();

      if (kDebugMode) {
        print('AdMob initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize AdMob: $e');
      }
    }
  }

  // Load Banner Ad
  BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (kDebugMode) {
            print('Banner ad loaded');
          }
        },
        onAdFailedToLoad: (ad, error) {
          if (kDebugMode) {
            print('Banner ad failed to load: $error');
          }
          ad.dispose();
        },
        onAdOpened: (ad) {
          if (kDebugMode) {
            print('Banner ad opened');
          }
        },
        onAdClosed: (ad) {
          if (kDebugMode) {
            print('Banner ad closed');
          }
        },
      ),
    );
  }

  // Load Interstitial Ad
  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;

          _interstitialAd!.fullScreenContentCallback =
              FullScreenContentCallback(
                onAdShowedFullScreenContent: (ad) {
                  if (kDebugMode) {
                    print('Interstitial ad showed full screen content');
                  }
                },
                onAdDismissedFullScreenContent: (ad) {
                  if (kDebugMode) {
                    print('Interstitial ad dismissed');
                  }
                  ad.dispose();
                  _isInterstitialAdReady = false;
                  _loadInterstitialAd(); // Load next ad
                },
                onAdFailedToShowFullScreenContent: (ad, error) {
                  if (kDebugMode) {
                    print('Interstitial ad failed to show: $error');
                  }
                  ad.dispose();
                  _isInterstitialAdReady = false;
                  _loadInterstitialAd(); // Load next ad
                },
              );

          if (kDebugMode) {
            print('Interstitial ad loaded');
          }
        },
        onAdFailedToLoad: (error) {
          if (kDebugMode) {
            print('Interstitial ad failed to load: $error');
          }
          _isInterstitialAdReady = false;
        },
      ),
    );
  }

  // Show Interstitial Ad
  Future<bool> showInterstitialAd() async {
    // Check frequency capping
    final canShow = await AdFrequencyService.instance.canShowInterstitialAd();
    if (!canShow) {
      if (kDebugMode) {
        print('Interstitial ad frequency limit reached');
      }
      return false;
    }

    if (!_isInterstitialAdReady || _interstitialAd == null) {
      if (kDebugMode) {
        print('Interstitial ad not ready');
      }
      return false;
    }

    try {
      await _interstitialAd!.show();
      // Record that ad was shown
      await AdFrequencyService.instance.recordInterstitialAdShown();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to show interstitial ad: $e');
      }
      return false;
    }
  }

  // Load Rewarded Ad
  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdReady = true;

          _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              if (kDebugMode) {
                print('Rewarded ad showed full screen content');
              }
            },
            onAdDismissedFullScreenContent: (ad) {
              if (kDebugMode) {
                print('Rewarded ad dismissed');
              }
              ad.dispose();
              _isRewardedAdReady = false;
              _loadRewardedAd(); // Load next ad
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              if (kDebugMode) {
                print('Rewarded ad failed to show: $error');
              }
              ad.dispose();
              _isRewardedAdReady = false;
              _loadRewardedAd(); // Load next ad
            },
          );

          if (kDebugMode) {
            print('Rewarded ad loaded');
          }
        },
        onAdFailedToLoad: (error) {
          if (kDebugMode) {
            print('Rewarded ad failed to load: $error');
          }
          _isRewardedAdReady = false;
        },
      ),
    );
  }

  // Show Rewarded Ad
  Future<RewardItem?> showRewardedAd() async {
    // Check frequency capping
    final canShow = await AdFrequencyService.instance.canShowRewardedAd();
    if (!canShow) {
      if (kDebugMode) {
        print('Rewarded ad frequency limit reached');
      }
      return null;
    }

    if (!_isRewardedAdReady || _rewardedAd == null) {
      if (kDebugMode) {
        print('Rewarded ad not ready');
      }
      return null;
    }

    try {
      RewardItem? reward;
      await _rewardedAd!.show(
        onUserEarnedReward: (ad, rewardItem) {
          reward = rewardItem;
          if (kDebugMode) {
            print(
              'User earned reward: ${rewardItem.amount} ${rewardItem.type}',
            );
          }
        },
      );
      // Record that ad was shown
      await AdFrequencyService.instance.recordRewardedAdShown();
      return reward;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to show rewarded ad: $e');
      }
      return null;
    }
  }

  // Check if ads are ready
  bool get isInterstitialAdReady => _isInterstitialAdReady;
  bool get isRewardedAdReady => _isRewardedAdReady;

  // Static methods for backward compatibility

  static Widget getBannerAd() {
    return BannerAdWidget();
  }

  static Future<bool> preloadAds() async {
    await instance.initialize();
    return true;
  }

  // Dispose resources
  void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}
