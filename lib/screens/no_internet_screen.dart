import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/connectivity_service.dart';

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // No Internet Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.wifi_off_rounded,
                  size: 60,
                  color: Colors.red,
                ),
              ),

              const SizedBox(height: 32),

              // Title
              const Text(
                'No Internet Connection',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Description
              const Text(
                'Please check your internet connection and try again. This app requires an active internet connection to function properly.',
                style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Retry Button
              Consumer<ConnectivityService>(
                builder: (context, connectivityService, child) {
                  return ElevatedButton(
                    onPressed: () async {
                      // Check connectivity again
                      await connectivityService.hasInternetConnection();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.refresh, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Retry Connection',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Connection Status Indicator
              Consumer<ConnectivityService>(
                builder: (context, connectivityService, child) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: connectivityService.isConnected
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: connectivityService.isConnected
                            ? Colors.green
                            : Colors.red,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          connectivityService.isConnected
                              ? Icons.wifi
                              : Icons.wifi_off,
                          size: 16,
                          color: connectivityService.isConnected
                              ? Colors.green
                              : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          connectivityService.isConnected
                              ? 'Connected'
                              : 'Disconnected',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: connectivityService.isConnected
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
