import 'package:flutter/material.dart';

import '../../app/app_palette.dart';
import '../../core/models/app_theme_preference.dart';
import '../../core/services/app_scope.dart';
import '../../core/services/ui_sound_service.dart';
import '../../shared/widgets/app_shell.dart';
import '../../shared/widgets/section_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final palette = AppPalette.of(context);

    return AppShell(
      title: 'Настройки',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          SectionCard(
            color: palette.surface,
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Оформление',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Тёплая тема, мягкие поверхности и тот же премиальный тон на всех экранах.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                SegmentedButton<AppThemePreference>(
                  segments: const [
                    ButtonSegment(
                      value: AppThemePreference.light,
                      label: Text('Светлая'),
                      icon: Icon(Icons.wb_sunny_rounded),
                    ),
                    ButtonSegment(
                      value: AppThemePreference.dark,
                      label: Text('Тёмная'),
                      icon: Icon(Icons.nightlight_rounded),
                    ),
                    ButtonSegment(
                      value: AppThemePreference.system,
                      label: Text('Как в системе'),
                      icon: Icon(Icons.phone_iphone_rounded),
                    ),
                  ],
                  selected: {controller.themePreference},
                  onSelectionChanged: (selection) async {
                    final preference = selection.first;
                    await controller.updateThemePreference(preference);
                    controller.playSound(UiSound.toggleSoft);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            color: palette.surfaceMuted,
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
            child: SwitchListTile.adaptive(
              value: controller.dirtyWordsEnabled,
              contentPadding: EdgeInsets.zero,
              activeColor: palette.primary,
              title: const Text('Грязные слова'),
              subtitle: const Text(
                'Показывать взрослые режимы словаря в играх со словами',
              ),
              onChanged: (value) async {
                await controller.setDirtyWordsEnabled(value);
                controller.playSound(UiSound.toggleSoft);
              },
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            color: palette.surfaceMuted,
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
            child: SwitchListTile.adaptive(
              value: controller.uiSoundsEnabled,
              contentPadding: EdgeInsets.zero,
              activeColor: palette.primary,
              title: const Text('Звуки интерфейса'),
              subtitle: const Text('Короткие премиальные звуки интерфейса'),
              onChanged: (value) async {
                await controller.setUiSoundsEnabled(value);
                if (value) {
                  controller.playSound(UiSound.toggleSoft);
                }
              },
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'by twonkykong',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: palette.textSecondary),
          ),
        ],
      ),
    );
  }
}
