import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qibla_compass_offline/constants/strings.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('About ', style: GoogleFonts.poppins()),
        centerTitle: true,
        backgroundColor: Color(0xFF00332F),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoCard(
              qiblaIcons3,
              icon: Icons.explore,
              title: 'Qibla Compass',
              subtitle: 'Version 1.0.0',
              theme: theme,
            ),
            const SizedBox(height: 20),
            _sectionCard(
              icon: Icons.info_outline,
              title: 'About the App',
              content:
                  'This app helps Muslims find the Qibla direction (direction to the Kaaba in Makkah) using your device\'s sensors. It works both online and offline.',
              theme: theme,
            ),
            const SizedBox(height: 20),
            _sectionCard(
              icon: Icons.settings_input_antenna,
              title: 'How it Works',
              content:
                  'The app uses your device\'s compass to determine the direction you\'re facing and calculates the angle to the Qibla based on your current location. When online, it can use network location for better accuracy.',
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(
    String image, {
    required IconData icon,
    required String title,
    required String subtitle,
    required ThemeData theme,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Row(
          children: [
            Image.asset(qiblaIcon2, width: 60),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: theme.textTheme.bodyMedium),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({
    required IconData icon,
    required String title,
    required String content,
    required ThemeData theme,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: theme.colorScheme.surfaceVariant,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(content, style: GoogleFonts.poppins()),
          ],
        ),
      ),
    );
  }
}
