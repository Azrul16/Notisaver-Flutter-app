import 'package:flutter/material.dart';

class PermissionSetupScreen extends StatelessWidget {
  const PermissionSetupScreen({
    super.key,
    required this.notificationAccessEnabled,
    required this.batteryOptimizationIgnored,
    required this.onOpenNotificationAccess,
    required this.onOpenBatteryOptimization,
    required this.onContinue,
  });

  final bool notificationAccessEnabled;
  final bool batteryOptimizationIgnored;
  final Future<void> Function() onOpenNotificationAccess;
  final Future<void> Function() onOpenBatteryOptimization;
  final Future<void> Function() onContinue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Get NotiSaver ready',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Turn on the few permissions needed to save your notifications smoothly.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              _PermissionCard(
                title: 'Notification Access',
                description:
                    'Allow NotiSaver to securely save incoming notifications.',
                enabled: notificationAccessEnabled,
                buttonLabel: 'Open Settings',
                onPressed: onOpenNotificationAccess,
              ),
              const SizedBox(height: 16),
              _PermissionCard(
                title: 'Battery Optimization',
                description:
                    'Recommended so NotiSaver can keep working in the background.',
                enabled: batteryOptimizationIgnored,
                buttonLabel: 'Disable Optimization',
                onPressed: onOpenBatteryOptimization,
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Background Tips',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'On some phones, adding NotiSaver to auto-start or background protection helps keep notifications saved consistently.',
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: notificationAccessEnabled &&
                          batteryOptimizationIgnored
                      ? onContinue
                      : null,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('Continue'),
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

class _PermissionCard extends StatelessWidget {
  const _PermissionCard({
    required this.title,
    required this.description,
    required this.enabled,
    required this.buttonLabel,
    required this.onPressed,
  });

  final String title;
  final String description;
  final bool enabled;
  final String buttonLabel;
  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Chip(
                  backgroundColor: enabled
                      ? Colors.green.withValues(alpha: 0.16)
                      : colors.errorContainer,
                  label: Text(
                    enabled ? 'Granted' : 'Required',
                    style: TextStyle(
                      color: enabled ? Colors.green.shade700 : colors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  avatar: Icon(
                    enabled ? Icons.check_circle : Icons.error_outline,
                    size: 18,
                    color: enabled ? Colors.green.shade700 : colors.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(description),
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: onPressed,
              child: Text(buttonLabel),
            ),
          ],
        ),
      ),
    );
  }
}
