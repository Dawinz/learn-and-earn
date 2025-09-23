import 'package:flutter/material.dart';
import '../services/ad_service.dart';

class RewardedAdButton extends StatefulWidget {
  final String text;
  final VoidCallback? onRewardEarned;
  final VoidCallback? onAdFailed;
  final Widget? child;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;

  const RewardedAdButton({
    super.key,
    required this.text,
    this.onRewardEarned,
    this.onAdFailed,
    this.child,
    this.backgroundColor,
    this.textColor,
    this.padding,
    this.borderRadius,
  });

  @override
  State<RewardedAdButton> createState() => _RewardedAdButtonState();
}

class _RewardedAdButtonState extends State<RewardedAdButton> {
  bool _isLoading = false;

  Future<void> _showRewardedAd() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final reward = await AdService.instance.showRewardedAd();

      if (reward != null) {
        // Ad was shown and user earned reward
        if (widget.onRewardEarned != null) {
          widget.onRewardEarned!();
        }

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('You earned ${reward.amount} ${reward.type}!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Ad failed to show or user didn't complete it
        if (widget.onAdFailed != null) {
          widget.onAdFailed!();
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ad not available. Please try again later.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (widget.onAdFailed != null) {
        widget.onAdFailed!();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error showing ad: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _isLoading ? null : _showRewardedAd,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            widget.backgroundColor ?? Theme.of(context).primaryColor,
        foregroundColor: widget.textColor ?? Colors.white,
        padding:
            widget.padding ??
            const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
        ),
      ),
      child: _isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : widget.child ?? Text(widget.text),
    );
  }
}
