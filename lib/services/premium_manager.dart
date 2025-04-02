// lib/services/premium_manager.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PremiumFeature {
  noAds,
  historyExport,
  customThemes,
  cloudBackup,
  scientificMode,
  currencyConverter,
}

class PremiumManager {
  static final PremiumManager _instance = PremiumManager._internal();
  factory PremiumManager() => _instance;
  PremiumManager._internal();

  // Keys for SharedPreferences
  static const String _isPremiumKey = 'is_premium_user';
  static const String _featurePrefix = 'premium_feature_';
  
  // Cache for features to avoid excessive SharedPreferences calls
  final Map<PremiumFeature, bool> _featureCache = {};
  bool? _isPremium;

  // Initialize and load the premium status
  Future<void> initialize() async {
    await _loadPremiumStatus();
  }

  // Load premium status from SharedPreferences
  Future<void> _loadPremiumStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool(_isPremiumKey) ?? false;
    
    // Clear the cache
    _featureCache.clear();
    
    // Load all features into cache
    for (final feature in PremiumFeature.values) {
      final key = _getFeatureKey(feature);
      _featureCache[feature] = prefs.getBool(key) ?? false;
    }
  }

  // Get key for a specific feature
  String _getFeatureKey(PremiumFeature feature) {
    return '$_featurePrefix${feature.toString().split('.').last}';
  }

  // Check if user has premium status
  Future<bool> isPremium() async {
    if (_isPremium == null) {
      await _loadPremiumStatus();
    }
    return _isPremium ?? false;
  }

  // Check if user has access to a specific feature
  Future<bool> hasFeature(PremiumFeature feature) async {
    // If we've already checked this feature, return from cache
    if (_featureCache.containsKey(feature)) {
      return _featureCache[feature]!;
    }
    
    // Otherwise, check from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final key = _getFeatureKey(feature);
    final hasAccess = prefs.getBool(key) ?? false;
    
    // Cache the result
    _featureCache[feature] = hasAccess;
    
    return hasAccess;
  }

  // Set premium status
  Future<void> setPremiumStatus(bool isPremium) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isPremiumKey, isPremium);
    _isPremium = isPremium;
    
    // If the user is premium, unlock all features
    if (isPremium) {
      for (final feature in PremiumFeature.values) {
        await unlockFeature(feature);
      }
    }
  }

  // Unlock a specific feature
  Future<void> unlockFeature(PremiumFeature feature) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getFeatureKey(feature);
    await prefs.setBool(key, true);
    _featureCache[feature] = true;
  }

  // For development and testing
  Future<void> resetFeatures() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isPremiumKey, false);
    
    for (final feature in PremiumFeature.values) {
      final key = _getFeatureKey(feature);
      await prefs.setBool(key, false);
    }
    
    await _loadPremiumStatus();
  }

  // Show purchase dialog for a premium feature
  Future<bool> purchaseFeature(PremiumFeature feature) async {
    // In a real app, this would integrate with an in-app purchase API
    // For this implementation, we'll simulate a successful purchase
    
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Always succeed for development purposes
    await unlockFeature(feature);
    return true;
  }
  
  // Purchase all premium features (premium bundle)
  Future<bool> purchasePremium() async {
    // In a real app, this would integrate with an in-app purchase API
    // For this implementation, we'll simulate a successful purchase
    
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Always succeed for development purposes
    await setPremiumStatus(true);
    return true;
  }
  
  // Toggle a feature (for development/testing only)
  Future<void> toggleFeature(PremiumFeature feature) async {
    final currentStatus = await hasFeature(feature);
    final prefs = await SharedPreferences.getInstance();
    final key = _getFeatureKey(feature);
    await prefs.setBool(key, !currentStatus);
    _featureCache[feature] = !currentStatus;
  }
}