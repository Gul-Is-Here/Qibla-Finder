import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/ads/ad_service.dart';

/// Middleware to track screen navigation and show interstitial ads automatically
class AdTrackingMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    // Track screen navigation
    try {
      final adService = Get.find<AdService>();
      adService.trackScreenNavigation();
    } catch (e) {
      // AdService might not be initialized yet
      print('AdService not found: $e');
    }
    return null;
  }

  @override
  GetPage? onPageCalled(GetPage? page) {
    print('📍 Navigating to: ${page?.name}');
    return super.onPageCalled(page);
  }

  @override
  Widget onPageBuilt(Widget page) {
    print('🏗️ Page built successfully');
    return page;
  }

  @override
  void onPageDispose() {
    print('🗑️ Page disposed');
    super.onPageDispose();
  }
}
