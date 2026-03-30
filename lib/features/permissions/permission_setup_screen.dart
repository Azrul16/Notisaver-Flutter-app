import 'package:flutter/material.dart';

import '../../services/android_bridge_service.dart';

class PermissionSetupScreen extends StatefulWidget {
  const PermissionSetupScreen({
    super.key,
    required this.notificationAccessEnabled,
    required this.batteryOptimizationIgnored,
    required this.devicePowerProfile,
    required this.onOpenNotificationAccess,
    required this.onOpenBatteryOptimization,
    required this.onOpenAutoStartSettings,
    required this.onContinue,
  });

  final bool notificationAccessEnabled;
  final bool batteryOptimizationIgnored;
  final DevicePowerProfile devicePowerProfile;
  final Future<void> Function() onOpenNotificationAccess;
  final Future<void> Function() onOpenBatteryOptimization;
  final Future<bool> Function() onOpenAutoStartSettings;
  final Future<void> Function() onContinue;

  @override
  State<PermissionSetupScreen> createState() => _PermissionSetupScreenState();
}

class _PermissionSetupScreenState extends State<PermissionSetupScreen> {
  bool _isCompleting = false;
  bool _isOpeningAutoStart = false;

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
    if (_requiredPermissionsGranted && !_needsXiaomiPrompt) {
      _isCompleting = true;
      await widget.onContinue();
    }
  }

  Future<void> _openAutoStartSettings() async {
    if (_isOpeningAutoStart) return;
    setState(() {
      _isOpeningAutoStart = true;
    });
    final opened = await widget.onOpenAutoStartSettings();
    if (!mounted) return;
    setState(() {
      _isOpeningAutoStart = false;
    });
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open the autostart settings screen.'),
        ),
      );
    }
  }

  Future<void> _completeSetup() async {
    if (_isCompleting) return;
    _isCompleting = true;
    await widget.onContinue();
  }

  bool get _requiredPermissionsGranted =>
      widget.notificationAccessEnabled && widget.batteryOptimizationIgnored;

  bool get _needsXiaomiPrompt =>
      _requiredPermissionsGranted && widget.devicePowerProfile.isXiaomiFamily;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: colors.scrim.withValues(alpha: 0.72),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Container(
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
                      Text(
                        _needsXiaomiPrompt
                            ? 'Almost ready'
                            : 'Complete setup',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _needsXiaomiPrompt
                            ? 'Your main Android permissions are already granted. One Xiaomi-specific step is still recommended for better background saving.'
                            : 'NotiSaver needs a couple of Android permissions before it can save notifications reliably.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colors.onSurfaceVariant,
                              height: 1.4,
                            ),
                      ),
                      const SizedBox(height: 20),
                      _PermissionRow(
                        title: 'Notification access',
                        subtitle: widget.notificationAccessEnabled
                            ? 'Granted and ready'
                            : 'Required to read incoming notifications',
                        granted: widget.notificationAccessEnabled,
                        buttonLabel: 'Open',
                        onPressed: widget.onOpenNotificationAccess,
                      ),
                      const SizedBox(height: 12),
                      _PermissionRow(
                        title: 'Battery optimization',
                        subtitle: widget.batteryOptimizationIgnored
                            ? 'Disabled for NotiSaver'
                            : 'Recommended so Android keeps background capture active',
                        granted: widget.batteryOptimizationIgnored,
                        buttonLabel: 'Open',
                        onPressed: widget.onOpenBatteryOptimization,
                      ),
                      if (_needsXiaomiPrompt) ...<Widget>[
                        const SizedBox(height: 12),
                        _PermissionRow(
                          title: 'Xiaomi autostart',
                          subtitle:
                              'Recommended on Xiaomi, Redmi, and Poco devices to reduce background kills.',
                          granted: false,
                          buttonLabel: _isOpeningAutoStart
                              ? 'Opening...'
                              : 'Open',
                          onPressed:
                              _isOpeningAutoStart ? null : _openAutoStartSettings,
                          accentColor: const Color(0xFFF59E0B),
                          badgeLabel: 'Recommended',
                          icon: Icons.rocket_launch_rounded,
                        ),
                      ],
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _requiredPermissionsGranted
                              ? _completeSetup
                              : null,
                          icon: const Icon(Icons.check_circle_rounded),
                          label: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              _needsXiaomiPrompt
                                  ? 'Continue to the app'
                                  : 'Finish setup',
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
    );
  }
}

class _PermissionRow extends StatelessWidget {
  const _PermissionRow({
    required this.title,
    required this.subtitle,
    required this.granted,
    required this.buttonLabel,
    required this.onPressed,
    this.accentColor,
    this.badgeLabel,
    this.icon,
  });

  final String title;
  final String subtitle;
  final bool granted;
  final String buttonLabel;
  final Future<void> Function()? onPressed;
  final Color? accentColor;
  final String? badgeLabel;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final Color statusColor = granted
        ? const Color(0xFF22C55E)
        : (accentColor ?? colors.primary);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: granted
              ? const Color(0xFF22C55E).withValues(alpha: 0.24)
              : colors.outlineVariant,
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon ??
                  (granted
                      ? Icons.verified_rounded
                      : Icons.settings_suggest_rounded),
              color: statusColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          if (granted) ...<Widget>[
                            Icon(
                              Icons.check_circle_rounded,
                              size: 13,
                              color: statusColor,
                            ),
                            const SizedBox(width: 5),
                          ],
                          Text(
                            badgeLabel ?? (granted ? 'Granted' : 'Required'),
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: onPressed,
            child: Text(buttonLabel),
          ),
        ],
      ),
    );
  }
}
