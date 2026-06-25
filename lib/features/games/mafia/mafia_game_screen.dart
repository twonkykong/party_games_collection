import 'package:flutter/material.dart';

import '../../../app/app_palette.dart';
import '../../../core/models/active_party.dart';
import '../../../core/services/app_scope.dart';
import '../../../core/services/ui_sound_service.dart';
import '../../../shared/widgets/app_shell.dart';
import '../../../shared/widgets/game_completion_sheet.dart';
import '../../../shared/widgets/party_code_sheet.dart';
import '../../../shared/widgets/reveal_card.dart';
import '../../../shared/widgets/retry_state_card.dart';
import '../../../shared/widgets/section_card.dart';
import 'mafia_party_state.dart';

class MafiaGameScreen extends StatefulWidget {
  const MafiaGameScreen({required this.activeParty, super.key});

  final ActiveParty activeParty;

  @override
  State<MafiaGameScreen> createState() => _MafiaGameScreenState();
}

class _MafiaGameScreenState extends State<MafiaGameScreen> {
  bool _revealed = false;
  Set<int> _crossedRoles = <int>{};
  bool _loaded = false;
  Future<MafiaPartyState>? _partyFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _partyFuture ??= AppScope.of(
      context,
    ).runtime.buildMafiaPartyFromCode(widget.activeParty.code);
    if (_loaded) {
      return;
    }
    _loaded = true;
    _loadTracker();
  }

  Future<void> _loadTracker() async {
    final app = AppScope.of(context);
    final json = await app.storage.loadJsonState(
      app.storage.mafiaTrackerKey(widget.activeParty.code),
    );
    final values =
        (json['crossedRoles'] as List<dynamic>? ?? const [])
            .whereType<num>()
            .where((value) => value.isFinite)
            .map((value) => value.toInt())
            .toSet();
    if (!mounted) {
      return;
    }
    setState(() => _crossedRoles = values);
  }

  Future<void> _saveTracker() {
    final app = AppScope.of(context);
    return app.storage.saveJsonState(
      app.storage.mafiaTrackerKey(widget.activeParty.code),
      {'crossedRoles': _crossedRoles.toList()..sort()},
    );
  }

  void _toggleReveal() {
    final next = !_revealed;
    setState(() => _revealed = next);
    AppScope.of(
      context,
    ).playSound(next ? UiSound.cardReveal : UiSound.cardHide);
  }

  Future<void> _toggleRole(int index) async {
    setState(() {
      if (_crossedRoles.contains(index)) {
        _crossedRoles.remove(index);
      } else {
        _crossedRoles.add(index);
      }
    });
    AppScope.of(context).playSound(UiSound.toggleSoft);
    await _saveTracker();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MafiaPartyState>(
      future: _partyFuture,
      builder: (context, snapshot) {
        return AppShell(
          title: 'Мафия',
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
              onPressed: () => showGameCompletionSheet(
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
                    ).runtime.buildMafiaPartyFromCode(widget.activeParty.code);
                  }),
            ),
            _ => _MafiaGameContent(
              activeParty: widget.activeParty,
              state: snapshot.data!,
              revealed: _revealed,
              crossedRoles: _crossedRoles,
              onToggleReveal: _toggleReveal,
              onToggleRole: _toggleRole,
            ),
          },
        );
      },
    );
  }
}

class _MafiaGameContent extends StatelessWidget {
  const _MafiaGameContent({
    required this.activeParty,
    required this.state,
    required this.revealed,
    required this.crossedRoles,
    required this.onToggleReveal,
    required this.onToggleRole,
  });

  final ActiveParty activeParty;
  final MafiaPartyState state;
  final bool revealed;
  final Set<int> crossedRoles;
  final VoidCallback onToggleReveal;
  final ValueChanged<int> onToggleRole;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final role = state.assignments[activeParty.playerIndex]!;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
        SectionCard(
          color: palette.surface,
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: palette.primarySoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(Icons.person_rounded, color: palette.primaryStrong),
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
                    Text('Твоя роль скрыта от остальных игроков.'),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        RevealCard(
          revealed: revealed,
          hiddenLabel: 'Нажми, чтобы показать роль',
          helperText: revealed ? 'Ещё один тап снова скроет карточку.' : null,
          onTap: onToggleReveal,
          revealedChild: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Твоя роль', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              Text(
                role.title,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium?.copyWith(fontSize: 34),
              ),
              const SizedBox(height: 16),
              Text(
                role.description,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        SectionCard(
          color: palette.surfaceMuted,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Состав партии',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              Text(
                'Локальный трекер: можно отмечать уже раскрытые или выбывшие роли.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              for (var i = 0; i < state.partyRoles.length; i++) ...[
                _RoleTrackerRow(
                  index: i,
                  title: state.partyRoles[i].title,
                  team: state.partyRoles[i].team,
                  crossed: crossedRoles.contains(i),
                  onTap: () => onToggleRole(i),
                ),
                if (i != state.partyRoles.length - 1)
                  const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _RoleTrackerRow extends StatelessWidget {
  const _RoleTrackerRow({
    required this.index,
    required this.title,
    required this.team,
    required this.crossed,
    required this.onTap,
  });

  final int index;
  final String title;
  final String team;
  final bool crossed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: crossed ? palette.surfaceStrong : palette.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: palette.outline),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  decoration: crossed ? TextDecoration.lineThrough : null,
                  color: crossed ? palette.textSecondary : palette.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(team, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
