import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/qibla_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final QiblaController controller = Get.find<QiblaController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF00332F),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFF00332F),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Colors.white.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Compass Settings',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(
                    () => SwitchListTile(
                      title: const Text(
                        'Vibration Feedback',
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: const Text(
                        'Vibrate when pointing to Qibla',
                        style: TextStyle(color: Colors.white70),
                      ),
                      value: controller.isVibrationEnabled.value,
                      onChanged: controller.toggleVibration,
                      activeColor: const Color(0xFF8BC34A),
                    ),
                  ),
                  Obx(
                    () => SwitchListTile(
                      title: const Text(
                        'Sound Effects',
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: const Text(
                        'Play sound when pointing to Qibla',
                        style: TextStyle(color: Colors.white70),
                      ),
                      value: controller.isSoundEnabled.value,
                      onChanged: controller.toggleSound,
                      activeColor: const Color(0xFF8BC34A),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: Colors.white.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Appearance',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    title: const Text(
                      'Theme',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: const Text(
                      'Dark theme applied',
                      style: TextStyle(color: Colors.white70),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                    ),
                    onTap: () {
                      Get.snackbar(
                        'Theme',
                        'Custom dark theme is already applied',
                        backgroundColor: const Color(
                          0xFF8BC34A,
                        ).withOpacity(0.9),
                        colorText: Colors.white,
                        borderRadius: 12,
                        margin: const EdgeInsets.all(16),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
