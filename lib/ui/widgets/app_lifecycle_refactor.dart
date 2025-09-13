import 'dart:developer';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:prime_web/ui/widgets/admob_service.dart';

/// Listens for app foreground events and shows app open ads.
class AppLifecycleReactor {
  AppLifecycleReactor({required this.appOpenAdManager});
  final AdMobService appOpenAdManager;

  void listenToAppStateChanges() {
    log('listening');
    AppStateEventNotifier.startListening();
    AppStateEventNotifier.appStateStream.forEach(_onAppStateChanged);
  }

  void _onAppStateChanged(AppState appState) {
    // Try to show an app open ad if the app is being resumed and
    // we're not already showing an app open ad.
    log('$appState');
    if (appState == AppState.foreground) {
      appOpenAdManager.showAdIfAvailable();
    }
  }
}
