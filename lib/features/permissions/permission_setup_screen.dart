import 'package:flutter/material.dart';

class PermissionSetupScreen extends StatefulWidget {
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
  State<PermissionSetupScreen> createState() => _PermissionSetupScreenState();
}

class _PermissionSetupScreenState extends State<PermissionSetupScreen> {
  bool _isCompleting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handlePermissionProgress();
    });
  }

  @override
  void didUpdateWidget(covariant PermissionSetupScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.notificationAccessEnabled != widget.notificationAccessEnabled ||
        oldWidget.batteryOptimizationIgnored !=
            widget.batteryOptimizationIgnored) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handlePermissionProgress();
      });
    }
  }

  Future<void> _handlePermissionProgress() async {
    if (_isCompleting) return;
    if (widget.notificationAccessEnabled && widget.batteryOptimizationIgnored) {
      _isCompleting = true;
      await widget.onContinue();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final step = _currentStep;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: colors.scrim.withValues(alpha: 0.72),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: Container(
                    key: ValueKey<_PermissionStep>(step),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: colors.shadow.withValues(alpha: 0.18),
                          blurRadius: 28,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                color: step == _PermissionStep.notification
                                    ? colors.primaryContainer
                                    : colors.secondaryContainer,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Icon(
                                step == _PermissionStep.notification
                                    ? Icons.notifications_active_rounded
                                    : Icons.battery_charging_full_rounded,
                                color: step == _PermissionStep.notification
                                    ? colors.primary
                                    : colors.secondary,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                step == _PermissionStep.notification
                                    ? 'Allow notification access'
                                    : 'Turn off battery restriction',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          step == _PermissionStep.notification
                              ? 'NotiSaver needs notification access first.'
                              : 'One more step to help background saving stay active.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: colors.surfaceContainerHighest
                                .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      step == _PermissionStep.notification
                                          ? 'Step 1 of 2'
                                          : 'Step 2 of 2',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(
                                            color: colors.primary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      step == _PermissionStep.notification
                                          ? 'Notification Access'
                                          : 'Battery Optimization',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Chip(
                                label: Text(
                                  step == _PermissionStep.notification
                                      ? (widget.notificationAccessEnabled
                                          ? 'Granted'
                                          : 'Required')
                                      : (widget.batteryOptimizationIgnored
                                          ? 'Granted'
                                          : 'Required'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: step == _PermissionStep.notification
                                ? widget.onOpenNotificationAccess
                                : widget.onOpenBatteryOptimization,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Text(
                                step == _PermissionStep.notification
                                    ? 'Open notification access'
                                    : 'Disable battery optimization',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _PermissionStep get _currentStep {
    if (!widget.notificationAccessEnabled) {
      return _PermissionStep.notification;
    }
    return _PermissionStep.battery;
  }
}

enum _PermissionStep { notification, battery }
