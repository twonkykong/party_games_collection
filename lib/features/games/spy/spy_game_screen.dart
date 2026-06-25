import 'package:flutter/material.dart';

import '../../../app/app_palette.dart';
import '../../../core/models/active_party.dart';
import '../../../core/models/word_source_mode.dart';
import '../../../core/services/app_scope.dart';
import '../../../core/services/ui_sound_service.dart';
import '../../../shared/widgets/app_shell.dart';
import '../../../shared/widgets/game_completion_sheet.dart';
import '../../../shared/widgets/missing_custom_words_state.dart';
import '../../../shared/widgets/party_code_sheet.dart';
import '../../../shared/widgets/reveal_card.dart';
import '../../../shared/widgets/retry_state_card.dart';
import '../../../shared/widgets/section_card.dart';
import 'spy_party_state.dart';

class SpyGameScreen extends StatefulWidget {
  const SpyGameScreen({required this.activeParty, super.key});

  final ActiveParty activeParty;

  @override
  State<SpyGameScreen> createState() => _SpyGameScreenState();
}

class _SpyGameScreenState extends State<SpyGameScreen> {
  bool _revealed = false;
  Future<SpyPartyState>? _partyFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _partyFuture ??= AppScope.of(
      context,
    ).runtime.buildSpyPartyFromCode(widget.activeParty.code);
  }

  Future<void> _toggleReveal() async {
    final app = AppScope.of(context);
    final next = !_revealed;
    setState(() => _revealed = next);
    app.playSound(next ? UiSound.cardReveal : UiSound.cardHide);
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    if (widget.activeParty.configuration.wordSourceMode ==
            WordSourceMode.customOnly &&
        app.customWords.isEmpty) {
      return const AppShell(title: 'Шпион', child: MissingCustomWordsState());
    }

    return FutureBuilder<SpyPartyState>(
      future: _partyFuture,
      builder: (context, snapshot) {
        return AppShell(
          title: 'Шпион',
          actions: [
            IconButton(
              onPressed:
                  snapshot.hasData
                      ? () => showPartyCodeSheet(
                        context,
                        code: widget.activeParty.code,
                        configuration: widget.activeParty.configuration,
                      )
                      : null,
              icon: const Icon(Icons.key_rounded),
            ),
            IconButton(
              onPressed:
                  () => showGameCompletionSheet(
                    context,
                    activeParty: widget.activeParty,
                  ),
              icon: const Icon(Icons.flag_rounded),
            ),
          ],
          child: switch (snapshot.connectionState) {
            ConnectionState.waiting => const Center(
              child: CircularProgressIndicator(),
            ),
            _ when snapshot.hasError => RetryStateCard(
              message: '${snapshot.error}',
              onRetry:
                  () => setState(() {
                    _partyFuture = AppScope.of(
                      context,
                    ).runtime.buildSpyPartyFromCode(widget.activeParty.code);
                  }),
            ),
            _ => _SpyGameContent(
              activeParty: widget.activeParty,
              state: snapshot.data!,
              revealed: _revealed,
              onToggle: _toggleReveal,
            ),
          },
        );
      },
    );
  }
}

class _SpyGameContent extends StatelessWidget {
  const _SpyGameContent({
    required this.activeParty,
    required this.state,
    required this.revealed,
    required this.onToggle,
  });

  final ActiveParty activeParty;
  final SpyPartyState state;
  final bool revealed;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final isSpy = state.isSpy(activeParty.playerIndex);
    final palette = AppPalette.of(context);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        SectionCard(
          color: palette.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: palette.secondarySoft,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.visibility_rounded,
                      color: palette.primaryStrong,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Игрок ${activeParty.playerIndex}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Личная карточка игрока',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: palette.surfaceMuted,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: palette.outline),
                ),
                child: Text(
                  'Начинает игрок ${state.startingPlayerIndex}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        RevealCard(
          revealed: revealed,
          hiddenLabel: 'Нажми, чтобы показать',
          helperText:
              revealed
                  ? 'Нажмите на карточку, чтобы скрыть или показать информацию'
                  : null,
          onTap: onToggle,
          revealedChild: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Твоя карточка',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontSize: 24),
              ),
              const SizedBox(height: 16),
              Text(
                isSpy ? state.hint : state.entry.word,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium?.copyWith(fontSize: 34),
              ),
              const SizedBox(height: 14),
              Text(
                'Запомните эту информацию и не показывайте экран другим игрокам.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
