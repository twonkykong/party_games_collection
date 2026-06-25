import 'package:flutter/services.dart';

import 'package:flutter/material.dart';

import '../../app/app_palette.dart';
import '../../core/services/custom_words_transfer.dart';
import '../../core/models/app_theme_preference.dart';
import '../../core/services/app_scope.dart';
import '../../core/services/ui_sound_service.dart';
import '../../shared/widgets/app_bottom_sheet_frame.dart';
import '../../shared/widgets/app_shell.dart';
import '../../shared/widgets/party_qr_code_card.dart';
import '../../shared/widgets/party_qr_scan_sheet.dart';
import '../../shared/widgets/section_card.dart';

const _appBuildLabel = 'v1.0';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _successMessage;
  bool _wordsVisible = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<String> _parseWords(String raw) {
    return raw
        .split(',')
        .map((item) => item.trim().replaceAll(RegExp(r'\s+'), ' '))
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  Future<void> _addWords() async {
    final app = AppScope.of(context);
    final parsed = _parseWords(_controller.text);
    if (parsed.isEmpty) {
      return;
    }
    final added = await app.addSharedCustomWords(parsed);
    if (!mounted) {
      return;
    }
    _controller.clear();
    setState(() {
      _successMessage =
          added > 0
              ? (added == 1 ? 'Слово добавлено.' : 'Добавлено слов: $added.')
              : 'Новых слов не было: дубликаты уже существуют.';
    });
    app.playSound(added > 0 ? UiSound.successSoft : UiSound.errorSoft);
  }

  Future<void> _copyAllWords() async {
    final app = AppScope.of(context);
    final words = app.customWords;
    if (words.isEmpty) {
      return;
    }
    await Clipboard.setData(ClipboardData(text: words.join('\n')));
    if (!mounted) {
      return;
    }
    setState(() {
      _successMessage = 'Список слов скопирован.';
    });
    app.playSound(UiSound.successSoft);
  }

  Future<void> _exportWordsQr() async {
    final app = AppScope.of(context);
    final words = app.customWords;
    if (words.isEmpty) {
      return;
    }
    final payload = CustomWordsTransfer.encode(words);
    app.playSound(UiSound.tapSoft);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AppBottomSheetFrame(
          maxHeightFactor: 0.72,
          header: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'QR со словами',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Сканируйте этот QR в настройках на другом устройстве, чтобы перенести общий список слов.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              PartyQrCodeCard(
                code: payload,
                caption: 'Этот QR переносит только пользовательские слова.',
              ),
            ],
          ),
          child: const SizedBox.shrink(),
        );
      },
    );
  }

  Future<void> _importWordsQr() async {
    final app = AppScope.of(context);
    app.playSound(UiSound.tapSoft);
    final raw = await showPartyQrScannerSheet(context);
    if (!mounted || raw == null || raw.isEmpty) {
      return;
    }
    final decoded = CustomWordsTransfer.decode(raw);
    if (decoded == null) {
      setState(() {
        _successMessage = 'Это не QR со словами.';
      });
      app.playSound(UiSound.errorSoft);
      return;
    }
    final added = await app.addSharedCustomWords(decoded);
    if (!mounted) {
      return;
    }
    setState(() {
      _successMessage =
          added > 0
              ? 'Импортировано слов: $added.'
              : 'Новых слов для импорта не оказалось.';
      _wordsVisible = true;
    });
    app.playSound(added > 0 ? UiSound.successSoft : UiSound.errorSoft);
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final palette = AppPalette.of(context);

    return AppShell(
      title: 'Настройки',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          SectionCard(
            color: palette.surface,
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Оформление',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Тёплая тема, мягкие поверхности и тот же премиальный тон на всех экранах.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                SegmentedButton<AppThemePreference>(
                  segments: const [
                    ButtonSegment(
                      value: AppThemePreference.light,
                      label: Text('Светлая'),
                      icon: Icon(Icons.wb_sunny_rounded),
                    ),
                    ButtonSegment(
                      value: AppThemePreference.dark,
                      label: Text('Тёмная'),
                      icon: Icon(Icons.nightlight_rounded),
                    ),
                    ButtonSegment(
                      value: AppThemePreference.system,
                      label: Text('Как в системе'),
                      icon: Icon(Icons.phone_iphone_rounded),
                    ),
                  ],
                  selected: {controller.themePreference},
                  onSelectionChanged: (selection) async {
                    final preference = selection.first;
                    await controller.updateThemePreference(preference);
                    controller.playSound(UiSound.toggleSoft);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            color: palette.surfaceMuted,
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
            child: SwitchListTile.adaptive(
              value: controller.dirtyWordsEnabled,
              contentPadding: EdgeInsets.zero,
              activeColor: palette.primary,
              title: const Text('Грязные слова'),
              subtitle: const Text(
                'Показывать взрослые режимы встроенных словарей в играх со словами',
              ),
              onChanged: (value) async {
                await controller.setDirtyWordsEnabled(value);
                controller.playSound(UiSound.toggleSoft);
              },
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            color: palette.surfaceMuted,
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
            child: SwitchListTile.adaptive(
              value: controller.uiSoundsEnabled,
              contentPadding: EdgeInsets.zero,
              activeColor: palette.primary,
              title: const Text('Звуки интерфейса'),
              subtitle: const Text('Короткие премиальные звуки интерфейса'),
              onChanged: (value) async {
                await controller.setUiSoundsEnabled(value);
                if (value) {
                  controller.playSound(UiSound.toggleSoft);
                }
              },
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Пользовательские слова',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Эти списки хранятся локально на этом устройстве и подключаются в выбранных играх через источник слов.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          _CustomWordsSection(
            inputController: _controller,
            words: controller.customWords,
            wordsVisible: _wordsVisible,
            successMessage: _successMessage,
            onChanged: () => setState(() {}),
            onAdd: _addWords,
            onToggleVisibility: () {
              setState(() => _wordsVisible = !_wordsVisible);
              controller.playSound(UiSound.toggleSoft);
            },
            onCopyAll: _copyAllWords,
            onExportQr: _exportWordsQr,
            onImportQr: _importWordsQr,
            onRemove: (word) async {
              await controller.removeSharedCustomWord(word);
              if (!mounted) {
                return;
              }
              setState(() {
                _successMessage = null;
              });
              controller.playSound(UiSound.toggleSoft);
            },
            onClear: () async {
              await controller.clearSharedCustomWords();
              if (!mounted) {
                return;
              }
              setState(() {
                _successMessage = null;
              });
              controller.playSound(UiSound.toggleSoft);
            },
          ),
          const SizedBox(height: 16),
          Text(
            _appBuildLabel,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: palette.textSecondary.withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'by twonkykong',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: palette.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _CustomWordsSection extends StatelessWidget {
  const _CustomWordsSection({
    required this.inputController,
    required this.words,
    required this.wordsVisible,
    required this.successMessage,
    required this.onChanged,
    required this.onAdd,
    required this.onToggleVisibility,
    required this.onCopyAll,
    required this.onExportQr,
    required this.onImportQr,
    required this.onRemove,
    required this.onClear,
  });

  final TextEditingController inputController;
  final List<String> words;
  final bool wordsVisible;
  final String? successMessage;
  final VoidCallback onChanged;
  final Future<void> Function() onAdd;
  final VoidCallback onToggleVisibility;
  final Future<void> Function() onCopyAll;
  final Future<void> Function() onExportQr;
  final Future<void> Function() onImportQr;
  final Future<void> Function(String word) onRemove;
  final Future<void> Function() onClear;

  List<String> _previewWords() {
    return inputController.text
        .split(',')
        .map((item) => item.trim().replaceAll(RegExp(r'\s+'), ' '))
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final preview = _previewWords();
    final addLabel =
        preview.length <= 1
            ? 'Добавить слово'
            : 'Добавить слова (${preview.length})';

    return SectionCard(
      color: palette.surface,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Общие пользовательские слова',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Один общий список используется в "Кто я", "Элиасе" и "Шпионе". Можно ввести одно слово или несколько через запятую.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          TextField(
            controller: inputController,
            minLines: 1,
            maxLines: 3,
            onChanged: (_) => onChanged(),
            decoration: const InputDecoration(
              hintText: 'Например: Человек-паук, Майкл Джексон, перекур',
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: preview.isEmpty ? null : onAdd,
            child: Text(addLabel),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton(
                onPressed: onToggleVisibility,
                child: Text(wordsVisible ? 'Скрыть слова' : 'Показать слова'),
              ),
              OutlinedButton(
                onPressed: words.isEmpty ? null : onCopyAll,
                child: const Text('Скопировать все'),
              ),
              OutlinedButton(
                onPressed: words.isEmpty ? null : onExportQr,
                child: const Text('Экспорт QR'),
              ),
              OutlinedButton(
                onPressed: onImportQr,
                child: const Text('Импорт QR'),
              ),
            ],
          ),
          if (successMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: palette.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                successMessage!,
                style: TextStyle(
                  color: palette.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          if (!wordsVisible)
            Text(
              'Список скрыт. Откройте его кнопкой выше, если хотите посмотреть или удалить слова.',
              style: Theme.of(context).textTheme.bodyMedium,
            )
          else if (words.isEmpty)
            Text('Пока пусто.', style: Theme.of(context).textTheme.bodyMedium)
          else ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: words
                  .map(
                    (word) => Chip(
                      label: Text(word),
                      onDeleted: () => onRemove(word),
                    ),
                  )
                  .toList(growable: false),
            ),
            const SizedBox(height: 12),
            TextButton(onPressed: onClear, child: const Text('Очистить все')),
          ],
        ],
      ),
    );
  }
}
