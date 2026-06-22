import 'package:flutter/material.dart';

import '../../app/app_palette.dart';
import '../../core/services/app_scope.dart';
import '../../core/services/ui_sound_service.dart';
import 'primary_action_button.dart';
import 'section_card.dart';
import 'wheel_index_picker.dart';

class PartySetupCodeCard extends StatelessWidget {
  const PartySetupCodeCard({
    required this.palette,
    required this.code,
    required this.selectedIndex,
    required this.itemCount,
    required this.onChanged,
    required this.onCopy,
    required this.onStart,
    super.key,
    this.indexLabel = 'Ваш индекс игрока',
    this.startLabel = 'Начать игру',
    this.selectorLabelBuilder,
  });

  final AppPalette palette;
  final String code;
  final int selectedIndex;
  final int itemCount;
  final ValueChanged<int> onChanged;
  final Future<void> Function() onCopy;
  final Future<void> Function() onStart;
  final String indexLabel;
  final String startLabel;
  final String Function(int value)? selectorLabelBuilder;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      color: palette.surfaceMuted,
      child: Column(
        children: [
          Text('Код партии', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [palette.primarySoft, palette.secondarySoft],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: SelectableText(
              code,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 30,
                letterSpacing: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onCopy,
            icon: const Icon(Icons.copy_rounded),
            label: const Text('Скопировать код'),
          ),
          const SizedBox(height: 18),
          PartyPlayerIndexSection(
            title: indexLabel,
            selectedIndex: selectedIndex,
            itemCount: itemCount,
            labelBuilder: selectorLabelBuilder,
            onChanged: onChanged,
            actionLabel: startLabel,
            onAction: onStart,
          ),
        ],
      ),
    );
  }
}

class PartyPlayerIndexSection extends StatelessWidget {
  const PartyPlayerIndexSection({
    required this.title,
    required this.selectedIndex,
    required this.itemCount,
    required this.onChanged,
    super.key,
    this.labelBuilder,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final int selectedIndex;
  final int itemCount;
  final ValueChanged<int> onChanged;
  final String Function(int value)? labelBuilder;
  final String? actionLabel;
  final Future<void> Function()? onAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        WheelIndexPicker(
          itemCount: itemCount,
          value: selectedIndex,
          labelBuilder: labelBuilder,
          onChanged: onChanged,
          onValueSettled:
              (_) => AppScope.of(context).playSound(UiSound.pickerTick),
        ),
        if (actionLabel != null && onAction != null) ...[
          const SizedBox(height: 12),
          PrimaryActionButton(label: actionLabel!, onPressed: onAction!),
        ],
      ],
    );
  }
}
