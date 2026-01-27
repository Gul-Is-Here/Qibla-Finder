import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_pages.dart';
import '../../services/subscription_service.dart';

/// Widget that shows a subscription prompt in place of ads
/// Displays when user is not premium
class SubscriptionPromptBanner extends StatelessWidget {
  final EdgeInsets? padding;
  final bool showGoldVariant;

  const SubscriptionPromptBanner({super.key, this.padding, this.showGoldVariant = false});

  @override
  Widget build(BuildContext context) {
    // Safe check - service might not be initialized yet
    if (!Get.isRegistered<SubscriptionService>()) {
      // Service not ready, show prompt anyway (will be hidden once user subscribes)
      return _buildPromptBanner();
    }

    final subscriptionService = Get.find<SubscriptionService>();

    return Obx(() {
      // Don't show if user is already premium
      if (subscriptionService.isPremium) {
        return const SizedBox.shrink();
      }

      return _buildPromptBanner();
    });
  }

  Widget _buildPromptBanner() {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: InkWell(
        onTap: () {
          Get.toNamed(Routes.SUBSCRIPTION);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            gradient: showGoldVariant
                ? const LinearGradient(
                    colors: [Color(0xFFD4AF37), Color(0xFFFFD700)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : const LinearGradient(
                    colors: [Color(0xFF8F66FF), Color(0xFF2D1B69)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: showGoldVariant
                    ? const Color(0xFFD4AF37).withOpacity(0.3)
                    : const Color(0xFF8F66FF).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon Section
              Container(
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: const Icon(Icons.star_rounded, color: Colors.white, size: 30),
              ),

              // Text Section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Remove Ads Forever',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'From Rs. 50/month only',
                        style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),

              // Button Section
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Go Premium',
                  style: TextStyle(
                    color: showGoldVariant ? const Color(0xFFD4AF37) : const Color(0xFF8F66FF),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
