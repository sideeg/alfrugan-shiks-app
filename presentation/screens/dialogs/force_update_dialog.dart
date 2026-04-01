// lib/presentation/screens/dialogs/force_update_dialog.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ForceUpdateDialog extends StatelessWidget {
  final String currentVersion;
  final String requiredVersion;
  final String appStoreUrl; // iOS App Store link
  final String playStoreUrl; // Google Play Store link
  final bool isDark;

  const ForceUpdateDialog({
    required this.currentVersion,
    required this.requiredVersion,
    required this.appStoreUrl,
    required this.playStoreUrl,
    required this.isDark,
    Key? key,
  }) : super(key: key);

  Future<void> _openAppStore() async {
    try {
      // Try to open the appropriate store
      if (await canLaunchUrl(Uri.parse(playStoreUrl))) {
        await launchUrl(
          Uri.parse(playStoreUrl),
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      print('Error launching app store: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFD4A843);
    const navy = Color(0xFF0B1120);
    const navyMid = Color(0xFF111D35);
    const cream = Color(0xFFF5EDD8);

    return WillPopScope(
      onWillPop: () async => false, // ✅ Prevent back button
      child: Dialog(
        backgroundColor: isDark ? navyMid : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: gold.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.system_update_rounded,
                  size: 35,
                  color: gold,
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                'تحديث مهم متاح',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? cream : navy,
                ),
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                'يجب تحديث التطبيق إلى الإصدار الأحدث للمتابعة',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 16),

              // Version info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.grey[900]
                      : Colors.grey.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: gold.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      textDirection: TextDirection.rtl,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'الإصدار الحالي:',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[500] : Colors.grey[600],
                          ),
                        ),
                        Text(
                          currentVersion,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark ? cream : navy,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      textDirection: TextDirection.rtl,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'الإصدار المطلوب:',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[500] : Colors.grey[600],
                          ),
                        ),
                        Text(
                          requiredVersion,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: gold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Update button (only option)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _openAppStore,
                  icon: const Icon(Icons.download_rounded, size: 18),
                  label: const Text(
                    'تحديث الآن',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gold,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Info text
              Text(
                'لن تتمكن من استخدام التطبيق حتى التحديث',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.orange[600],
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
