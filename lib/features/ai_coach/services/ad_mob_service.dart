import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  static final AdMobService _instance = AdMobService._internal();
  factory AdMobService() => _instance;
  AdMobService._internal();

  RewardedAd? _rewardedAd;
  bool _isAdLoaded = false;

  // Test Unit IDs for Rewarded Video Ads
  final String _androidTestUnitId = 'ca-app-pub-3940256099942544/5224354917';
  final String _iosTestUnitId = 'ca-app-pub-3940256099942544/1712482638';

  String get _adUnitId {
    if (Platform.isAndroid) {
      return _androidTestUnitId;
    } else if (Platform.isIOS) {
      return _iosTestUnitId;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  /// Reklamı yükle
  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('✅ Rewarded Ad loaded.');
          _rewardedAd = ad;
          _isAdLoaded = true;
        },
        onAdFailedToLoad: (error) {
          debugPrint('❌ Rewarded Ad failed to load: $error');
          _rewardedAd = null;
          _isAdLoaded = false;
        },
      ),
    );
  }

  /// Reklamı göster ve izlenme başarılı olursa callback çağır
  void showRewardedAd(
      {required VoidCallback onEarnedReward, VoidCallback? onClosed}) {
    if (_rewardedAd == null || !_isAdLoaded) {
      debugPrint('⚠️ Warning: Rewarded Ad is not loaded yet.');
      // Eğer yüklenmemişse bir sonraki deneme için tetikleyelim.
      loadRewardedAd();

      // İzlenmemiş sayabilir ya da kullanıcıyı bekletebilirdik.
      // Şimdilik reklam yoksa direkt hak veriyoruz ki kullanıcı takılmasın (fallback).
      onEarnedReward();
      if (onClosed != null) onClosed();
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) =>
          debugPrint('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _rewardedAd = null;
        _isAdLoaded = false;
        // Kapatıldığında yenisini yükleyelim
        loadRewardedAd();
        if (onClosed != null) onClosed();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _rewardedAd = null;
        _isAdLoaded = false;
        if (onClosed != null) onClosed();
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        debugPrint('🎉 User earned reward: ${reward.amount} ${reward.type}');
        onEarnedReward();
      },
    );
  }
}
