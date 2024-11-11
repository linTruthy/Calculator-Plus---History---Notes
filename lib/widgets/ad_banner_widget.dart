import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../services/ad_manager.dart';

class AdBannerWidget extends StatefulWidget {
  final AdSize? adSize;
  final Alignment? alignment;
  final EdgeInsets? margin;

  const AdBannerWidget({
    super.key,
    this.adSize,
    this.alignment,
    this.margin,
  });

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AdManager().bannerAdUnitId,
      size: widget.adSize ?? AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() {}),
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

  @override
  Widget build(BuildContext context) {
    if (_bannerAd == null || _bannerAd?.size.height == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      alignment: widget.alignment ?? Alignment.center,
      margin: widget.margin,
      width: _bannerAd?.size.width.toDouble(),
      height: _bannerAd?.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
