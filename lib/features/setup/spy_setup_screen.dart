import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_palette.dart';
import '../../app/app_router.dart';
import '../../core/models/dictionary_mode.dart';
import '../../core/models/game_setup_drafts.dart';
import '../../core/models/game_type.dart';
import '../../core/models/party_code_version.dart';
import '../../core/models/party_configuration.dart';
import '../../core/models/word_source_mode.dart';
import '../../core/services/app_scope.dart';
import '../../core/services/ui_sound_service.dart';
import '../../shared/widgets/app_shell.dart';
import '../../shared/widgets/dictionary_mode_slider.dart';
import '../../shared/widgets/party_setup_code_card.dart';
import '../../shared/widgets/primary_action_button.dart';
import '../../shared/widgets/section_card.dart';
import '../../shared/widgets/setting_stepper.dart';
import '../../shared/widgets/word_source_mode_selector.dart';

class SpySetupScreen extends StatefulWidget {
  const SpySetupScreen({super.key});

  @override
  State<SpySetupScreen> createState() => _SpySetupScreenState();
}

class _SpySetupScreenState extends State<SpySetupScreen> {
  late int _players;
  late int _spies;
  late DictionaryMode _mode;
  late WordSourceMode _sourceMode;
  bool _initialized = false;
  int _selectedPlayerIndex = 1;
  String? _generatedCode;
  bool _isGenerating = false;
  String _animatedCode = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) {
      return;
    }
    final draft = AppScope.of(context).spySetupDraft;
    _players = draft.playerCount;
    _spies = draft.spyCount;
    _mode = draft.dictionaryMode;
    _sourceMode = draft.wordSourceMode;
    _initialized = true;
  }

  Future<void> _generate() async {
    final app = AppScope.of(context);
    final effectiveMode = app.dirtyWordsEnabled ? _mode : DictionaryMode.family;
    app.playSound(UiSound.tapSoft);
    setState(() {
      _isGenerating = true;
      _selectedPlayerIndex = 1;
    });
    final configuration = PartyConfiguration(
      version: PartyCodeVersion.v3,
      gameType: GameType.spy,
      playerCount: _players,
      dictionaryMode: effectiveMode,
      wordSourceMode: _sourceMode,
      seed: app.codec.generateSeed(),
      spyCount: _spies,
    );
    final code = app.codec.encode(configuration);
    await _runCodeAnimation(code);
    await app.updateSpySetupDraft(
      SpySetupDraft(
        playerCount: _players,
        spyCount: _spies,
        dictionaryMode: effectiveMode,
        wordSourceMode: _sourceMode,
      ),
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
    for (var frame = 0; frame < 12; frame++) {
      await Future<void>.delayed(const Duration(milliseconds: 60));
      if (!mounted) {
        return;
      }
      setState(() {
        _animatedCode =
            List.generate(
              finalCode.length,
              (index) => alphabet[(frame * 7 + index * 11) % alphabet.length],
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
    Navigator.of(context).pushNamed(AppRouter.spyGamePath, arguments: party);
  }

  @override
  Widget build(BuildContext context) {
    final maxSpies = _players >= 6 ? 2 : 1;
    final palette = AppPalette.of(context);
    final dirtyWordsEnabled = AppScope.of(context).dirtyWordsEnabled;
    final customWordsCount = AppScope.of(context).customSpyWords.length;
    final requiresCustomWords =
        _sourceMode == WordSourceMode.customOnly && customWordsCount == 0;
    if (_spies > maxSpies) {
      _spies = maxSpies;
    }

    return AppShell(
      title: 'Шпион',
      child: ListView(
        padding: const EdgeInsets.all(20),
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
                const SizedBox(height: 6),
                Text(
                  'Код зафиксирует параметры, seed и роли. Хост позже тоже откроет игру только через этот код.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                SettingStepper(
                  label: 'Количество игроков',
                  value: _players,
                  min: 3,
                  max: 10,
                  onChanged:
                      (value) => setState(() {
                        _players = value;
                        if (_selectedPlayerIndex > value) {
                          _selectedPlayerIndex = value;
                        }
                      }),
                ),
                const SizedBox(height: 18),
                SettingStepper(
                  label: 'Количество шпионов',
                  value: _spies,
                  min: 1,
                  max: maxSpies,
                  onChanged: (value) => setState(() => _spies = value),
                ),
                const SizedBox(height: 18),
                Text(
                  'Источник слов',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                WordSourceModeSelector(
                  value: _sourceMode,
                  onChanged: (value) {
                    AppScope.of(context).playSound(UiSound.toggleSoft);
                    setState(() => _sourceMode = value);
                  },
                ),
                const SizedBox(height: 10),
                Text(
                  customWordsCount == 0
                      ? 'Пользовательских слов для Шпиона пока нет.'
                      : 'Пользовательских слов для Шпиона: $customWordsCount',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (requiresCustomWords) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Для режима "Только свои" сначала добавьте слова в настройках.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: palette.errorStrong,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                Text(
                  'Режим встроенных слов',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                if (dirtyWordsEnabled)
                  DictionaryModeSlider(
                    value: _mode,
                    onChanged: (mode) {
                      AppScope.of(context).playSound(UiSound.toggleSoft);
                      setState(() => _mode = mode);
                    },
                  )
                else
                  Text(
                    'Сейчас используются только обычные слова. Взрослые режимы можно включить в настройках.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          PrimaryActionButton(
            label: _isGenerating ? 'Генерируем...' : 'Создать код партии',
            onPressed: _isGenerating || requiresCustomWords ? null : _generate,
          ),
          if (_isGenerating || _generatedCode != null) ...[
            const SizedBox(height: 24),
            PartySetupCodeCard(
              palette: palette,
              code: _isGenerating ? _animatedCode : _generatedCode!,
              showQr: !_isGenerating && _generatedCode != null,
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
