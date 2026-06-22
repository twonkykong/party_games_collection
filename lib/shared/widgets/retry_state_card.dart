import 'package:flutter/material.dart';

import '../../app/app_palette.dart';
import 'section_card.dart';

class RetryStateCard extends StatelessWidget {
  const RetryStateCard({
    required this.message,
    required this.onRetry,
    super.key,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SectionCard(
          color: palette.errorSoft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: palette.errorStrong,
                size: 28,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: palette.errorStrong),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Повторить'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
