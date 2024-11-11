// lib/services/ad_manager.dart
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

class AdManager {
  static final AdManager _instance = AdManager._internal();
  factory AdManager() => _instance;
  AdManager._internal();

  // Ad Units
  static const String _testBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialId = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testRewardedId = 'ca-app-pub-3940256099942544/5224354917';

  // Production IDs - Replace with your actual ad unit IDs
  static const String _prodBannerId = 'ca-app-pub-8267064683737776/5354943697';
  static const String _prodInterstitialId = 'ca-app-pub-8267064683737776/3625350042';
  static const String _prodRewardedId = 'ca-app-pub-8267064683737776/9128986418';

  // Ad instances
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  // Tracking variables
  int _calculationsCount = 0;
  DateTime? _lastInterstitialShow;
  bool _isInitialized = false;

  // Constants for ad frequency
  static const int _calculationsBeforeAd = 5;
  static const Duration _minTimeBetweenAds = Duration(minutes: 3);

  // Getters for ad unit IDs based on build mode
  String get bannerAdUnitId => kDebugMode ? _testBannerId : _prodBannerId;
  String get interstitialAdUnitId => kDebugMode ? _testInterstitialId : _prodInterstitialId;
  String get rewardedAdUnitId => kDebugMode ? _testRewardedId : _prodRewardedId;

  // Initialize the AdManager
  Future<void> initialize() async {
    if (_isInitialized) return;

    await MobileAds.instance.initialize();
    _loadBannerAd();
    _loadInterstitialAd();
    _loadRewardedAd();
    _isInitialized = true;
  }

  // Banner Ad Management
  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => debugPrint('Banner ad loaded'),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _bannerAd = null;
          debugPrint('Banner ad failed to load: $error');
          // Retry loading after delay
          Future.delayed(const Duration(minutes: 1), _loadBannerAd);
        },
      ),
    )..load();
  }

  // Interstitial Ad Management
  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialAd!.setImmersiveMode(true);
        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial ad failed to load: $error');
          // Retry loading after delay
          Future.delayed(const Duration(minutes: 1), _loadInterstitialAd);
        },
      ),
    );
  }

  // Rewarded Ad Management
  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
        },
        onAdFailedToLoad: (error) {
          debugPrint('Rewarded ad failed to load: $error');
          // Retry loading after delay
          Future.delayed(const Duration(minutes: 1), _loadRewardedAd);
        },
      ),
    );
  }

  // Get banner ad widget
  BannerAd? get bannerAd => _bannerAd;

  // Track calculations and show interstitial when appropriate
  Future<void> onCalculationPerformed() async {
    _calculationsCount++;
    
    if (_shouldShowInterstitial()) {
      await showInterstitialAd();
      _calculationsCount = 0;
    }
  }

  bool _shouldShowInterstitial() {
    if (_calculationsCount < _calculationsBeforeAd) return false;
    if (_lastInterstitialShow != null) {
      final timeSinceLastAd = DateTime.now().difference(_lastInterstitialShow!);
      if (timeSinceLastAd < _minTimeBetweenAds) return false;
    }
    return _interstitialAd != null;
  }

  Future<void> showInterstitialAd() async {
    if (_interstitialAd == null) return;

    await _interstitialAd!.show();
    _lastInterstitialShow = DateTime.now();
    _interstitialAd = null;
    _loadInterstitialAd(); // Load the next interstitial
  }

  // Show rewarded ad and return whether the user completed watching
  Future<bool> showRewardedAd() async {
    if (_rewardedAd == null) return false;

    final completer = Completer<bool>();
    await _rewardedAd!.show(
      onUserEarnedReward: (_, reward) {
        completer.complete(true);
      },
    );
    _rewardedAd = null;
    _loadRewardedAd(); // Load the next rewarded ad
    return completer.future;
  }

  // Cleanup
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}


