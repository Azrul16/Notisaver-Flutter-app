import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.darkModeEnabled,
    required this.autoDeleteDays,
    required this.notificationAccessEnabled,
    required this.batteryOptimizationIgnored,
    required this.onDarkModeChanged,
    required this.onAutoDeleteDaysChanged,
    required this.onOpenNotificationAccess,
    required this.onOpenBatterySettings,
    required this.onOpenAppFilter,
    required this.onClearAll,
  });

  final bool darkModeEnabled;
  final int autoDeleteDays;
  final bool notificationAccessEnabled;
  final bool batteryOptimizationIgnored;
  final Future<void> Function(bool value) onDarkModeChanged;
  final Future<void> Function(int value) onAutoDeleteDaysChanged;
  final Future<void> Function() onOpenNotificationAccess;
  final Future<void> Function() onOpenBatterySettings;
  final Future<void> Function() onOpenAppFilter;
  final Future<void> Function() onClearAll;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Card(
            child: Column(
              children: <Widget>[
                SwitchListTile(
                  title: const Text('Dark mode'),
                  subtitle: const Text('Switch between light and dark themes.'),
                  value: darkModeEnabled,
                  onChanged: (value) => onDarkModeChanged(value),
                ),
                ListTile(
                  title: const Text('Auto-delete after'),
                  subtitle: Text('$autoDeleteDays days'),
                  trailing: DropdownButton<int>(
                    value: autoDeleteDays,
                    underline: const SizedBox.shrink(),
                    items: const <DropdownMenuItem<int>>[
                      DropdownMenuItem(value: 7, child: Text('7 days')),
                      DropdownMenuItem(value: 15, child: Text('15 days')),
                      DropdownMenuItem(value: 30, child: Text('30 days')),
                      DropdownMenuItem(value: 90, child: Text('90 days')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        onAutoDeleteDaysChanged(value);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: <Widget>[
                ListTile(
                  title: const Text('Notification access'),
                  subtitle: Text(
                    notificationAccessEnabled ? 'Connected' : 'Needs attention',
                  ),
                  trailing: TextButton(
                    onPressed: onOpenNotificationAccess,
                    child: const Text('Open'),
                  ),
                ),
                ListTile(
                  title: const Text('Battery optimization'),
                  subtitle: Text(
                    batteryOptimizationIgnored ? 'Optimized for reliability' : 'Recommended to update',
                  ),
                  trailing: TextButton(
                    onPressed: onOpenBatterySettings,
                    child: const Text('Open'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: <Widget>[
                ListTile(
                  title: const Text('App filter'),
                  subtitle: const Text('Choose which apps appear in NotiSaver.'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: onOpenAppFilter,
                ),
                ListTile(
                  title: const Text('Clear notification history'),
                  subtitle: const Text('Remove all saved notifications from this device.'),
                  trailing: const Icon(Icons.delete_outline_rounded),
                  onTap: () async {
                    final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            title: const Text('Clear notification history?'),
                            content: const Text(
                              'This will remove all saved notifications from NotiSaver on this device.',
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(dialogContext).pop(false),
                                child: const Text('Cancel'),
                              ),
                              FilledButton(
                                onPressed: () =>
                                    Navigator.of(dialogContext).pop(true),
                                child: const Text('Clear'),
                              ),
                            ],
                          ),
                        ) ??
                        false;

                    if (confirmed) {
                      await onClearAll();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
