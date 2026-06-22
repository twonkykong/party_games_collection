import 'package:flutter/material.dart';

import '../../app/app_palette.dart';
import '../../app/app_router.dart';
import '../../core/services/app_scope.dart';
import '../../core/services/game_registry.dart';
import '../../core/services/ui_sound_service.dart';
import '../../shared/widgets/app_shell.dart';
import '../../shared/widgets/section_card.dart';

class GameSelectionScreen extends StatelessWidget {
  const GameSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final palette = AppPalette.of(context);

    return AppShell(
      title: 'Выбор игры',
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SectionCard(
            color: palette.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Выберите игру для новой партии',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Все игры используют локальные assets и восстанавливаются по коду на каждом устройстве одним и тем же способом.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          for (final game in GameRegistry.games) ...[
            InkWell(
              borderRadius: BorderRadius.circular(28),
              onTap: () async {
                app.playSound(UiSound.tapSoft);
                if (context.mounted) {
                  Navigator.of(
                    context,
                  ).pushNamed(AppRouter.gameSetupPath(game.type));
                }
              },
              child: SectionCard(
                color: game.accent.withValues(
                  alpha:
                      Theme.of(context).brightness == Brightness.dark
                          ? 0.18
                          : 0.12,
                ),
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: game.accent,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Icon(game.icon, color: palette.white),
                        ),
                        const Spacer(),
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: palette.surface.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.chevron_right_rounded,
                            color: palette.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      game.title,
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(fontSize: 24),
                    ),
                    const SizedBox(height: 8),
                    Text(game.description),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}
