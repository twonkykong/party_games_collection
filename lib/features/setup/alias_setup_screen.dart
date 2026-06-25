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
import '../../shared/widgets/party_qr_code_card.dart';
import '../../shared/widgets/primary_action_button.dart';
import '../../shared/widgets/section_card.dart';
import '../../shared/widgets/setting_stepper.dart';
import '../../shared/widgets/word_source_mode_selector.dart';
import '../../shared/widgets/wheel_index_picker.dart';

class AliasSetupScreen extends StatefulWidget {
  const AliasSetupScreen({super.key});

  @override
  State<AliasSetupScreen> createState() => _AliasSetupScreenState();
}

class _AliasSetupScreenState extends State<AliasSetupScreen> {
  static const _roundOptions = [30, 45, 60, 75, 90, 120];
  late int _teams;
  late int _roundSeconds;
  late int _targetScore;
  late DictionaryMode _mode;
  late WordSourceMode _sourceMode;
  int _selectedTeamIndex = 1;
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
    final draft = AppScope.of(context).aliasSetupDraft;
    _teams = draft.teamCount;
    _roundSeconds = draft.roundSeconds;
    _targetScore = draft.targetScore;
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
      _selectedTeamIndex = 1;
    });
    final configuration = PartyConfiguration(
      version: PartyCodeVersion.v3,
      gameType: GameType.alias,
      playerCount: _teams,
      dictionaryMode: effectiveMode,
      wordSourceMode: _sourceMode,
      seed: app.codec.generateSeed(),
      aliasRoundSeconds: _roundSeconds,
      aliasTargetScore: _targetScore,
    );
    final code = app.codec.encode(configuration);
    await _runCodeAnimation(code);
    await app.updateAliasSetupDraft(
      AliasSetupDraft(
        teamCount: _teams,
        roundSeconds: _roundSeconds,
        targetScore: _targetScore,
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
    for (var frame = 0; frame < 10; frame++) {
      await Future<void>.delayed(const Duration(milliseconds: 55));
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
      _selectedTeamIndex,
    );
    await app.saveActiveParty(party);
    app.playSound(UiSound.tapSoft);
    if (!mounted) {
      return;
    }
    Navigator.of(context).pushNamed(AppRouter.aliasGamePath, arguments: party);
  }

  void _shiftRoundSeconds(int direction) {
    final currentIndex = _roundOptions.indexOf(_roundSeconds);
    final nextIndex = (currentIndex + direction).clamp(
      0,
      _roundOptions.length - 1,
    );
    final nextValue = _roundOptions[nextIndex];
    if (nextValue == _roundSeconds) {
      return;
    }
    AppScope.of(context).playSound(UiSound.pickerTick);
    setState(() => _roundSeconds = nextValue);
  }

  void _shiftTargetScore(int direction) {
    final nextValue = (_targetScore + (direction * 5)).clamp(10, 60);
    if (nextValue == _targetScore) {
      return;
    }
    AppScope.of(context).playSound(UiSound.pickerTick);
    setState(() => _targetScore = nextValue);
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final dirtyWordsEnabled = AppScope.of(context).dirtyWordsEnabled;
    final customWordsCount = AppScope.of(context).customAliasWords.length;
    final requiresCustomWords =
        _sourceMode == WordSourceMode.customOnly && customWordsCount == 0;

    return AppShell(
      title: 'Элиас',
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
                  'Код зафиксирует число команд, длительность раунда, цель по очкам и словарь.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 18),
                SettingStepper(
                  label: 'Количество команд',
                  value: _teams,
                  min: 1,
                  max: 6,
                  onChanged:
                      (value) => setState(() {
                        _teams = value;
                        if (_selectedTeamIndex > value) {
                          _selectedTeamIndex = value;
                        }
                      }),
                ),
                const SizedBox(height: 18),
                Text(
                  'Время раунда',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                SettingStepper(
                  label: 'Длительность',
                  value: _roundSeconds,
                  min: 30,
                  max: 120,
                  valueLabelBuilder: (value) => '$value сек',
                  onChanged: (_) {},
                  onDecrease: () => _shiftRoundSeconds(-1),
                  onIncrease: () => _shiftRoundSeconds(1),
                ),
                const SizedBox(height: 18),
                SettingStepper(
                  label: 'Очков до победы',
                  value: _targetScore,
                  min: 10,
                  max: 60,
                  valueLabelBuilder: (value) => '$value очк',
                  onChanged: (_) {},
                  onDecrease: () => _shiftTargetScore(-1),
                  onIncrease: () => _shiftTargetScore(1),
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
                      ? 'Пользовательских слов для Элиаса пока нет.'
                      : 'Пользовательских слов для Элиаса: $customWordsCount',
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
                    'Сейчас активны только обычные слова. Режимы 18+ включаются в настройках.',
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
            SectionCard(
              color: palette.surfaceMuted,
              child: Column(
                children: [
                  Text(
                    'Код партии',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 22,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [palette.secondarySoft, palette.primarySoft],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: SelectableText(
                      _isGenerating ? _animatedCode : _generatedCode!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontSize: 30, letterSpacing: 1.4),
                    ),
                  ),
                  if (!_isGenerating && _generatedCode != null) ...[
                    const SizedBox(height: 16),
                    PartyQrCodeCard(code: _generatedCode!),
                    const SizedBox(height: 16),
                  ] else
                    const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final app = AppScope.of(context);
                      final messenger = ScaffoldMessenger.of(context);
                      await Clipboard.setData(
                        ClipboardData(text: _generatedCode!),
                      );
                      if (!mounted) {
                        return;
                      }
                      app.playSound(UiSound.successSoft);
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Код скопирован.')),
                      );
                    },
                    icon: const Icon(Icons.copy_rounded),
                    label: const Text('Скопировать код'),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Ваша команда',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  WheelIndexPicker(
                    itemCount: _teams,
                    value: _selectedTeamIndex,
                    labelBuilder: (_) => 'Команда',
                    onChanged:
                        (value) => setState(() => _selectedTeamIndex = value),
                    onValueSettled:
                        (_) =>
                            AppScope.of(context).playSound(UiSound.pickerTick),
                  ),
                  const SizedBox(height: 12),
                  PrimaryActionButton(
                    label: 'Открыть команду',
                    onPressed: _startGame,
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
