import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/version_service.dart';

class ForceUpdateScreen extends StatelessWidget {
  final VersionCheckResult versionResult;

  const ForceUpdateScreen({Key? key, required this.versionResult})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.system_update,
                  size: 60,
                  color: Colors.blue.shade600,
                ),
              ),

              const SizedBox(height: 32),

              // Title
              Text(
                versionResult.maintenanceMode
                    ? 'Maintenance Mode'
                    : versionResult.versionInfo?.updateTitle ??
                          'Update Required',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Message
              Text(
                versionResult.maintenanceMode
                    ? versionResult.error ??
                          'The app is currently under maintenance. Please try again later.'
                    : versionResult.versionInfo?.updateMessage ??
                          'A new version is available with important updates.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Version Info
              if (versionResult.versionInfo != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      _buildVersionRow(
                        'Current Version',
                        '${VersionService.instance.currentVersion} (${VersionService.instance.currentBuildNumber})',
                      ),
                      const SizedBox(height: 8),
                      _buildVersionRow(
                        'Latest Version',
                        '${versionResult.versionInfo!.latestVersion} (${versionResult.versionInfo!.latestBuildNumber})',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // Update Button
              if (!versionResult.maintenanceMode) ...[
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _handleUpdate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Update Now',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Retry Button (for non-force updates)
                if (!versionResult.forceUpdate) ...[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Continue Anyway',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ],

              // Maintenance Mode Message
              if (versionResult.maintenanceMode) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.orange.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'We\'re working hard to improve your experience. Please check back soon!',
                          style: TextStyle(
                            color: Colors.orange.shade800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVersionRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _handleUpdate() async {
    final downloadUrl = VersionService.instance.getDownloadUrl();

    if (downloadUrl.isNotEmpty) {
      try {
        final uri = Uri.parse(downloadUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          // Fallback to Play Store search
          final playStoreUri = Uri.parse(
            'https://play.google.com/store/apps/details?id=com.example.learn_earn_mobile',
          );
          if (await canLaunchUrl(playStoreUri)) {
            await launchUrl(playStoreUri, mode: LaunchMode.externalApplication);
          }
        }
      } catch (e) {
        // Handle error - maybe show a snackbar or dialog
        print('Failed to launch URL: $e');
      }
    }
  }
}
