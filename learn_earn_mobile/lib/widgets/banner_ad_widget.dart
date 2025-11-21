import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';

class BannerAdWidget extends StatefulWidget {
  final double? height;
  final EdgeInsets? margin;
  final Color? backgroundColor;

  const BannerAdWidget({
    super.key,
    this.height,
    this.margin,
    this.backgroundColor,
  });

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  bool _isAdFailed = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    // Dispose previous ad if exists
    _bannerAd?.dispose();
    
    _bannerAd = AdService.instance.createBannerAd();
    
    // Update listener to check if widget is still mounted
    _bannerAd!.load().then((_) {
      if (mounted && !_isDisposed) {
        setState(() {
          _isAdLoaded = true;
          _isAdFailed = false;
        });
      } else {
        _bannerAd?.dispose();
      }
    }).catchError((error) {
      if (mounted && !_isDisposed) {
        setState(() {
          _isAdLoaded = false;
          _isAdFailed = true;
        });
      }
      _bannerAd?.dispose();
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isAdFailed) {
      return const SizedBox.shrink();
    }

    if (!_isAdLoaded || _bannerAd == null) {
      return Container(
        height: widget.height ?? 50,
        margin: widget.margin ?? const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      height: (widget.height ?? 50) + 20, // Extra space for label
      margin: widget.margin ?? const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Ad Label
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: const Text(
              'Advertisement',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Ad Content
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
              child: _bannerAd != null && _isAdLoaded && !_isDisposed
                  ? AdWidget(ad: _bannerAd!)
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}
