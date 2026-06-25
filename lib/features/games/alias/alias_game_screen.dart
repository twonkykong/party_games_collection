import 'dart:async';

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
import '../../../shared/widgets/primary_action_button.dart';
import '../../../shared/widgets/retry_state_card.dart';
import '../../../shared/widgets/section_card.dart';
import 'alias_party_state.dart';

enum AliasRoundPhase { preRound, active, grace, postRound }

class AliasGameScreen extends StatefulWidget {
  const AliasGameScreen({required this.activeParty, super.key});

  final ActiveParty activeParty;

  @override
  State<AliasGameScreen> createState() => _AliasGameScreenState();
}

class _AliasGameScreenState extends State<AliasGameScreen> {
  int _score = 0;
  int _wordOffset = 0;
  int _secondsLeft = 0;
  int _roundScore = 0;
  AliasRoundPhase _phase = AliasRoundPhase.preRound;
  Timer? _timer;
  bool _loaded = false;
  Future<AliasPartyState>? _partyFuture;
  bool _starterShown = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _partyFuture ??= AppScope.of(
      context,
    ).runtime.buildAliasPartyFromCode(widget.activeParty.code);
    if (_loaded) {
      return;
    }
    _loaded = true;
    _loadLocalState();
  }

  Future<void> _loadLocalState() async {
    final app = AppScope.of(context);
    final json = await app.storage.loadJsonState(
      app.storage.aliasStateKey(
        widget.activeParty.code,
        widget.activeParty.playerIndex,
      ),
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _score =
          json['score'] is num && (json['score'] as num).isFinite
              ? (json['score'] as num).toInt()
              : 0;
      _wordOffset =
          json['wordOffset'] is num && (json['wordOffset'] as num).isFinite
              ? (json['wordOffset'] as num).toInt()
              : 0;
    });
  }

  Future<void> _saveLocalState() {
    final app = AppScope.of(context);
    return app.storage.saveJsonState(
      app.storage.aliasStateKey(
        widget.activeParty.code,
        widget.activeParty.playerIndex,
      ),
      {'score': _score, 'wordOffset': _wordOffset},
    );
  }

  void _startRound(int roundSeconds) {
    if (_phase == AliasRoundPhase.active || _phase == AliasRoundPhase.grace) {
      return;
    }
    _timer?.cancel();
    AppScope.of(context).playSound(UiSound.tapSoft);
    setState(() {
      _secondsLeft = roundSeconds;
      _roundScore = 0;
      _phase = AliasRoundPhase.active;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() {
          _secondsLeft = 0;
          _phase = AliasRoundPhase.grace;
        });
        AppScope.of(context).playSound(UiSound.errorSoft);
        return;
      }
      setState(() => _secondsLeft -= 1);
    });
  }

  Future<void> _resolveWord(int delta) async {
    if (_phase != AliasRoundPhase.active && _phase != AliasRoundPhase.grace) {
      return;
    }
    final wasGrace = _phase == AliasRoundPhase.grace;
    setState(() {
      if (delta > 0) {
        _score += delta;
        _roundScore += delta;
      }
      _wordOffset += 1;
      if (wasGrace) {
        _phase = AliasRoundPhase.postRound;
      }
    });
    AppScope.of(
      context,
    ).playSound(delta > 0 ? UiSound.successSoft : UiSound.tapSoft);
    await _saveLocalState();
  }

  void _showStarterOnce() {
    if (_starterShown) {
      return;
    }
    _starterShown = true;
    final starter =
        (widget.activeParty.configuration.seed.abs() %
            widget.activeParty.configuration.playerCount) +
        1;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Начинает команда $starter'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    if (widget.activeParty.configuration.wordSourceMode ==
            WordSourceMode.customOnly &&
        app.customWords.isEmpty) {
      return const AppShell(title: 'Элиас', child: MissingCustomWordsState());
    }

    return FutureBuilder<AliasPartyState>(
      future: _partyFuture,
      builder: (context, snapshot) {
        return AppShell(
          title: 'Элиас',
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
                    ).runtime.buildAliasPartyFromCode(widget.activeParty.code);
                  }),
            ),
            _ => () {
              _showStarterOnce();
              return _AliasGameContent(
                activeParty: widget.activeParty,
                state: snapshot.data!,
                score: _score,
                secondsLeft: _secondsLeft,
                roundScore: _roundScore,
                phase: _phase,
                wordOffset: _wordOffset,
                onStartRound: _startRound,
                onResolveWord: _resolveWord,
              );
            }(),
          },
        );
      },
    );
  }
}

class _AliasGameContent extends StatelessWidget {
  const _AliasGameContent({
    required this.activeParty,
    required this.state,
    required this.score,
    required this.secondsLeft,
    required this.roundScore,
    required this.phase,
    required this.wordOffset,
    required this.onStartRound,
    required this.onResolveWord,
  });

  final ActiveParty activeParty;
  final AliasPartyState state;
  final int score;
  final int secondsLeft;
  final int roundScore;
  final AliasRoundPhase phase;
  final int wordOffset;
  final ValueChanged<int> onStartRound;
  final Future<void> Function(int delta) onResolveWord;

  bool get _isWordVisible =>
      phase == AliasRoundPhase.active || phase == AliasRoundPhase.grace;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final currentWord = state.words[wordOffset % state.words.length];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
        SectionCard(
          color: palette.surface,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Команда ${activeParty.playerIndex}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text('Счёт $score / ${state.targetScore}'),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color:
                      phase == AliasRoundPhase.grace
                          ? palette.errorSoft
                          : palette.primarySoft,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  phase == AliasRoundPhase.preRound ||
                          phase == AliasRoundPhase.postRound
                      ? '${state.roundSeconds} сек'
                      : '$secondsLeft сек',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color:
                        phase == AliasRoundPhase.grace
                            ? palette.errorStrong
                            : palette.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        SectionCard(
          color: palette.surfaceMuted,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _switchTitle(),
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                height: 220,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: palette.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: palette.outline),
                ),
                child: Center(
                  child:
                      _isWordVisible
                          ? Text(
                            currentWord,
                            textAlign: TextAlign.center,
                            style: Theme.of(
                              context,
                            ).textTheme.headlineMedium?.copyWith(fontSize: 34),
                          )
                          : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.visibility_off_rounded,
                                size: 34,
                                color: palette.primary,
                              ),
                              const SizedBox(height: 14),
                              Text(
                                phase == AliasRoundPhase.postRound
                                    ? 'Раунд завершён'
                                    : 'Слово появится после старта раунда',
                                textAlign: TextAlign.center,
                                style: Theme.of(
                                  context,
                                ).textTheme.titleMedium?.copyWith(fontSize: 18),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                phase == AliasRoundPhase.postRound
                                    ? 'За этот раунд: +$roundScore очко(ов)'
                                    : 'Подготовьтесь, а затем нажмите «Начать».',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                ),
              ),
              const SizedBox(height: 16),
              if (phase == AliasRoundPhase.grace)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: palette.errorSoft,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: palette.outline),
                  ),
                  child: Text(
                    'Время вышло — заверши текущее слово последним нажатием.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: palette.errorStrong,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              if (phase == AliasRoundPhase.preRound ||
                  phase == AliasRoundPhase.postRound)
                PrimaryActionButton(
                  label:
                      phase == AliasRoundPhase.postRound
                          ? 'Начать следующий раунд'
                          : 'Начать',
                  onPressed: () => onStartRound(state.roundSeconds),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => onResolveWord(1),
                        child: const Text('Угадали'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => onResolveWord(0),
                        child: const Text('Пропуск'),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _switchTitle() {
    switch (phase) {
      case AliasRoundPhase.preRound:
        return 'Раунд ещё не начался';
      case AliasRoundPhase.active:
        return 'Объясняй слово';
      case AliasRoundPhase.grace:
        return 'Финальное слово';
      case AliasRoundPhase.postRound:
        return 'Раунд завершён';
    }
  }
}
