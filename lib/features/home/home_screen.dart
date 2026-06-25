import 'package:flutter/material.dart';

import '../../app/app_palette.dart';
import '../../app/app_router.dart';
import '../../core/services/app_scope.dart';
import '../../core/services/game_registry.dart';
import '../../core/services/ui_sound_service.dart';
import '../../shared/widgets/app_shell.dart';
import '../../shared/widgets/primary_action_button.dart';
import '../../shared/widgets/section_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final palette = AppPalette.of(context);
    final lastParty = controller.lastParty;

    return AppShell(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          SectionCard(
            color: palette.surface,
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: palette.secondarySoft,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Local party PWA',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: palette.primaryStrong,
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () async {
                        controller.playSound(UiSound.tapSoft);
                        if (context.mounted) {
                          Navigator.of(
                            context,
                          ).pushNamed(AppRouter.settingsPath);
                        }
                      },
                      icon: const Icon(Icons.tune_rounded),
                      tooltip: 'Настройки',
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  'Сборник игр',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineLarge?.copyWith(fontSize: 36, height: 1),
                ),
                const SizedBox(height: 10),
                Text(
                  'Тёплый мобильный формат для компании: один код и одна общая партия на каждом телефоне.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          PrimaryActionButton(
            label: 'Создать партию',
            icon: Icons.auto_awesome_rounded,
            onPressed: () async {
              controller.playSound(UiSound.tapSoft);
              if (context.mounted) {
                Navigator.of(context).pushNamed(AppRouter.createPath);
              }
            },
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              controller.playSound(UiSound.tapSoft);
              if (context.mounted) {
                Navigator.of(context).pushNamed(AppRouter.joinPath);
              }
            },
            icon: const Icon(Icons.key_rounded),
            label: const Text('Ввести код'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              controller.playSound(UiSound.tapSoft);
              if (context.mounted) {
                Navigator.of(context).pushNamed(AppRouter.rulesPath);
              }
            },
            icon: const Icon(Icons.menu_book_rounded),
            label: const Text('Правила'),
          ),
          if (lastParty != null) ...[
            const SizedBox(height: 24),
            SectionCard(
              color: palette.surfaceMuted,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Последняя партия',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(GameRegistry.byType(lastParty.gameType).title),
                  const SizedBox(height: 6),
                  Text('Код: ${lastParty.code}'),
                  const SizedBox(height: 6),
                  Text('Игрок: ${lastParty.playerIndex}'),
                  const SizedBox(height: 18),
                  PrimaryActionButton(
                    label: 'Вернуться',
                    onPressed: () async {
                      try {
                        if (lastParty.playerIndex < 1) {
                          throw const FormatException('Invalid player index');
                        }
                        final activeParty = controller.runtime
                            .buildActivePartyFromCode(
                              lastParty.code,
                              lastParty.playerIndex,
                            );
                        controller.playSound(UiSound.tapSoft);
                        if (!context.mounted) {
                          return;
                        }
                        Navigator.of(context).pushNamed(
                          AppRouter.gamePath(lastParty.gameType),
                          arguments: activeParty,
                        );
                      } catch (_) {
                        controller.playSound(UiSound.errorSoft);
                        if (!context.mounted) {
                          return;
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Не удалось восстановить последнюю партию.',
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () async {
                        controller.playSound(UiSound.tapSoft);
                        await controller.clearLastParty();
                      },
                      child: const Text('Очистить'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
