import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_palette.dart';
import '../../app/app_router.dart';
import '../../core/models/active_party.dart';
import '../../core/models/game_type.dart';
import '../../core/services/app_scope.dart';
import '../../core/services/game_registry.dart';
import '../../core/services/ui_sound_service.dart';
import '../../shared/widgets/app_shell.dart';
import '../../shared/widgets/labeled_value_row.dart';
import '../../shared/widgets/party_qr_scan_sheet.dart';
import '../../shared/widgets/party_setup_code_card.dart';
import '../../shared/widgets/primary_action_button.dart';
import '../../shared/widgets/section_card.dart';

class JoinPartyScreen extends StatefulWidget {
  const JoinPartyScreen({super.key});

  @override
  State<JoinPartyScreen> createState() => _JoinPartyScreenState();
}

class _JoinPartyScreenState extends State<JoinPartyScreen> {
  final _controller = TextEditingController();
  String? _error;
  ActiveParty? _candidate;
  int _selectedPlayerIndex = 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatError(Object error) {
    final raw = '$error'.trim();
    const prefixes = ['Exception: ', 'StateError: ', 'Bad state: '];
    for (final prefix in prefixes) {
      if (raw.startsWith(prefix)) {
        return raw.substring(prefix.length).trim();
      }
    }
    return raw;
  }

  Future<void> _parseCode() async {
    final app = AppScope.of(context);
    try {
      final activeParty = app.runtime.buildActivePartyFromCode(
        _controller.text,
        1,
      );
      app.playSound(UiSound.successSoft);
      setState(() {
        _error = null;
        _selectedPlayerIndex = 1;
        _candidate = activeParty;
      });
    } catch (error) {
      app.playSound(UiSound.errorSoft);
      setState(() {
        _candidate = null;
        _error = _formatError(error);
      });
    }
  }

  Future<void> _openParty() async {
    final app = AppScope.of(context);
    final candidate = _candidate;
    if (candidate == null) {
      setState(() {
        _error = 'Сначала введите и проверьте код партии.';
      });
      app.playSound(UiSound.errorSoft);
      return;
    }
    final activeParty = app.runtime.buildActivePartyFromCode(
      candidate.code,
      _selectedPlayerIndex,
    );
    await app.saveActiveParty(activeParty);
    app.playSound(UiSound.tapSoft);
    if (!mounted) {
      return;
    }
    Navigator.of(context).pushNamed(
      AppRouter.gamePath(activeParty.gameType),
      arguments: activeParty,
    );
  }

  @override
  Widget build(BuildContext context) {
    final candidate = _candidate;
    final palette = AppPalette.of(context);
    final isAlias = candidate?.gameType == GameType.alias;

    return AppShell(
      title: 'Ввести код',
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SectionCard(
            padding: const EdgeInsets.all(18),
            color: palette.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Код партии',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Вставьте код, и приложение восстановит игру, параметры и seed без ручного выбора игры.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _controller,
                  textCapitalization: TextCapitalization.none,
                  decoration: InputDecoration(
                    labelText: 'Например, A9qW5xJ3',
                    prefixIcon: const Icon(Icons.key_rounded),
                    suffixIcon:
                        candidate != null
                            ? Icon(
                              Icons.verified_rounded,
                              color: palette.success,
                            )
                            : null,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    AppScope.of(context).playSound(UiSound.tapSoft);
                    final data = await Clipboard.getData(Clipboard.kTextPlain);
                    final value = data?.text?.trim();
                    if (value == null || value.isEmpty) {
                      return;
                    }
                    _controller.text = value;
                    await _parseCode();
                  },
                  icon: const Icon(Icons.content_paste_go_rounded),
                  label: const Text('Вставить'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PrimaryActionButton(
                  label: 'Проверить',
                  onPressed: _parseCode,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              final app = AppScope.of(context);
              app.playSound(UiSound.tapSoft);
              final code = await showPartyQrScannerSheet(context);
              if (!mounted || code == null || code.isEmpty) {
                return;
              }
              _controller.text = code;
              await _parseCode();
            },
            icon: const Icon(Icons.qr_code_scanner_rounded),
            label: const Text('Сканировать QR'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            SectionCard(
              color: palette.errorSoft,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.error_outline_rounded, color: palette.errorStrong),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _error!,
                      style: TextStyle(color: palette.errorStrong),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (candidate != null) ...[
            const SizedBox(height: 24),
            SectionCard(
              color: palette.surfaceMuted,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Партия распознана',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Данные ниже получены напрямую из кода партии.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 14),
                  LabeledValueRow(
                    label: 'Игра',
                    value: GameRegistry.byType(candidate.gameType).title,
                  ),
                  const SizedBox(height: 10),
                  LabeledValueRow(
                    label: isAlias ? 'Команд' : 'Игроков',
                    value: '${candidate.configuration.playerCount}',
                  ),
                  const SizedBox(height: 10),
                  LabeledValueRow(
                    label: 'Режим',
                    value: candidate.configuration.dictionaryMode.label,
                  ),
                  if (candidate.gameType == GameType.spy ||
                      candidate.gameType == GameType.whoAmI ||
                      candidate.gameType == GameType.alias) ...[
                    const SizedBox(height: 10),
                    LabeledValueRow(
                      label: 'Источник',
                      value: candidate.configuration.wordSourceMode.label,
                    ),
                  ],
                  if (candidate.gameType == GameType.spy) ...[
                    const SizedBox(height: 10),
                    LabeledValueRow(
                      label: 'Шпионов',
                      value: '${candidate.configuration.spyCount}',
                    ),
                  ],
                  if (candidate.gameType == GameType.mafia) ...[
                    const SizedBox(height: 10),
                    LabeledValueRow(
                      label: 'Пресет',
                      value: candidate.configuration.mafiaPresetId ?? 'classic',
                    ),
                  ],
                  if (candidate.gameType == GameType.alias) ...[
                    const SizedBox(height: 10),
                    LabeledValueRow(
                      label: 'Раунд',
                      value:
                          '${candidate.configuration.aliasRoundSeconds ?? 60} сек',
                    ),
                    const SizedBox(height: 10),
                    LabeledValueRow(
                      label: 'Победа',
                      value:
                          '${candidate.configuration.aliasTargetScore ?? 30} очков',
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text(
              isAlias ? 'Выберите команду' : 'Выберите индекс игрока',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            PartyPlayerIndexSection(
              key: ValueKey(
                '${candidate.code}-${candidate.configuration.playerCount}-$_selectedPlayerIndex',
              ),
              title: isAlias ? 'Выберите команду' : 'Выберите индекс игрока',
              selectedIndex: _selectedPlayerIndex,
              itemCount: candidate.configuration.playerCount,
              onChanged:
                  (value) => setState(() => _selectedPlayerIndex = value),
              labelBuilder: isAlias ? (value) => 'Команда' : null,
            ),
            const SizedBox(height: 12),
            PrimaryActionButton(label: 'Открыть партию', onPressed: _openParty),
          ],
        ],
      ),
    );
  }
}
