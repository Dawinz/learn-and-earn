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

  // Ad Unit IDs - Learn & Grow App AdMob unit IDs

  // 1. Banner Ad
  static String get _bannerAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-6181092189054832/6010463479' // Android Banner
      : 'ca-app-pub-6181092189054832/9566565106'; // iOS Banner

  // 2. Interstitial Ad
  static String get _interstitialAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-6181092189054832/1061389126' // Android Interstitial
      : 'ca-app-pub-6181092189054832/8417134960'; // iOS Interstitial

  // 3. Rewarded Interstitial Ad
  static String get _rewardedInterstitialAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-6181092189054832/8608706658' // Android Rewarded Interstitial
      : 'ca-app-pub-6181092189054832/8890125294'; // iOS Rewarded Interstitial

  // 4. Rewarded Ad
  static String get _rewardedAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-6181092189054832/2332455800' // Android Rewarded
      : 'ca-app-pub-6181092189054832/5627320093'; // iOS Rewarded

  // 5. Native Advanced Ad
  static String get nativeAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-6181092189054832/3689769508' // Android Native Advanced
      : 'ca-app-pub-6181092189054832/6263961957'; // iOS Native Advanced

  // 6. App Open Ad
  static String get _appOpenAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-6181092189054832/3721559099' // Android App Open
      : 'ca-app-pub-6181092189054832/6080129122'; // iOS App Open

  bool _isInitialized = false;
  InterstitialAd? _interstitialAd;
  RewardedInterstitialAd? _rewardedInterstitialAd;
  RewardedAd? _rewardedAd;
  AppOpenAd? _appOpenAd;
  bool _isInterstitialAdReady = false;
  bool _isRewardedInterstitialAdReady = false;
  bool _isRewardedAdReady = false;
  bool _isAppOpenAdReady = false;

  // Initialize AdMob
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Configure RequestConfiguration for 13+ audience (not child-directed)
      final requestConfiguration = RequestConfiguration(
        tagForChildDirectedTreatment: TagForChildDirectedTreatment.no,
        tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.no,
        maxAdContentRating: MaxAdContentRating.pg,
        testDeviceIds: kDebugMode ? ['YOUR_TEST_DEVICE_ID_HERE'] : [],
      );
      MobileAds.instance.updateRequestConfiguration(requestConfiguration);

      await MobileAds.instance.initialize();
      _isInitialized = true;

      // Load initial ads
      _loadInterstitialAd();
      _loadRewardedInterstitialAd();
      _loadRewardedAd();
      _loadAppOpenAd();

      if (kDebugMode) {
        print('AdMob initialized successfully with 13+ audience configuration');
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
            // Only log significant errors, ignore common simulator issues
            if (error.code != 1 && error.code != 5) {
              print('Banner ad failed to load: $error');
            }
          }
          // Don't dispose here - let the widget handle disposal
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
        onAdImpression: (ad) {
          if (kDebugMode) {
            print('Banner ad impression recorded');
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

  // Load Rewarded Interstitial Ad
  void _loadRewardedInterstitialAd() {
    RewardedInterstitialAd.load(
      adUnitId: _rewardedInterstitialAdUnitId,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedInterstitialAd = ad;
          _isRewardedInterstitialAdReady = true;

          _rewardedInterstitialAd!
              .fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              if (kDebugMode) {
                print('Rewarded interstitial ad showed full screen content');
              }
            },
            onAdDismissedFullScreenContent: (ad) {
              if (kDebugMode) {
                print('Rewarded interstitial ad dismissed');
              }
              ad.dispose();
              _isRewardedInterstitialAdReady = false;
              _loadRewardedInterstitialAd(); // Load next ad
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              if (kDebugMode) {
                print('Rewarded interstitial ad failed to show: $error');
              }
              ad.dispose();
              _isRewardedInterstitialAdReady = false;
              _loadRewardedInterstitialAd(); // Load next ad
            },
          );

          if (kDebugMode) {
            print('Rewarded interstitial ad loaded');
          }
        },
        onAdFailedToLoad: (error) {
          if (kDebugMode) {
            print('Rewarded interstitial ad failed to load: $error');
          }
          _isRewardedInterstitialAdReady = false;
        },
      ),
    );
  }

  // Show Rewarded Interstitial Ad
  Future<RewardItem?> showRewardedInterstitialAd() async {
    if (!_isRewardedInterstitialAdReady || _rewardedInterstitialAd == null) {
      if (kDebugMode) {
        print('Rewarded interstitial ad not ready');
      }
      return null;
    }

    try {
      RewardItem? reward;
      await _rewardedInterstitialAd!.show(
        onUserEarnedReward: (ad, rewardItem) {
          reward = rewardItem;
          if (kDebugMode) {
            print(
              'User earned reward from rewarded interstitial: ${rewardItem.amount} ${rewardItem.type}',
            );
          }
        },
      );
      return reward;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to show rewarded interstitial ad: $e');
      }
      return null;
    }
  }

  // Load App Open Ad
  void _loadAppOpenAd() {
    AppOpenAd.load(
      adUnitId: _appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _isAppOpenAdReady = true;

          _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              if (kDebugMode) {
                print('App open ad showed full screen content');
              }
            },
            onAdDismissedFullScreenContent: (ad) {
              if (kDebugMode) {
                print('App open ad dismissed');
              }
              ad.dispose();
              _isAppOpenAdReady = false;
              _loadAppOpenAd(); // Load next ad
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              if (kDebugMode) {
                print('App open ad failed to show: $error');
              }
              ad.dispose();
              _isAppOpenAdReady = false;
              _loadAppOpenAd(); // Load next ad
            },
          );

          if (kDebugMode) {
            print('App open ad loaded');
          }
        },
        onAdFailedToLoad: (error) {
          if (kDebugMode) {
            print('App open ad failed to load: $error');
          }
          _isAppOpenAdReady = false;
        },
      ),
    );
  }

  // Show App Open Ad
  Future<bool> showAppOpenAd() async {
    if (!_isAppOpenAdReady || _appOpenAd == null) {
      if (kDebugMode) {
        print('App open ad not ready');
      }
      return false;
    }

    try {
      await _appOpenAd!.show();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to show app open ad: $e');
      }
      return false;
    }
  }

  // Check if ads are ready
  bool get isInterstitialAdReady => _isInterstitialAdReady;
  bool get isRewardedInterstitialAdReady => _isRewardedInterstitialAdReady;
  bool get isRewardedAdReady => _isRewardedAdReady;
  bool get isAppOpenAdReady => _isAppOpenAdReady;

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
    _rewardedInterstitialAd?.dispose();
    _rewardedAd?.dispose();
    _appOpenAd?.dispose();
  }
}
