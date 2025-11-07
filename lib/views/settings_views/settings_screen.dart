import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/compass_controller/qibla_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final QiblaController controller = Get.find<QiblaController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF8F66FF),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFE8E4F3),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Compass Settings',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF2D1B69),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(
                    () => SwitchListTile(
                      title: const Text(
                        'Vibration Feedback',
                        style: TextStyle(color: Color(0xFF2D1B69)),
                      ),
                      subtitle: const Text(
                        'Vibrate when pointing to Qibla',
                        style: TextStyle(color: Colors.grey),
                      ),
                      value: controller.isVibrationEnabled.value,
                      onChanged: controller.toggleVibration,
                      activeThumbColor: const Color(0xFF8F66FF),
                    ),
                  ),
                  Obx(
                    () => SwitchListTile(
                      title: const Text(
                        'Sound Effects',
                        style: TextStyle(color: Color(0xFF2D1B69)),
                      ),
                      subtitle: const Text(
                        'Play sound when pointing to Qibla',
                        style: TextStyle(color: Colors.grey),
                      ),
                      value: controller.isSoundEnabled.value,
                      onChanged: controller.toggleSound,
                      activeThumbColor: const Color(0xFF8F66FF),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Appearance',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF2D1B69),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    title: const Text('Theme', style: TextStyle(color: Color(0xFF2D1B69))),
                    subtitle: const Text(
                      'Light purple theme applied',
                      style: TextStyle(color: Colors.grey),
                    ),
                    trailing: const Icon(Icons.chevron_right, color: Color(0xFF8F66FF)),
                    onTap: () {
                      Get.snackbar(
                        'Theme',
                        'Prayer Times theme is applied',
                        backgroundColor: const Color(0xFF8F66FF).withOpacity(0.9),
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
