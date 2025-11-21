import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/api_service.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  bool _isLoading = true;
  bool _backendOnline = false;
  String _statusMessage = 'Checking connection...';

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final healthResult = await ApiService.checkHealth();
      final isOnline = healthResult['success'] == true;
      setState(() {
        _backendOnline = isOnline;
        _statusMessage = isOnline
            ? 'Backend is online and connected!'
            : 'Backend is offline - using local data';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _backendOnline = false;
        _statusMessage = 'Connection error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Status'),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Icon(
                      _isLoading
                          ? Icons.hourglass_empty
                          : _backendOnline
                          ? Icons.cloud_done
                          : Icons.cloud_off,
                      size: 60,
                      color: _isLoading
                          ? Colors.orange
                          : _backendOnline
                          ? Colors.green
                          : Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _isLoading ? 'Checking...' : 'Backend Status',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _statusMessage,
                      style: TextStyle(
                        fontSize: 16,
                        color: _isLoading
                            ? Colors.orange
                            : _backendOnline
                            ? Colors.green
                            : Colors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _checkStatus,
                      child: const Text('Refresh Status'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Consumer<AppProvider>(
              builder: (context, appProvider, child) {
                return Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'App Data',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Coins:'),
                            Text(
                              '${appProvider.coins}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2196F3),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Lessons:'),
                            Text(
                              '${appProvider.lessons.length}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2196F3),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Transactions:'),
                            Text(
                              '${appProvider.transactions.length}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2196F3),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
