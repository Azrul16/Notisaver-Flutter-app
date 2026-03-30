import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/android_bridge_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.darkModeEnabled,
    required this.autoDeleteDays,
    required this.excludedAppsCount,
    required this.notificationAccessEnabled,
    required this.batteryOptimizationIgnored,
    required this.onDarkModeChanged,
    required this.onAutoDeleteDaysChanged,
    required this.onLoadReliabilityStatus,
    required this.onRefreshListenerBinding,
    required this.onOpenNotificationAccess,
    required this.onOpenBatterySettings,
    required this.onOpenAppFilter,
  });

  final bool darkModeEnabled;
  final int autoDeleteDays;
  final int excludedAppsCount;
  final bool notificationAccessEnabled;
  final bool batteryOptimizationIgnored;
  final Future<void> Function(bool value) onDarkModeChanged;
  final Future<void> Function(int value) onAutoDeleteDaysChanged;
  final Future<BackgroundReliabilityStatus> Function() onLoadReliabilityStatus;
  final Future<void> Function() onRefreshListenerBinding;
  final Future<void> Function() onOpenNotificationAccess;
  final Future<void> Function() onOpenBatterySettings;
  final Future<int> Function() onOpenAppFilter;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  BackgroundReliabilityStatus? _reliabilityStatus;
  bool _loadingReliability = true;
  late bool _darkModeEnabled;
  late int _autoDeleteDays;
  late int _excludedAppsCount;
  late bool _notificationAccessEnabled;
  late bool _batteryOptimizationIgnored;

  @override
  void initState() {
    super.initState();
    _darkModeEnabled = widget.darkModeEnabled;
    _autoDeleteDays = widget.autoDeleteDays;
    _excludedAppsCount = widget.excludedAppsCount;
    _notificationAccessEnabled = widget.notificationAccessEnabled;
    _batteryOptimizationIgnored = widget.batteryOptimizationIgnored;
    _loadReliability();
  }

  Future<void> _loadReliability() async {
    if (mounted) {
      setState(() {
        _loadingReliability = true;
      });
    }
    final status = await widget.onLoadReliabilityStatus();
    if (!mounted) return;
    setState(() {
      _reliabilityStatus = status;
      _loadingReliability = false;
      _notificationAccessEnabled = status.notificationAccessEnabled;
      _batteryOptimizationIgnored = status.batteryOptimizationIgnored;
    });
  }

  Future<void> _refreshBinding() async {
    await widget.onRefreshListenerBinding();
    await _loadReliability();
  }

  Future<void> _updateDarkMode(bool value) async {
    await widget.onDarkModeChanged(value);
    if (!mounted) return;
    setState(() {
      _darkModeEnabled = value;
    });
  }

  Future<void> _updateAutoDeleteDaysValue(int value) async {
    await widget.onAutoDeleteDaysChanged(value);
    if (!mounted) return;
    setState(() {
      _autoDeleteDays = value;
    });
  }

  Future<void> _openNotificationAccess() async {
    await widget.onOpenNotificationAccess();
    await _loadReliability();
  }

  Future<void> _openBatterySettings() async {
    await widget.onOpenBatterySettings();
    await _loadReliability();
  }

  Future<void> _openAppFilter() async {
    final excludedAppsCount = await widget.onOpenAppFilter();
    if (!mounted) return;
    setState(() {
      _excludedAppsCount = excludedAppsCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    final reliabilityStatus = _reliabilityStatus;
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
                  value: _darkModeEnabled,
                  onChanged: _updateDarkMode,
                ),
                ListTile(
                  title: const Text('Auto-delete after'),
                  subtitle: Text('$_autoDeleteDays days'),
                  trailing: const Icon(Icons.edit_rounded),
                  onTap: () async {
                    final value = await _showAutoDeleteDialog(context);
                    if (value != null) {
                      await _updateAutoDeleteDaysValue(value);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Expanded(
                        child: Text(
                          'Background reliability',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _loadingReliability ? null : _loadReliability,
                        icon: const Icon(Icons.refresh_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_loadingReliability)
                    const LinearProgressIndicator()
                  else ...<Widget>[
                    _StatusRow(
                      label: 'Notification access',
                      value: reliabilityStatus?.notificationAccessEnabled == true
                          ? 'On'
                          : 'Off',
                    ),
                    _StatusRow(
                      label: 'Battery optimization',
                      value: reliabilityStatus?.batteryOptimizationIgnored == true
                          ? 'Off'
                          : 'On',
                    ),
                    _StatusRow(
                      label: 'Listener connected',
                      value: _formatTimestamp(
                        reliabilityStatus?.lastListenerConnectedAt,
                      ),
                    ),
                    _StatusRow(
                      label: 'Last notification saved',
                      value: _formatTimestamp(
                        reliabilityStatus?.lastNotificationCapturedAt,
                      ),
                    ),
                    _StatusRow(
                      label: 'Last listener refresh',
                      value: _formatTimestamp(
                        reliabilityStatus?.lastRebindRequestedAt,
                      ),
                    ),
                    _StatusRow(
                      label: 'Pending sync',
                      value: '${reliabilityStatus?.pendingCount ?? 0}',
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _refreshBinding,
                      icon: const Icon(Icons.sync_rounded),
                      label: const Text('Refresh listener'),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: <Widget>[
                ListTile(
                  title: const Text('Notification access'),
                  subtitle: Text(
                    _notificationAccessEnabled ? 'On' : 'Off',
                  ),
                  trailing: TextButton(
                    onPressed: _openNotificationAccess,
                    child: const Text('Open'),
                  ),
                ),
                ListTile(
                  title: const Text('Battery optimization'),
                  subtitle: Text(
                    _batteryOptimizationIgnored ? 'On' : 'Off',
                  ),
                  trailing: TextButton(
                    onPressed: _openBatterySettings,
                    child: const Text('Open'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _openAppFilter,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primaryContainer
                            .withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.apps_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            'App filter',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _excludedAppsCount == 0
                                ? 'All apps are currently allowed.'
                                : '$_excludedAppsCount app${_excludedAppsCount == 1 ? '' : 's'} hidden from NotiSaver.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .secondaryContainer
                            .withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'Manage',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<int?> _showAutoDeleteDialog(BuildContext context) async {
    final controller =
        TextEditingController(text: _autoDeleteDays.toString());
    String? errorText;

    final result = await showDialog<int>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Auto-delete period'),
              content: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                autofocus: true,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
                decoration: InputDecoration(
                  hintText: '1 to 30',
                  suffixText: 'days',
                  errorText: errorText,
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final parsedValue = int.tryParse(controller.text.trim());
                    if (parsedValue == null ||
                        parsedValue < 1 ||
                        parsedValue > 30) {
                      setState(() {
                        errorText = 'Enter a value from 1 to 30';
                      });
                      return;
                    }
                    Navigator.of(dialogContext).pop(parsedValue);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();
    return result;
  }

  String _formatTimestamp(DateTime? value) {
    if (value == null) return 'Not yet';
    final local = value.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final suffix = local.hour >= 12 ? 'pm' : 'am';
    return '${local.day}/${local.month}/${local.year}  $hour:$minute $suffix';
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(label)),
          const SizedBox(width: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
