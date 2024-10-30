// import 'package:flutter/cupertino.dart';
// import 'package:myapp/ad_manager.dart';

// class PremiumFeaturesPage extends StatelessWidget {
//   const PremiumFeaturesPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return CupertinoPageScaffold(
//       navigationBar: const CupertinoNavigationBar(
//         middle: Text('Premium Features'),
//       ),
//       child: SafeArea(
//         child: ListView(
//           children: PremiumFeature.values.map((feature) {
//             return CupertinoListTile(
//               title: Text(_getFeatureTitle(feature)),
//               subtitle: Text(_getFeatureDescription(feature)),
//               trailing: AdManager.instance.hasFeature(feature)
//                   ? const Icon(CupertinoIcons.check_mark_circled, color: CupertinoColors.activeGreen)
//                   : CupertinoButton(
//                       padding: EdgeInsets.zero,
//                       child: const Text('Unlock'),
//                       onPressed: () => AdManager.instance.showPremiumFeaturePromo(feature),
//                     ),
//             );
//           }).toList(),
//         ),
//       ),
//     );
//   }

//   String _getFeatureTitle(PremiumFeature feature) {
//     switch (feature) {
//       case PremiumFeature.noAds:
//         return 'Ad-Free Experience';
//       case PremiumFeature.historyExport:
//         return 'Export History';
//       case PremiumFeature.customThemes:
//         return 'Custom Themes';
//       case PremiumFeature.cloudBackup:
//         return 'Cloud Backup';
//       case PremiumFeature.scientificMode:
//         return 'Scientific Calculator';
//       case PremiumFeature.currencyConverter:
//         return 'Currency Converter';
//     }
//   }

//   String _getFeatureDescription(PremiumFeature feature) {
//     switch (feature) {
//       case PremiumFeature.noAds:
//         return 'Remove all advertisements';
//       case PremiumFeature.historyExport:
//         return 'Export calculation history to CSV or PDF';
//       case PremiumFeature.customThemes:
//         return 'Create and save custom calculator themes';
//       case PremiumFeature.cloudBackup:
//         return 'Backup your history and settings to the cloud';
//       case PremiumFeature.scientificMode:
//         return 'Access advanced scientific calculator functions';
//       case PremiumFeature.currencyConverter:
//         return 'Convert between different currencies';
//     }
//   }
// }