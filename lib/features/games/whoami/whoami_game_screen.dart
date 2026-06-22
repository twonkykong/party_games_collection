import 'package:flutter/material.dart';

import '../../../app/app_palette.dart';
import '../../../core/models/active_party.dart';
import '../../../core/services/app_scope.dart';
import '../../../core/services/ui_sound_service.dart';
import '../../../shared/widgets/app_shell.dart';
import '../../../shared/widgets/hold_to_reveal_card.dart';
import '../../../shared/widgets/party_code_sheet.dart';
import '../../../shared/widgets/retry_state_card.dart';
import '../../../shared/widgets/section_card.dart';
import 'whoami_party_state.dart';

enum WhoAmIViewMode { forehead, list }

class WhoAmIGameScreen extends StatefulWidget {
  const WhoAmIGameScreen({required this.activeParty, super.key});

  final ActiveParty activeParty;

  @override
  State<WhoAmIGameScreen> createState() => _WhoAmIGameScreenState();
}

class _WhoAmIGameScreenState extends State<WhoAmIGameScreen> {
  WhoAmIViewMode _mode = WhoAmIViewMode.forehead;
  bool _revealed = false;
  Future<WhoAmIPartyState>? _partyFuture;
  bool _starterShown = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _partyFuture ??= AppScope.of(
      context,
    ).runtime.buildWhoAmIPartyFromCode(widget.activeParty.code);
  }

  Future<void> _setMode(WhoAmIViewMode value) async {
    if (_mode == value) {
      return;
    }
    setState(() => _mode = value);
    AppScope.of(context).playSound(UiSound.toggleSoft);
  }

  Future<void> _reveal() async {
    setState(() => _revealed = true);
    AppScope.of(context).playSound(UiSound.cardReveal);
  }

  Future<void> _hide() async {
    setState(() => _revealed = false);
    AppScope.of(context).playSound(UiSound.cardHide);
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
          content: Text('Начинает игрок $starter'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WhoAmIPartyState>(
      future: _partyFuture,
      builder: (context, snapshot) {
        return AppShell(
          title: 'Кто я',
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
                    ).runtime.buildWhoAmIPartyFromCode(widget.activeParty.code);
                  }),
            ),
            _ => () {
              _showStarterOnce();
              return _WhoAmIGameContent(
                activeParty: widget.activeParty,
                state: snapshot.data!,
                mode: _mode,
                revealed: _revealed,
                onModeChanged: _setMode,
                onReveal: _reveal,
                onHide: _hide,
              );
            }(),
          },
        );
      },
    );
  }
}

class _WhoAmIGameContent extends StatelessWidget {
  const _WhoAmIGameContent({
    required this.activeParty,
    required this.state,
    required this.mode,
    required this.revealed,
    required this.onModeChanged,
    required this.onReveal,
    required this.onHide,
  });

  final ActiveParty activeParty;
  final WhoAmIPartyState state;
  final WhoAmIViewMode mode;
  final bool revealed;
  final ValueChanged<WhoAmIViewMode> onModeChanged;
  final VoidCallback onReveal;
  final VoidCallback onHide;

  @override
  Widget build(BuildContext context) {
    final currentWord = state.assignments[activeParty.playerIndex]!;
    final palette = AppPalette.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
        SectionCard(
          color: palette.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Игрок ${activeParty.playerIndex}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              Text(
                'Кнопка шапки показывает код партии, а переключатель ниже меняет режим просмотра без изменения партии.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              SegmentedButton<WhoAmIViewMode>(
                segments: const [
                  ButtonSegment(
                    value: WhoAmIViewMode.forehead,
                    label: Text('Ко лбу'),
                    icon: Icon(Icons.flip_to_front_rounded),
                  ),
                  ButtonSegment(
                    value: WhoAmIViewMode.list,
                    label: Text('Список'),
                    icon: Icon(Icons.view_list_rounded),
                  ),
                ],
                selected: {mode},
                onSelectionChanged: (selection) {
                  onModeChanged(selection.first);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        if (mode == WhoAmIViewMode.forehead)
          HoldToRevealCard(
            revealed: revealed,
            onReveal: onReveal,
            onHide: onHide,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Твоё слово',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontSize: 24),
                ),
                const SizedBox(height: 16),
                Text(
                  currentWord.value,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.headlineMedium?.copyWith(fontSize: 34),
                ),
                const SizedBox(height: 16),
                Text(
                  'Покажите экран другим игрокам, затем нажмите, чтобы снова скрыть слово.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          )
        else
          SectionCard(
            color: palette.surface,
            child: Column(
              children: [
                for (final entry in state.assignments.entries) ...[
                  _WordRow(
                    playerIndex: entry.key,
                    value: entry.value.value,
                    isCurrentPlayer: entry.key == activeParty.playerIndex,
                  ),
                  if (entry.key != state.assignments.length)
                    const SizedBox(height: 10),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _WordRow extends StatelessWidget {
  const _WordRow({
    required this.playerIndex,
    required this.value,
    required this.isCurrentPlayer,
  });

  final int playerIndex;
  final String value;
  final bool isCurrentPlayer;

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: isCurrentPlayer ? palette.primarySoft : palette.surfaceMuted,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              isCurrentPlayer
                  ? palette.primary.withValues(alpha: 0.14)
                  : palette.outline,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                '$playerIndex',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Игрок $playerIndex',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight:
                        isCurrentPlayer ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
                if (isCurrentPlayer) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Твой экран',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: palette.primaryStrong,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            isCurrentPlayer ? 'Скрыто' : value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color:
                  isCurrentPlayer ? palette.primaryStrong : palette.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
