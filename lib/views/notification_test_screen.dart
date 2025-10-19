import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/notification_service.dart';
import '../services/prayer_times_database.dart';

class NotificationTestScreen extends StatelessWidget {
  const NotificationTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Test'),
        backgroundColor: const Color(0xFF00897B),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.notifications_active,
                  color: Color(0xFF00897B),
                ),
                title: const Text('Test Immediate Notification'),
                subtitle: const Text('Triggers in 5 seconds'),
                trailing: ElevatedButton(
                  onPressed: () async {
                    await NotificationService.instance.scheduleAzanNotification(
                      id: 999,
                      prayerName: 'Test Prayer',
                      prayerTime: DateTime.now().add(
                        const Duration(seconds: 5),
                      ),
                      locationName: 'Test Location',
                    );

                    Get.snackbar(
                      'Success',
                      'Test notification scheduled for 5 seconds from now',
                      backgroundColor: const Color(0xFF00897B),
                      colorText: Colors.white,
                    );
                  },
                  child: const Text('Test'),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.list, color: Color(0xFF00897B)),
                title: const Text('View Scheduled Notifications'),
                subtitle: const Text('See all upcoming notifications'),
                trailing: ElevatedButton(
                  onPressed: () async {
                    final notifications = await NotificationService.instance
                        .getScheduledNotifications();

                    Get.dialog(
                      AlertDialog(
                        title: const Text('Scheduled Notifications'),
                        content: SizedBox(
                          width: double.maxFinite,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: notifications.length,
                            itemBuilder: (context, index) {
                              final notification = notifications[index];
                              return ListTile(
                                title: Text(
                                  notification.content?.title ?? 'No title',
                                ),
                                subtitle: Text(
                                  'ID: ${notification.content?.id}\n${notification.content?.body ?? ''}',
                                ),
                              );
                            },
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('View'),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Cancel All Notifications'),
                subtitle: const Text('Remove all scheduled notifications'),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () async {
                    await NotificationService.instance.cancelAllNotifications();
                    Get.snackbar(
                      'Success',
                      'All notifications cancelled',
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  },
                  child: const Text('Cancel All'),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.storage, color: Color(0xFF00897B)),
                title: const Text('Check Database'),
                subtitle: const Text('View cached prayer times'),
                trailing: ElevatedButton(
                  onPressed: () async {
                    final db = PrayerTimesDatabase.instance;
                    final upcoming = await db.getUpcomingPrayerTimes(
                      DateTime.now(),
                      31.5204, // Example coordinates
                      74.3587,
                    );

                    Get.dialog(
                      AlertDialog(
                        title: const Text('Cached Prayer Times'),
                        content: SizedBox(
                          width: double.maxFinite,
                          child: upcoming.isEmpty
                              ? const Text('No cached data found')
                              : ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: upcoming.length,
                                  itemBuilder: (context, index) {
                                    final prayer = upcoming[index];
                                    return ListTile(
                                      title: Text(prayer.date),
                                      subtitle: Text(
                                        'Fajr: ${prayer.fajr}\nDhuhr: ${prayer.dhuhr}',
                                      ),
                                    );
                                  },
                                ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('Check'),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF00897B),
                ),
                title: const Text('Check Permissions'),
                subtitle: const Text('Verify notification permissions'),
                trailing: ElevatedButton(
                  onPressed: () async {
                    final isEnabled = await NotificationService.instance
                        .areNotificationsEnabled();

                    Get.snackbar(
                      isEnabled ? 'Enabled' : 'Disabled',
                      isEnabled
                          ? 'Notifications are enabled'
                          : 'Please enable notifications in app settings',
                      backgroundColor: isEnabled
                          ? const Color(0xFF00897B)
                          : Colors.orange,
                      colorText: Colors.white,
                    );
                  },
                  child: const Text('Check'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
