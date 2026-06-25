import 'package:flutter/material.dart';

import '../../app/app_palette.dart';
import '../../app/app_router.dart';
import 'section_card.dart';

class MissingCustomWordsState extends StatelessWidget {
  const MissingCustomWordsState({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SectionCard(
          color: palette.surface,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.qr_code_2_rounded,
                size: 30,
                color: palette.primaryStrong,
              ),
              const SizedBox(height: 12),
              Text(
                'Для этой партии нужны пользовательские слова',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Импортируйте список слов в настройках, а затем откройте партию снова.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRouter.settingsPath);
                },
                child: const Text('Открыть настройки'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: const Text('Назад'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
