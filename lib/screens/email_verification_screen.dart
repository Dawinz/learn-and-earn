import 'package:flutter/material.dart';
import '../services/email_linking_service.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';

/// Screen for email verification using OTP
class EmailVerificationScreen extends StatefulWidget {
  final String email;
  final String? referralCode;

  const EmailVerificationScreen({
    super.key,
    required this.email,
    this.referralCode,
  });

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final _otpController = TextEditingController();
  bool _isLoading = false;
  bool _isSendingOtp = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    // Automatically send OTP when screen loads
    _sendOtp();
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    setState(() {
      _isSendingOtp = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final result = await EmailLinkingService.sendOtp(
        email: widget.email,
        referralCode: widget.referralCode,
      );

      if (result['success'] == true) {
        setState(() {
          _successMessage =
              result['message'] ?? 'Verification code sent to your email';
          _isSendingOtp = false;
        });
      } else {
        setState(() {
          _errorMessage =
              result['message'] ?? 'Failed to send verification code';
          _isSendingOtp = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isSendingOtp = false;
      });
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter the verification code';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final result = await EmailLinkingService.verifyOtp(
        email: widget.email,
        otpCode: _otpController.text.trim(),
      );

      if (result['success'] == true) {
        // Email has been linked to the device-based user account
        // The EmailLinkingService already updated the email in users_public
        // We keep using the device session (don't replace it with email session)

        // If referral code was used, record it
        if (widget.referralCode != null) {
          try {
            final userId = await StorageService.getUserId();
            if (userId != null) {
              await ApiService.claimReferral(
                referralCode: widget.referralCode!,
              );
            }
          } catch (e) {
            // Don't fail the email linking if referral fails
            print('Failed to record referral: $e');
          }
        }

        // Show success message
        setState(() {
          _successMessage = result['message'] ?? 'Email successfully linked!';
          _isLoading = false;
        });

        // Wait a moment to show success message, then navigate back
        await Future.delayed(const Duration(seconds: 1));

        if (mounted) {
          Navigator.of(context).pop(true); // Return true to indicate success
        }
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Invalid verification code';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Verification failed: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              // Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.email_outlined,
                  size: 50,
                  color: Color(0xFF2196F3),
                ),
              ),

              const SizedBox(height: 24),

              // Title
              const Text(
                'Check Your Email',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2196F3),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Description
              Text(
                'We sent a verification code to\n${widget.email}',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Success/Error Messages
              if (_successMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _successMessage!,
                          style: const TextStyle(color: Colors.green),
                        ),
                      ),
                    ],
                  ),
                ),

              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),

              // OTP Input
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                ),
                decoration: InputDecoration(
                  labelText: 'Verification Code',
                  hintText: 'Enter 6-8 digit code',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF2196F3)),
                  ),
                ),
                maxLength: 10,
              ),

              const SizedBox(height: 24),

              // Verify Button
              ElevatedButton(
                onPressed: _isLoading ? null : _verifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'Verify',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),

              const SizedBox(height: 16),

              // Resend Code
              TextButton(
                onPressed: _isSendingOtp ? null : _sendOtp,
                child: _isSendingOtp
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Resend Code',
                        style: TextStyle(
                          color: Color(0xFF2196F3),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),

              const SizedBox(height: 24),

              // Help Text
              Text(
                'Didn\'t receive the code? Check your spam folder or try resending.',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
