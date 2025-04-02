// lib/screens/premium_features_page.dart
import 'package:calculator_plus_history_notes/managers/theme_notifier.dart';
import 'package:calculator_plus_history_notes/services/premium_manager.dart';
import 'package:calculator_plus_history_notes/widgets/ad_banner_widget.dart';
import 'package:calculator_plus_history_notes/widgets/adaptive_button.dart';
import 'package:calculator_plus_history_notes/widgets/adaptive_card.dart';
import 'package:calculator_plus_history_notes/widgets/bouncing_button.dart';
import 'package:calculator_plus_history_notes/widgets/reponsive_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

class PremiumFeaturesPage extends StatefulWidget {
  const PremiumFeaturesPage({super.key});

  @override
  State<PremiumFeaturesPage> createState() => _PremiumFeaturesPageState();
  
  // Static methods for feature info to use across the app
  static String getFeatureTitle(PremiumFeature feature) {
    switch (feature) {
      case PremiumFeature.noAds:
        return 'Ad-Free Experience';
      case PremiumFeature.historyExport:
        return 'Export History';
      case PremiumFeature.customThemes:
        return 'Custom Themes';
      case PremiumFeature.cloudBackup:
        return 'Cloud Backup';
      case PremiumFeature.scientificMode:
        return 'Scientific Calculator';
      case PremiumFeature.currencyConverter:
        return 'Currency Converter';
    }
  }

  static String getFeatureDescription(PremiumFeature feature) {
    switch (feature) {
      case PremiumFeature.noAds:
        return 'Remove all advertisements from the app for a cleaner experience.';
      case PremiumFeature.historyExport:
        return 'Export your calculation history to CSV or PDF for record keeping.';
      case PremiumFeature.customThemes:
        return 'Create and save your own personalized calculator themes.';
      case PremiumFeature.cloudBackup:
        return 'Securely back up your history and settings to the cloud.';
      case PremiumFeature.scientificMode:
        return 'Access advanced scientific calculator functions like sin, cos, tan, log, and more.';
      case PremiumFeature.currencyConverter:
        return 'Convert between different currencies with real-time exchange rates.';
    }
  }
  
  static IconData getFeatureIcon(PremiumFeature feature) {
    switch (feature) {
      case PremiumFeature.noAds:
        return CupertinoIcons.rectangle_badge_xmark;
      case PremiumFeature.historyExport:
        return CupertinoIcons.share;
      case PremiumFeature.customThemes:
        return CupertinoIcons.paintbrush;
      case PremiumFeature.cloudBackup:
        return CupertinoIcons.cloud_upload;
      case PremiumFeature.scientificMode:
        return CupertinoIcons.function;
      case PremiumFeature.currencyConverter:
        return CupertinoIcons.money_dollar_circle;
    }
  }
}

class _PremiumFeaturesPageState extends State<PremiumFeaturesPage> {
  final PremiumManager _premiumManager = PremiumManager();
  bool _isPremium = false;
  final Map<PremiumFeature, bool> _featureStatus = {};
  final Map<PremiumFeature, bool> _loadingStatus = {};
  
  @override
  void initState() {
    super.initState();
    _loadPremiumStatus();
  }
  
  Future<void> _loadPremiumStatus() async {
    final isPremium = await _premiumManager.isPremium();
    
    // Load status for each feature
    for (final feature in PremiumFeature.values) {
      _featureStatus[feature] = await _premiumManager.hasFeature(feature);
      _loadingStatus[feature] = false;
    }
    
    if (mounted) {
      setState(() {
        _isPremium = isPremium;
      });
    }
  }
  
  Future<void> _purchaseFeature(PremiumFeature feature) async {
    setState(() {
      _loadingStatus[feature] = true;
    });
    
    try {
      final success = await _premiumManager.purchaseFeature(feature);
      if (success && mounted) {
        setState(() {
          _featureStatus[feature] = true;
        });
      }
    } catch (e) {
      // Handle purchase error
      if (mounted) {
        _showPurchaseError('Failed to purchase feature: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _loadingStatus[feature] = false;
        });
      }
    }
  }
  
  Future<void> _purchasePremium() async {
    setState(() {
      for (final feature in PremiumFeature.values) {
        _loadingStatus[feature] = true;
      }
    });
    
    try {
      final success = await _premiumManager.purchasePremium();
      if (success && mounted) {
        await _loadPremiumStatus();
      }
    } catch (e) {
      // Handle purchase error
      if (mounted) {
        _showPurchaseError('Failed to purchase premium: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          for (final feature in PremiumFeature.values) {
            _loadingStatus[feature] = false;
          }
        });
      }
    }
  }
  
  void _showPurchaseError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Purchase Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeNotifier>(context);
    final theme = themeManager.currentTheme;
    
    return CupertinoPageScaffold(
      backgroundColor: theme.backgroundColor,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: theme.backgroundColor.withOpacity(0.9),
        middle: Text(
          'Premium Features',
          style: TextStyle(color: theme.textColor),
        ),
        border: null,
      ),
      child: ResponsiveLayout(
        padding: EdgeInsets.zero,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _buildHeaderCard(theme),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'AVAILABLE FEATURES',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: theme.primaryColor,
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final feature = PremiumFeature.values[index];
                  return _buildFeatureCard(feature, theme);
                },
                childCount: PremiumFeature.values.length,
              ),
            ),
            SliverToBoxAdapter(
              child: _buildPremiumBundleCard(theme),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: 16),
            ),
            if (!kIsWeb && !_isPremium)
              SliverToBoxAdapter(
                child: AdBannerWidget(
                  alignment: Alignment.center,
                  margin: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            SliverToBoxAdapter(
              child: SizedBox(height: 16),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeaderCard(theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: AdaptiveCard(
        backgroundColor: theme.displayColor,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  CupertinoIcons.star_circle_fill,
                  color: theme.primaryColor,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Text(
                  'Upgrade Your Calculator',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Unlock powerful features to enhance your calculator experience.',
              style: TextStyle(
                fontSize: 16,
                color: theme.textColor.withOpacity(0.8),
              ),
            ),
            if (_isPremium) 
              ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        CupertinoIcons.checkmark_circle_fill,
                        color: theme.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'You have Premium access!',
                        style: TextStyle(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildFeatureCard(PremiumFeature feature, theme) {
    final isUnlocked = _featureStatus[feature] ?? false;
    final isLoading = _loadingStatus[feature] ?? false;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: AdaptiveCard(
        backgroundColor: theme.displayColor,
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                PremiumFeaturesPage.getFeatureIcon(feature),
                color: theme.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    PremiumFeaturesPage.getFeatureTitle(feature),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    PremiumFeaturesPage.getFeatureDescription(feature),
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.textColor.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (isUnlocked)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CupertinoIcons.checkmark_circle_fill,
                      color: theme.primaryColor,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Unlocked',
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
            else
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: isLoading ? null : () => _purchaseFeature(feature),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: isLoading
                      ? CupertinoActivityIndicator(color: CupertinoColors.white)
                      : Text(
                          'Unlock',
                          style: TextStyle(
                            color: CupertinoColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPremiumBundleCard(theme) {
    final allFeaturesUnlocked = _isPremium || 
        PremiumFeature.values.every((feature) => _featureStatus[feature] ?? false);
    final isLoading = PremiumFeature.values.any((feature) => _loadingStatus[feature] ?? false);
    
    if (allFeaturesUnlocked) {
      return SizedBox.shrink();
    }
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: AdaptiveCard(
        backgroundColor: theme.primaryColor.withOpacity(0.1),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  CupertinoIcons.star_circle_fill,
                  color: theme.primaryColor,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Premium Bundle',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: theme.textColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Get all premium features at a discounted price. Unlock everything and enhance your calculator experience.',
              style: TextStyle(
                fontSize: 16,
                color: theme.textColor.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 24),
            AdaptiveButton(
              text: 'Get Premium Bundle',
              onPressed: isLoading ? () {} : _purchasePremium,
              isLoading: isLoading,
              backgroundColor: theme.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              textColor: CupertinoColors.white,
            ),
          ],
        ),
      ),
    );
  }
}