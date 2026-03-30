import 'package:flutter/material.dart';

import '../../services/android_bridge_service.dart';

class AppFilterScreen extends StatefulWidget {
  const AppFilterScreen({
    super.key,
    required this.apps,
    required this.excludedPackages,
    required this.onChanged,
  });

  final List<InstalledApp> apps;
  final Set<String> excludedPackages;
  final Future<void> Function(Set<String> packages) onChanged;

  @override
  State<AppFilterScreen> createState() => _AppFilterScreenState();
}

class _AppFilterScreenState extends State<AppFilterScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _excludedPackages = <String>{};

  @override
  void initState() {
    super.initState();
    _excludedPackages.addAll(widget.excludedPackages);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredApps = widget.apps.where((app) {
      final query = _searchController.text.trim().toLowerCase();
      if (query.isEmpty) {
        return true;
      }
      return app.appName.toLowerCase().contains(query) ||
          app.packageName.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('App Filter'),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              await widget.onChanged(_excludedPackages);
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search installed apps',
                prefixIcon: Icon(Icons.search_rounded),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: filteredApps.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final app = filteredApps[index];
                final enabled = !_excludedPackages.contains(app.packageName);
                return SwitchListTile(
                  title: Text(app.appName),
                  subtitle: Text(app.packageName),
                  value: enabled,
                  onChanged: (value) {
                    setState(() {
                      if (value) {
                        _excludedPackages.remove(app.packageName);
                      } else {
                        _excludedPackages.add(app.packageName);
                      }
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
