import 'package:flutter/material.dart';

import '../../../app/app_palette.dart';
import '../../../core/models/active_party.dart';
import '../../../core/services/app_scope.dart';
import '../../../core/services/ui_sound_service.dart';
import '../../../data/models/bunker_catalog.dart';
import '../../../shared/widgets/app_shell.dart';
import '../../../shared/widgets/game_completion_sheet.dart';
import '../../../shared/widgets/party_code_sheet.dart';
import '../../../shared/widgets/retry_state_card.dart';
import '../../../shared/widgets/section_card.dart';
import 'bunker_party_state.dart';

enum BunkerViewMode { personal, players, bunker, flow, finale }

class BunkerGameScreen extends StatefulWidget {
  const BunkerGameScreen({required this.activeParty, super.key});

  final ActiveParty activeParty;

  @override
  State<BunkerGameScreen> createState() => _BunkerGameScreenState();
}

class _BunkerGameScreenState extends State<BunkerGameScreen> {
  BunkerViewMode _mode = BunkerViewMode.personal;
  Set<String> _revealedKeys = <String>{};
  Set<String> _personalMarkedFields = <String>{};
  Set<int> _eliminatedPlayers = <int>{};
  bool _finaleUnlocked = false;
  bool _loaded = false;
  Future<BunkerPartyState>? _partyFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _partyFuture ??= AppScope.of(
      context,
    ).runtime.buildBunkerPartyFromCode(widget.activeParty.code);
    if (_loaded) {
      return;
    }
    _loaded = true;
    _loadLocalState();
  }

  Future<void> _loadLocalState() async {
    final app = AppScope.of(context);
    final json = await app.storage.loadJsonState(
      app.storage.bunkerStateKey(widget.activeParty.code),
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _revealedKeys = _parseStringSet(json['revealedKeys']);
      _personalMarkedFields = _parseStringSet(json['personalMarkedFields']);
      _eliminatedPlayers = _parseIntSet(json['eliminatedPlayers']);
      _finaleUnlocked = json['finaleUnlocked'] as bool? ?? false;
    });
  }

  Set<String> _parseStringSet(Object? raw) {
    return (raw as List<dynamic>? ?? const []).whereType<String>().toSet();
  }

  Set<int> _parseIntSet(Object? raw) {
    return (raw as List<dynamic>? ?? const [])
        .whereType<num>()
        .where((value) => value.isFinite)
        .map((value) => value.toInt())
        .toSet();
  }

  Future<void> _saveLocalState() {
    final app = AppScope.of(context);
    return app.storage
        .saveJsonState(app.storage.bunkerStateKey(widget.activeParty.code), {
          'revealedKeys': _revealedKeys.toList()..sort(),
          'personalMarkedFields': _personalMarkedFields.toList()..sort(),
          'eliminatedPlayers': _eliminatedPlayers.toList()..sort(),
          'finaleUnlocked': _finaleUnlocked,
        });
  }

  Future<void> _setMode(BunkerViewMode mode) async {
    if (_mode == mode) {
      return;
    }
    setState(() => _mode = mode);
    AppScope.of(context).playSound(UiSound.toggleSoft);
  }

  Future<void> _toggleRevealField(int playerIndex, String field) async {
    final key = '$playerIndex::$field';
    setState(() {
      if (_revealedKeys.contains(key)) {
        _revealedKeys.remove(key);
      } else {
        _revealedKeys.add(key);
      }
    });
    AppScope.of(context).playSound(UiSound.cardReveal);
    await _saveLocalState();
  }

  Future<void> _togglePersonalMark(String field) async {
    setState(() {
      if (_personalMarkedFields.contains(field)) {
        _personalMarkedFields.remove(field);
      } else {
        _personalMarkedFields.add(field);
      }
    });
    AppScope.of(context).playSound(UiSound.toggleSoft);
    await _saveLocalState();
  }

  Future<void> _toggleEliminated(int playerIndex) async {
    setState(() {
      if (_eliminatedPlayers.contains(playerIndex)) {
        _eliminatedPlayers.remove(playerIndex);
      } else {
        _eliminatedPlayers.add(playerIndex);
      }
    });
    AppScope.of(context).playSound(UiSound.toggleSoft);
    await _saveLocalState();
  }

  Future<void> _unlockFinale() async {
    if (_finaleUnlocked) {
      return;
    }
    setState(() => _finaleUnlocked = true);
    AppScope.of(context).playSound(UiSound.successSoft);
    await _saveLocalState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<BunkerPartyState>(
      future: _partyFuture,
      builder: (context, snapshot) {
        return AppShell(
          title: 'Бункер',
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
                    ).runtime.buildBunkerPartyFromCode(widget.activeParty.code);
                  }),
            ),
            _ => _BunkerGameContent(
              activeParty: widget.activeParty,
              state: snapshot.data!,
              mode: _mode,
              revealedKeys: _revealedKeys,
              personalMarkedFields: _personalMarkedFields,
              eliminatedPlayers: _eliminatedPlayers,
              finaleUnlocked: _finaleUnlocked,
              onModeChanged: _setMode,
              onToggleRevealField: _toggleRevealField,
              onTogglePersonalMark: _togglePersonalMark,
              onToggleEliminated: _toggleEliminated,
              onUnlockFinale: _unlockFinale,
            ),
          },
        );
      },
    );
  }
}

class _BunkerGameContent extends StatelessWidget {
  const _BunkerGameContent({
    required this.activeParty,
    required this.state,
    required this.mode,
    required this.revealedKeys,
    required this.personalMarkedFields,
    required this.eliminatedPlayers,
    required this.finaleUnlocked,
    required this.onModeChanged,
    required this.onToggleRevealField,
    required this.onTogglePersonalMark,
    required this.onToggleEliminated,
    required this.onUnlockFinale,
  });

  final ActiveParty activeParty;
  final BunkerPartyState state;
  final BunkerViewMode mode;
  final Set<String> revealedKeys;
  final Set<String> personalMarkedFields;
  final Set<int> eliminatedPlayers;
  final bool finaleUnlocked;
  final ValueChanged<BunkerViewMode> onModeChanged;
  final Future<void> Function(int playerIndex, String field)
  onToggleRevealField;
  final Future<void> Function(String field) onTogglePersonalMark;
  final Future<void> Function(int playerIndex) onToggleEliminated;
  final Future<void> Function() onUnlockFinale;

  bool _isRevealed(int playerIndex, String field) =>
      revealedKeys.contains('$playerIndex::$field');

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final me =
        state.players[activeParty.playerIndex] ??
        state.players[1] ??
        state.players.values.first;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
        SectionCard(
          color: palette.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 430;
                  final badge = Container(
                    width: compact ? double.infinity : null,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: palette.secondarySoft,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      state.survivalTerm,
                      maxLines: compact ? 2 : 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: palette.primaryStrong,
                      ),
                    ),
                  );

                  if (compact) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Игрок ${activeParty.playerIndex}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        badge,
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Игрок ${activeParty.playerIndex}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(child: badge),
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              _BunkerTabs(mode: mode, onModeChanged: onModeChanged),
            ],
          ),
        ),
        const SizedBox(height: 18),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: KeyedSubtree(
            key: ValueKey(mode),
            child:
                mode == BunkerViewMode.personal
                    ? _PersonalView(
                      profile: me,
                      markedFields: personalMarkedFields,
                      onToggleMark: onTogglePersonalMark,
                    )
                    : mode == BunkerViewMode.players
                    ? _OverviewView(
                      players: state.players,
                      eliminatedPlayers: eliminatedPlayers,
                      onToggleRevealField: onToggleRevealField,
                      onToggleEliminated: onToggleEliminated,
                      isRevealed: _isRevealed,
                    )
                    : mode == BunkerViewMode.bunker
                    ? _BunkerLoreView(state: state)
                    : mode == BunkerViewMode.flow
                    ? _FlowView(rounds: state.rounds)
                    : _FinaleView(
                      state: state,
                      eliminatedCount: eliminatedPlayers.length,
                      unlocked: finaleUnlocked,
                      onUnlock: onUnlockFinale,
                    ),
          ),
        ),
      ],
    );
  }
}

class _PersonalView extends StatelessWidget {
  const _PersonalView({
    required this.profile,
    required this.markedFields,
    required this.onToggleMark,
  });

  final BunkerPlayerProfile profile;
  final Set<String> markedFields;
  final Future<void> Function(String field) onToggleMark;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final entries = _personalEntries(profile);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionCard(
          color: palette.surfaceMuted,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Профессия', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: palette.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: palette.outline),
                ),
                child: Text(
                  profile.profession,
                  textAlign: TextAlign.left,
                  style: Theme.of(
                    context,
                  ).textTheme.headlineMedium?.copyWith(fontSize: 30),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        for (var index = 0; index < entries.length; index++) ...[
          _PersonalFieldCard(
            title: entries[index].$1,
            lines: entries[index].$2,
            marked: markedFields.contains(entries[index].$1),
            onTap: () => onToggleMark(entries[index].$1),
            delay: index * 35,
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  List<(String, List<String>)> _personalEntries(BunkerPlayerProfile profile) {
    return [
      (
        'Биологические характеристики',
        [
          'Пол: ${profile.gender}',
          'Возраст: ${profile.age}',
          'Ориентация: ${profile.orientation}',
        ],
      ),
      ('Состояние здоровья', [profile.health]),
      ('Хобби', [profile.hobby]),
      ('Фобия', [profile.phobia]),
      ('Характер', [profile.character]),
      ('Дополнительная информация', [profile.fact]),
      ('Багаж', [profile.baggage]),
      ('Действие', [profile.action]),
      ('Условия', [profile.condition]),
    ];
  }
}

class _PersonalFieldCard extends StatelessWidget {
  const _PersonalFieldCard({
    required this.title,
    required this.lines,
    required this.marked,
    required this.onTap,
    required this.delay,
  });

  final String title;
  final List<String> lines;
  final bool marked;
  final VoidCallback onTap;
  final int delay;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 240 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 18 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        splashFactory: NoSplash.splashFactory,
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        onTap: onTap,
        child: SectionCard(
          color: palette.surface,
          padding: const EdgeInsets.all(18),
          child: Stack(
            children: [
              _BunkerInfoCardSurface(title: title, lines: lines),
              if (marked)
                Positioned(
                  top: 2,
                  right: 2,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: palette.errorStrong,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: palette.errorStrong.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
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

class _OverviewView extends StatelessWidget {
  const _OverviewView({
    required this.players,
    required this.eliminatedPlayers,
    required this.onToggleRevealField,
    required this.onToggleEliminated,
    required this.isRevealed,
  });

  final Map<int, BunkerPlayerProfile> players;
  final Set<int> eliminatedPlayers;
  final Future<void> Function(int playerIndex, String field)
  onToggleRevealField;
  final Future<void> Function(int playerIndex) onToggleEliminated;
  final bool Function(int playerIndex, String field) isRevealed;

  @override
  Widget build(BuildContext context) {
    final playerEntries = players.entries.toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Игроки', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          'Профессия видна сразу, остальные карточки раскрываются внутри блока по мере игры.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        for (var index = 0; index < playerEntries.length; index++) ...[
          _OverviewPlayerCard(
            playerIndex: playerEntries[index].key,
            profile: playerEntries[index].value,
            eliminated: eliminatedPlayers.contains(playerEntries[index].key),
            isRevealed: isRevealed,
            onToggleRevealField: onToggleRevealField,
            onToggleEliminated: onToggleEliminated,
            delay: index * 40,
          ),
          if (index != playerEntries.length - 1) const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class _OverviewPlayerCard extends StatelessWidget {
  const _OverviewPlayerCard({
    required this.playerIndex,
    required this.profile,
    required this.eliminated,
    required this.isRevealed,
    required this.onToggleRevealField,
    required this.onToggleEliminated,
    required this.delay,
  });

  final int playerIndex;
  final BunkerPlayerProfile profile;
  final bool eliminated;
  final bool Function(int playerIndex, String field) isRevealed;
  final Future<void> Function(int playerIndex, String field)
  onToggleRevealField;
  final Future<void> Function(int playerIndex) onToggleEliminated;
  final int delay;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final entries = _overviewEntries(profile);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 260 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 220),
        opacity: eliminated ? 0.55 : 1,
        child: SectionCard(
          color: palette.surface,
          child: Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
            ),
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: EdgeInsets.zero,
              shape: const Border(),
              collapsedShape: const Border(),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Игрок $playerIndex',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  _BunkerInfoCardSurface(
                    title: 'Профессия',
                    lines: [profile.profession],
                    emphasis: true,
                  ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton.tonal(
                    onPressed: () => onToggleEliminated(playerIndex),
                    child: Text(eliminated ? 'Вернуть' : 'Выгнать'),
                  ),
                ),
              ),
              children: [
                const SizedBox(height: 14),
                for (final item in entries) ...[
                  _RevealFieldCard(
                    label: item.$1,
                    lines: item.$2,
                    revealed: isRevealed(playerIndex, item.$1),
                    onTap: () => onToggleRevealField(playerIndex, item.$1),
                  ),
                  if (item != entries.last) const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<(String, List<String>)> _overviewEntries(BunkerPlayerProfile profile) {
    return [
      (
        'Биологические характеристики',
        [
          'Пол: ${profile.gender}',
          'Возраст: ${profile.age}',
          'Ориентация: ${profile.orientation}',
        ],
      ),
      ('Состояние здоровья', [profile.health]),
      ('Хобби', [profile.hobby]),
      ('Фобия', [profile.phobia]),
      ('Характер', [profile.character]),
      ('Дополнительная информация', [profile.fact]),
      ('Багаж', [profile.baggage]),
      ('Действие', [profile.action]),
      ('Условия', [profile.condition]),
    ];
  }
}

class _FlowView extends StatelessWidget {
  const _FlowView({required this.rounds});

  final List<BunkerRoundStep> rounds;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);

    return SectionCard(
      color: palette.surfaceMuted,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ход игры', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Это полный roadmap партии: сколько карточек открывает каждый игрок и сколько киков происходит в каждом раунде.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          for (final round in rounds) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: palette.outline),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: palette.primarySoft,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        '${round.round}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Раунд ${round.round}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Каждый открывает ${round.openPerPlayer} карточк(и), киков: ${round.kicks}.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (round != rounds.last) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _BunkerLoreView extends StatelessWidget {
  const _BunkerLoreView({required this.state});

  final BunkerPartyState state;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionCard(
          color: palette.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Бункер', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              Text(
                state.disaster,
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium?.copyWith(fontSize: 28),
              ),
              const SizedBox(height: 16),
              _BunkerInfoCardSurface(
                title: state.introLore.title,
                lines: [state.introLore.summary, state.introLore.details],
              ),
              const SizedBox(height: 14),
              _BunkerInfoCardSurface(title: 'Место', lines: [state.location]),
              const SizedBox(height: 12),
              _BunkerInfoCardSurface(
                title: 'Вместимость',
                lines: [state.capacity],
              ),
              const SizedBox(height: 12),
              _BunkerInfoCardSurface(
                title: 'Срок выживания',
                lines: [state.survivalTerm],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          color: palette.surfaceMuted,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Условия', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children:
                    state.globalConditions
                        .map(
                          (condition) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: palette.surface,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: palette.outline),
                            ),
                            child: Text(condition),
                          ),
                        )
                        .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FinaleView extends StatelessWidget {
  const _FinaleView({
    required this.state,
    required this.eliminatedCount,
    required this.unlocked,
    required this.onUnlock,
  });

  final BunkerPartyState state;
  final int eliminatedCount;
  final bool unlocked;
  final Future<void> Function() onUnlock;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final finale = _buildFinaleNarrative();
    final resolvedEnding = _resolveEndingEntry();

    return Column(
      children: [
        SectionCard(
          color: palette.surfaceMuted,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Финал', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                'Открывайте финал только после всех обсуждений, всех раскрытий и всех киков.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 14),
              _FinaleUnlockCard(unlocked: unlocked, onUnlock: onUnlock),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          color: palette.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 420),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child:
                    unlocked
                        ? Column(
                          key: const ValueKey('final_open'),
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              finale.$1,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              finale.$2,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        )
                        : Column(
                          key: const ValueKey('final_closed'),
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              finale.$1,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              finale.$2,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: palette.surfaceMuted,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 420),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child:
                      unlocked
                          ? Column(
                            key: const ValueKey('ending_lore'),
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                resolvedEnding.title,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                resolvedEnding.text,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          )
                          : Text(
                            'Полный финальный лор скрыт до удержания. Сначала закончите обсуждения, кики и все раскрытия.',
                            key: const ValueKey('ending_locked'),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  (String, String) _buildFinaleNarrative() {
    if (!unlocked) {
      return (
        'Финал запечатан',
        'Поверхность всё ещё остаётся неизвестной, а любой поспешный вывод может разрушить атмосферу партии. Дождитесь конца обсуждений и только потом открывайте исход.',
      );
    }

    final survivors = state.players.length - eliminatedCount;
    if (survivors == state.players.length) {
      return (
        'Все вошли в бункер',
        'Внутри тесно, жарко и тревожно, но группа удержалась от раскола. Люди, которых никто не хотел терять, всё ещё рядом, а значит у бункера есть шанс прожить этот кошмар как одна команда.',
      );
    }
    if (survivors >= state.players.length ~/ 2) {
      return (
        'Бункер выдержал цену отбора',
        'До финала дошли не все, но уцелевший состав сохранил ключевые навыки. Теперь выживание выглядит не как удача, а как тяжёлое, холодное решение, за которое придётся расплачиваться памятью о тех, кто остался снаружи.',
      );
    }
    if (survivors >= 2) {
      return (
        'Слишком мало, чтобы чувствовать победу',
        'Бункер всё ещё стоит, но воздух здесь уже пахнет не спасением, а последствиями. Оставшиеся выжили, только вот сама идея общего будущего стала гораздо хрупче, чем стены вокруг.',
      );
    }
    return (
      'Провал отбора',
      'Финальная сцена звучит как пустой эхом коридор: ресурсы есть, металл цел, но людей почти не осталось. Иногда катастрофа приходит не снаружи, а из решений, которые группа принимает внутри бункера.',
    );
  }

  BunkerEndingEntry _resolveEndingEntry() {
    final survivors = state.players.length - eliminatedCount;
    if (survivors == state.players.length) {
      return state.finalGood;
    }
    if (survivors >= state.players.length ~/ 2) {
      return state.finalMixed;
    }
    return state.finalBad;
  }
}

class _RevealFieldCard extends StatelessWidget {
  const _RevealFieldCard({
    required this.label,
    required this.lines,
    required this.revealed,
    required this.onTap,
  });

  final String label;
  final List<String> lines;
  final bool revealed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      splashFactory: NoSplash.splashFactory,
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: revealed ? 220 : 70),
        curve: revealed ? Curves.easeOutCubic : Curves.linear,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: revealed ? palette.primarySoft : palette.surfaceMuted,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: palette.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            AnimatedSwitcher(
              duration: Duration(milliseconds: revealed ? 200 : 70),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: revealed ? Curves.easeInCubic : Curves.linear,
              child:
                  revealed
                      ? Container(
                        key: const ValueKey('revealed'),
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: palette.surface.withValues(alpha: 0.74),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (
                              var index = 0;
                              index < lines.length;
                              index++
                            ) ...[
                              Text(
                                lines[index],
                                textAlign: TextAlign.left,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              if (index != lines.length - 1)
                                const SizedBox(height: 6),
                            ],
                          ],
                        ),
                      )
                      : Row(
                        key: const ValueKey('hidden'),
                        children: [
                          Expanded(
                            child: Text(
                              'Скрыто',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: palette.textSecondary),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.visibility_rounded,
                            color: palette.textSecondary,
                            size: 18,
                          ),
                        ],
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BunkerIntroCard extends StatefulWidget {
  const _BunkerIntroCard({required this.state});

  final BunkerPartyState state;

  @override
  State<_BunkerIntroCard> createState() => _BunkerIntroCardState();
}

class _BunkerIntroCardState extends State<_BunkerIntroCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final intro = widget.state.introLore;

    return SectionCard(
      color: palette.surfaceMuted,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Предыстория партии',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [palette.secondarySoft, palette.primarySoft],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  intro.title,
                  style: Theme.of(
                    context,
                  ).textTheme.headlineMedium?.copyWith(fontSize: 30),
                ),
                const SizedBox(height: 10),
                Text(
                  intro.summary,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _IntroMetaLine(label: 'Катастрофа', value: widget.state.disaster),
          const SizedBox(height: 10),
          _IntroMetaLine(label: 'Укрытие', value: widget.state.location),
          const SizedBox(height: 10),
          _IntroMetaLine(label: 'Вместимость', value: widget.state.capacity),
          const SizedBox(height: 10),
          _IntroMetaLine(
            label: 'Цель выживания',
            value: widget.state.survivalTerm,
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children:
                widget.state.globalConditions
                    .take(2)
                    .map(
                      (condition) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: palette.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: palette.outline),
                        ),
                        child: Text(condition),
                      ),
                    )
                    .toList(),
          ),
          const SizedBox(height: 14),
          TextButton.icon(
            onPressed: () => setState(() => _expanded = !_expanded),
            icon: Icon(
              _expanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
            ),
            label: Text(_expanded ? 'Скрыть детали' : 'Показать детали'),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                intro.details,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            crossFadeState:
                _expanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 240),
          ),
        ],
      ),
    );
  }
}

class _IntroMetaLine extends StatelessWidget {
  const _IntroMetaLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _BunkerInfoCardSurface extends StatelessWidget {
  const _BunkerInfoCardSurface({
    required this.title,
    required this.lines,
    this.emphasis = false,
  });

  final String title;
  final List<String> lines;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: palette.surfaceMuted,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: palette.outline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var index = 0; index < lines.length; index++) ...[
                Text(
                  lines[index],
                  textAlign: TextAlign.left,
                  style:
                      emphasis
                          ? Theme.of(
                            context,
                          ).textTheme.headlineMedium?.copyWith(fontSize: 26)
                          : Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: palette.textPrimary,
                          ),
                ),
                if (index != lines.length - 1) const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _FinaleUnlockCard extends StatefulWidget {
  const _FinaleUnlockCard({required this.unlocked, required this.onUnlock});

  final bool unlocked;
  final Future<void> Function() onUnlock;

  @override
  State<_FinaleUnlockCard> createState() => _FinaleUnlockCardState();
}

class _FinaleUnlockCardState extends State<_FinaleUnlockCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _unlockTriggered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed &&
          !_unlockTriggered &&
          !widget.unlocked) {
        _unlockTriggered = true;
        widget.onUnlock();
      }
    });
  }

  @override
  void didUpdateWidget(covariant _FinaleUnlockCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.unlocked && !oldWidget.unlocked) {
      _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startHold() {
    if (widget.unlocked) {
      return;
    }
    _unlockTriggered = false;
    _controller.forward(from: 0);
  }

  void _cancelHold() {
    if (widget.unlocked || _unlockTriggered) {
      return;
    }
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);

    return GestureDetector(
      onTapDown: (_) => _startHold(),
      onTapUp: (_) => _cancelHold(),
      onTapCancel: _cancelHold,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final progress = widget.unlocked ? 1.0 : _controller.value;
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: widget.unlocked ? palette.surface : palette.surfaceStrong,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color:
                    progress > 0
                        ? palette.primary.withValues(alpha: 0.45)
                        : palette.outline,
              ),
              boxShadow:
                  progress > 0 && !widget.unlocked
                      ? [
                        BoxShadow(
                          color: palette.primary.withValues(alpha: 0.16),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ]
                      : null,
            ),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 54,
                      height: 54,
                      child: CircularProgressIndicator(
                        value: progress == 0 ? null : progress,
                        strokeWidth: 4,
                        backgroundColor: palette.surfaceMuted,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          palette.primaryStrong,
                        ),
                      ),
                    ),
                    Icon(
                      widget.unlocked
                          ? Icons.menu_book_rounded
                          : Icons.lock_clock_rounded,
                      size: 26,
                      color:
                          widget.unlocked
                              ? palette.primaryStrong
                              : palette.textPrimary,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  widget.unlocked
                      ? 'Финальная сцена открыта'
                      : 'Удерживай, чтобы открыть финал',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.unlocked
                      ? 'Это локальное открытие и оно не влияет на код партии.'
                      : progress > 0
                      ? 'Держи до полного круга, чтобы мягко открыть финальную сцену.'
                      : 'Обычный тап ничего не делает. Нужен осознанный long press в конце партии.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BunkerTabs extends StatelessWidget {
  const _BunkerTabs({required this.mode, required this.onModeChanged});

  final BunkerViewMode mode;
  final ValueChanged<BunkerViewMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    const items = [
      (BunkerViewMode.personal, 'Личное'),
      (BunkerViewMode.players, 'Игроки'),
      (BunkerViewMode.bunker, 'Бункер'),
      (BunkerViewMode.flow, 'Ход'),
      (BunkerViewMode.finale, 'Финал'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final item in items) ...[
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(
                  item.$2,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                ),
                selected: mode == item.$1,
                selectedColor: palette.primarySoft,
                backgroundColor: palette.surface,
                side: BorderSide.none,
                onSelected: (_) => onModeChanged(item.$1),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
