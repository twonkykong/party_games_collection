import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_palette.dart';
import '../../app/app_router.dart';
import '../../core/models/dictionary_mode.dart';
import '../../core/models/game_setup_drafts.dart';
import '../../core/models/game_type.dart';
import '../../core/models/mafia_preset.dart';
import '../../core/models/party_code_version.dart';
import '../../core/models/party_configuration.dart';
import '../../core/models/word_source_mode.dart';
import '../../core/services/app_scope.dart';
import '../../core/services/ui_sound_service.dart';
import '../../shared/widgets/app_shell.dart';
import '../../shared/widgets/choice_chips_row.dart';
import '../../shared/widgets/party_setup_code_card.dart';
import '../../shared/widgets/primary_action_button.dart';
import '../../shared/widgets/section_card.dart';
import '../../shared/widgets/setting_stepper.dart';

class MafiaSetupScreen extends StatefulWidget {
  const MafiaSetupScreen({super.key});

  @override
  State<MafiaSetupScreen> createState() => _MafiaSetupScreenState();
}

class _MafiaSetupScreenState extends State<MafiaSetupScreen> {
  late int _players;
  late MafiaPreset _preset;
  int _selectedPlayerIndex = 1;
  String? _generatedCode;
  bool _isGenerating = false;
  String _animatedCode = '';
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) {
      return;
    }
    final draft = AppScope.of(context).mafiaSetupDraft;
    _players = draft.playerCount;
    _preset = draft.preset;
    _initialized = true;
  }

  Future<void> _generate() async {
    final app = AppScope.of(context);
    app.playSound(UiSound.tapSoft);
    setState(() {
      _isGenerating = true;
      _selectedPlayerIndex = 1;
    });
    final configuration = PartyConfiguration(
      version: PartyCodeVersion.v3,
      gameType: GameType.mafia,
      playerCount: _players,
      dictionaryMode: DictionaryMode.family,
      wordSourceMode: WordSourceMode.builtIn,
      seed: app.codec.generateSeed(),
      mafiaPresetId: _preset.code,
    );
    final code = app.codec.encode(configuration);
    await _runCodeAnimation(code);
    await app.updateMafiaSetupDraft(
      MafiaSetupDraft(playerCount: _players, preset: _preset),
    );
    app.playSound(UiSound.successSoft);
    if (!mounted) {
      return;
    }
    setState(() {
      _generatedCode = code;
      _isGenerating = false;
    });
  }

  Future<void> _runCodeAnimation(String finalCode) async {
    const alphabet =
        '23456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';
    for (var frame = 0; frame < 10; frame++) {
      await Future<void>.delayed(const Duration(milliseconds: 55));
      if (!mounted) {
        return;
      }
      setState(() {
        _animatedCode =
            List.generate(
              finalCode.length,
              (index) => alphabet[(frame * 5 + index * 7) % alphabet.length],
            ).join();
      });
    }
  }

  Future<void> _startGame() async {
    final app = AppScope.of(context);
    final code = _generatedCode;
    if (code == null) {
      return;
    }
    final party = app.runtime.buildActivePartyFromCode(
      code,
      _selectedPlayerIndex,
    );
    await app.saveActiveParty(party);
    app.playSound(UiSound.tapSoft);
    if (!mounted) {
      return;
    }
    Navigator.of(context).pushNamed(AppRouter.mafiaGamePath, arguments: party);
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final minPlayers = _preset == MafiaPreset.classic ? 4 : 6;

    if (_players < minPlayers) {
      _players = minPlayers;
    }

    return AppShell(
      title: 'Мафия',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          SectionCard(
            color: palette.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Настройка партии',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Создайте код партии и раздайте роли одинаково на всех устройствах.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 18),
                SettingStepper(
                  label: 'Количество игроков',
                  value: _players,
                  min: minPlayers,
                  max: 12,
                  onChanged:
                      (value) => setState(() {
                        _players = value;
                        if (_selectedPlayerIndex > value) {
                          _selectedPlayerIndex = value;
                        }
                      }),
                ),
                const SizedBox(height: 18),
                Text(
                  'Пресет ролей',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                ChoiceChipsRow<MafiaPreset>(
                  value: _preset,
                  options: MafiaPreset.values,
                  labelBuilder: (preset) => preset.label,
                  onChanged: (preset) {
                    AppScope.of(context).playSound(UiSound.toggleSoft);
                    setState(() => _preset = preset);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          PrimaryActionButton(
            label: _isGenerating ? 'Генерируем...' : 'Создать код партии',
            onPressed: _isGenerating ? null : _generate,
          ),
          if (_isGenerating || _generatedCode != null) ...[
            const SizedBox(height: 24),
            PartySetupCodeCard(
              palette: palette,
              code: _isGenerating ? _animatedCode : _generatedCode!,
              selectedIndex: _selectedPlayerIndex,
              itemCount: _players,
              onChanged:
                  (value) => setState(() => _selectedPlayerIndex = value),
              onCopy: () async {
                final app = AppScope.of(context);
                final messenger = ScaffoldMessenger.of(context);
                await Clipboard.setData(ClipboardData(text: _generatedCode!));
                if (!mounted) {
                  return;
                }
                app.playSound(UiSound.successSoft);
                messenger.showSnackBar(
                  const SnackBar(content: Text('Код скопирован.')),
                );
              },
              onStart: _startGame,
            ),
          ],
        ],
      ),
    );
  }
}
