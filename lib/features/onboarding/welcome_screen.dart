import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    super.key,
    required this.onGetStarted,
  });

  final Future<void> Function() onGetStarted;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final features = <String>[
      'Save incoming notifications locally',
      'Search by app, title, or message',
      'Star important alerts and revisit them later',
    ];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Spacer(),
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Icon(
                  Icons.inventory_2_rounded,
                  size: 42,
                  color: colors.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Keep the notifications you wish you had not lost.',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                'NotiSaver quietly stores your notifications so you can search and recover them later.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              ...features.map(
                (feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.check_circle_rounded,
                        color: colors.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(feature)),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onGetStarted,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('Get Started'),
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
