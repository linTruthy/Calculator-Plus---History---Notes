// import 'package:easy_ads_flutter/easy_ads_flutter.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:firebase_analytics/firebase_analytics.dart';
// import 'dart:io' show Platform;

// // Test Ad IDs Map
// final Map<String, Map<String, String>> testIds = {
//   'android': {
//     'app_id': 'ca-app-pub-3940256099942544~3347511713',
//     'banner': 'ca-app-pub-3940256099942544/6300978111',
//     'interstitial': 'ca-app-pub-3940256099942544/1033173712',
//     'native': 'ca-app-pub-3940256099942544/2247696110',
//     'rewarded': 'ca-app-pub-3940256099942544/5224354917',
//     'rewarded_interstitial': 'ca-app-pub-3940256099942544/5354046379',
//   },
//   'ios': {
//     'app_id': 'ca-app-pub-3940256099942544~1458002511',
//     'banner': 'ca-app-pub-3940256099942544/2934735716',
//     'interstitial': 'ca-app-pub-3940256099942544/4411468910',
//     'native': 'ca-app-pub-3940256099942544/3986624511',
//     'rewarded': 'ca-app-pub-3940256099942544/1712485313',
//     'rewarded_interstitial': 'ca-app-pub-3940256099942544/6978759866',
//   },
// };

// // Premium Features Enum
enum PremiumFeature {
  noAds,
  historyExport,
  customThemes,
  cloudBackup,
  scientificMode,
  currencyConverter
}

// class AdAnalytics {
//   final String adType;
//   final String placement;
//   final DateTime timestamp;
//   final bool wasShown;
//   final bool wasClicked;
//   final double revenue;

//   AdAnalytics({
//     required this.adType,
//     required this.placement,
//     required this.timestamp,
//     required this.wasShown,
//     required this.wasClicked,
//     this.revenue = 0.0,
//   });

//   Map<String, Object> toJson() => {
//         'adType': adType,
//         'placement': placement,
//         'timestamp': timestamp.toIso8601String(),
//         'wasShown': wasShown,
//         'wasClicked': wasClicked,
//         'revenue': revenue,
//       };
// }

// class UserSegment {
//   final bool isPremium;
//   final int calculationsPerDay;
//   final int daysActive;
//   final List<String> featuresUsed;
//   final String userRegion;

//   UserSegment({
//     required this.isPremium,
//     required this.calculationsPerDay,
//     required this.daysActive,
//     required this.featuresUsed,
//     required this.userRegion,
//   });
// }

// class AdManager {
//   static AdManager? _instance;
//   final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
//   final SharedPreferences _prefs;

//   bool _isPremium = false;
//   final Map<PremiumFeature, bool> _unlockedFeatures = {};
//   final List<AdAnalytics> _adAnalytics = [];
//   DateTime? _firstUseDate;
//   int _totalCalculations = 0;
//   UserSegment? _userSegment;

//   static AdManager get instance => _instance!;

//   AdManager._(this._prefs) {
//     _loadPremiumStatus();
//     _loadAnalytics();
//     _initializeUserSegment();
//   }

//   static Future<void> initialize() async {
//     final prefs = await SharedPreferences.getInstance();
//     _instance = AdManager._(prefs);
//     await _instance!._initializeAds();
//   }

//   Future<void> _initializeAds() async {
//     final adsIdMap = <AdNetwork, Map<String, String>>{
//       AdNetwork.admob: Platform.isAndroid ? testIds['android']! : testIds['ios']!,
//     };

//     final adConfig = EasyAdsConfig()
//       ..adNetwork = AdNetwork.admob
//       ..isDebug = true
//       ..adsIdMap = adsIdMap
//       ..testDeviceIds = ['test-device-id']  // Add your test device IDs
//       ..initialize(
//         bannerAdEnabled: true,
//         interstitialAdEnabled: true,
//         nativeAdEnabled: true,
//         rewardedAdEnabled: true,
//       );

//     await EasyAds.instance.initialize(adConfig);
    
//     // Set up ad listeners
//     EasyAds.instance.setEventListener(
//       EasyAdsEventListener(
//         onAdLoaded: (adType, data) => _logAdEvent(
//           AdAnalytics(
//             adType: adType.name,
//             placement: 'default',
//             timestamp: DateTime.now(),
//             wasShown: true,
//             wasClicked: false,
//           ),
//         ),
//         onAdClicked: (adType, data) => _logAdEvent(
//           AdAnalytics(
//             adType: adType.name,
//             placement: 'default',
//             timestamp: DateTime.now(),
//             wasShown: true,
//             wasClicked: true,
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> _loadAnalytics() async {
//     _firstUseDate = DateTime.parse(
//         _prefs.getString('first_use_date') ?? DateTime.now().toIso8601String());
//     _totalCalculations = _prefs.getInt('total_calculations') ?? 0;
//   }

//   Future<void> _loadPremiumStatus() async {
//     _isPremium = _prefs.getBool('is_premium') ?? false;
//     final unlockedFeatures = _prefs.getStringList('unlocked_features') ?? [];
    
//     for (final feature in unlockedFeatures) {
//       _unlockedFeatures[PremiumFeature.values
//           .firstWhere((e) => e.toString() == feature)] = true;
//     }
//   }

//   // UI Components with Cupertino styling
//   Widget buildAdBanner() {
//     if (_isPremium) return const SizedBox.shrink();

//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       decoration: BoxDecoration(
//         color: CupertinoColors.systemBackground,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: CupertinoColors.systemGrey.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(12),
//         child: const EasyBannerAd(
//           adNetwork: AdNetwork.admob,
//           adSize: AdSize.banner,
//         ),
//       ),
//     );
//   }

//   Widget buildNativeAd() {
//     if (_isPremium) return const SizedBox.shrink();

//     return Container(
//       margin: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: CupertinoColors.systemBackground,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: CupertinoColors.systemGrey.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(12),
//         child: const EasyNativeAd(
//           adNetwork: AdNetwork.admob,
//           factoryId: 'calculatorTip',
//         ),
//       ),
//     );
//   }

//   Widget buildPremiumFeatureButton(
//       PremiumFeature feature, VoidCallback onUnlocked) {
//     return CupertinoButton.filled(
//       onPressed: () => _showRewardedAdForFeature(feature, onUnlocked),
//       child: Text(
//         'Unlock ${feature.toString().split('.').last}',
//         style: const TextStyle(
//           fontFamily: '.SF Pro Text',
//           fontSize: 16,
//           fontWeight: FontWeight.w500,
//         ),
//       ),
//     );
//   }

//   // Ad Display Methods
//   Future<void> _showRewardedAdForFeature(
//       PremiumFeature feature, VoidCallback onUnlocked) async {
//     if (_isPremium) {
//       onUnlocked();
//       return;
//     }

//     final result =  EasyAds.instance.isRewardedAdLoaded();
//     if (result) {
//       await unlockFeature(feature);
//       onUnlocked();
//     }
//   }

//   Future<void> showInterstitial() async {
//     if (!_isPremium) {
//        EasyAds.instance.showAd(
//        AdUnitType.interstitial,
//        adNetwork: AdNetwork.any
//       );
//     }
//     }
//   }
  
//   class EasyAdsConfig {
//     AdNetwork? adNetwork;
  
//     bool? isDebug;
  
//     Map<AdNetwork, Map<String, String>>? adsIdMap;
  
//     List<String>? testDeviceIds;

//   }

//   // Premium Features Management
//   Future<void> unlockFeature(PremiumFeature feature) async {
//     _unlockedFeatures[feature] = true;
//     await _savePremiumFeatures();
//     _logFeatureUnlock(feature);
//   }

//   bool hasFeature(PremiumFeature feature) {
//     return _isPremium || _unlockedFeatures[feature] == true;
//   }

//   Future<void> _savePremiumFeatures() async {
//     await _prefs.setStringList(
//       'unlocked_features',
//       _unlockedFeatures.entries
//           .where((entry) => entry.value)
//           .map((entry) => entry.key.toString())
//           .toList(),
//     );
//   }

//   void _logFeatureUnlock(PremiumFeature feature) {
//     _analytics.logEvent(
//       name: 'feature_unlock',
//       parameters: {
//         'feature': feature.toString(),
//         'method': 'rewarded_ad',
//         'timestamp': DateTime.now().toIso8601String(),
//       },
//     );
//   }

//   void _logAdEvent(AdAnalytics analytics) {
//     _adAnalytics.add(analytics);
//     _analytics.logEvent(
//       name: 'ad_event',
//       parameters: analytics.toJson(),
//     );
//   }

//   Future<void> _initializeUserSegment() async {
//     final region = await _determineUserRegion();
//     final featuresUsed = _prefs.getStringList('features_used') ?? [];
    
//     _userSegment = UserSegment(
//       isPremium: _isPremium,
//       calculationsPerDay: _getAverageCalculationsPerDay(),
//       daysActive: _daysSinceFirstUse(),
//       featuresUsed: featuresUsed,
//       userRegion: region,
//     );
//   }

//   Future<String> _determineUserRegion() async {
//     // Implement region detection logic
//     return 'unknown';
//   }

//   int _getAverageCalculationsPerDay() {
//     final days = _daysSinceFirstUse();
//     return days > 0 ? (_totalCalculations / days).round() : 0;
//   }

//   int _daysSinceFirstUse() {
//     if (_firstUseDate == null) return 0;
//     return DateTime.now().difference(_firstUseDate!).inDays;
//   }

//   // Analytics reporting
//   Map<String, dynamic> getAnalyticsReport() {
//     return {
//       'total_ads_shown': _adAnalytics.where((a) => a.wasShown).length,
//       'total_clicks': _adAnalytics.where((a) => a.wasClicked).length,
//       'total_revenue': _adAnalytics.fold(0.0, (sum, a) => sum + a.revenue),
//       'ads_by_type': _getAdsByType(),
//       'user_segment': {
//         'premium': _isPremium,
//         'days_active': _daysSinceFirstUse(),
//         'calculations_per_day': _getAverageCalculationsPerDay(),
//         'region': _userSegment?.userRegion,
//       },
//     };
//   }

//   Map<String, int> _getAdsByType() {
//     final adsByType = <String, int>{};
//     for (final analytics in _adAnalytics) {
//       adsByType[analytics.adType] = (adsByType[analytics.adType] ?? 0) + 1;
//     }
//     return adsByType;
//   }
// }