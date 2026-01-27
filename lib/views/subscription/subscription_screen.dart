import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/subscription_service.dart';
import '../../models/subscription_model.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final subscriptionService = Get.put(SubscriptionService());

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Go Premium', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF8F66FF),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        if (subscriptionService.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF8F66FF)));
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // Header Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF8F66FF), Color(0xFF2D1B69)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.workspace_premium, size: 80, color: Color(0xFFD4AF37)),
                    const SizedBox(height: 16),
                    Text(
                      'Remove All Ads',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enjoy an ad-free experience',
                      style: GoogleFonts.poppins(fontSize: 16, color: Colors.white70),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Benefits Section
              _buildBenefitsSection(),

              const SizedBox(height: 24),

              // Subscription Plans
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose Your Plan',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2D1B69),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Subscription Cards
                    if (subscriptionService.availableProducts.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              const Icon(Icons.error_outline, size: 60, color: Colors.grey),
                              const SizedBox(height: 16),
                              Text(
                                'No subscriptions available',
                                style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () => subscriptionService.loadProducts(),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...subscriptionService.availableProducts.map(
                        (product) => _buildSubscriptionCard(context, product, subscriptionService),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Restore Purchases Button
              TextButton.icon(
                onPressed: () => subscriptionService.restorePurchases(),
                icon: const Icon(Icons.restore),
                label: const Text('Restore Purchases'),
                style: TextButton.styleFrom(foregroundColor: const Color(0xFF8F66FF)),
              ),

              const SizedBox(height: 8),

              // Terms & Privacy
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Auto-renewable. Cancel anytime.\nManage subscriptions in your Google Play account.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildBenefitsSection() {
    final benefits = [
      {'icon': Icons.block, 'title': 'No Ads', 'description': 'Enjoy uninterrupted experience'},
      {'icon': Icons.speed, 'title': 'Faster', 'description': 'No ad loading delays'},
      {
        'icon': Icons.battery_charging_full,
        'title': 'Save Battery',
        'description': 'Less battery usage without ads',
      },
      {'icon': Icons.data_usage, 'title': 'Save Data', 'description': 'Reduce data consumption'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Premium Benefits',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2D1B69),
                ),
              ),
              const SizedBox(height: 16),
              ...benefits.map(
                (benefit) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8F66FF).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          benefit['icon'] as IconData,
                          color: const Color(0xFF8F66FF),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              benefit['title'] as String,
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
                            ),
                            Text(
                              benefit['description'] as String,
                              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubscriptionCard(
    BuildContext context,
    SubscriptionProduct product,
    SubscriptionService service,
  ) {
    final isYearly = product.isYearly;
    final isPopular = isYearly;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPopular ? const Color(0xFFD4AF37) : Colors.grey[300]!,
          width: isPopular ? 2 : 1,
        ),
      ),
      child: Stack(
        children: [
          // Popular badge
          if (isPopular)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: const BoxDecoration(
                  color: Color(0xFFD4AF37),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(14),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: Text(
                  'BEST VALUE',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.durationText,
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2D1B69),
                            ),
                          ),
                          if (product.savings.isNotEmpty)
                            Text(
                              product.savings,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.green[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          product.price,
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF8F66FF),
                          ),
                        ),
                        Text(
                          product.currencyCode,
                          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: Obx(
                    () => ElevatedButton(
                      onPressed: service.isPurchasing.value
                          ? null
                          : () => service.purchaseSubscription(product.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isPopular
                            ? const Color(0xFFD4AF37)
                            : const Color(0xFF8F66FF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: service.isPurchasing.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              'Subscribe Now',
                              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
