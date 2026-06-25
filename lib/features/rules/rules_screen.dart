import 'package:flutter/material.dart';

import '../../shared/widgets/app_shell.dart';
import '../../shared/widgets/section_card.dart';

class RulesScreen extends StatelessWidget {
  const RulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Правила',
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          _GameRuleCard(
            title: 'Шпион',
            description: 'Один или два игрока знают меньше остальных.',
            goal:
                'Обычные игроки пытаются вычислить шпиона, а шпион старается понять общую тему разговора.',
            flow:
                'Все по очереди задают вопросы и отвечают так, чтобы не назвать слово слишком прямо.',
            finish:
                'Раунд заканчивается, когда компания уверена в шпионе или шпион готов назвать тему.',
          ),
          SizedBox(height: 14),
          _GameRuleCard(
            title: 'Кто я',
            description: 'Каждый игрок пытается понять, кто он.',
            goal:
                'По вопросам и ответам сузить круг вариантов и первым назвать своё слово.',
            flow:
                'Игрок задаёт короткие вопросы, остальные отвечают без долгих подсказок и прямого раскрытия.',
            finish:
                'Игра продолжается, пока все не угадают свои слова или пока вы не решите остановить раунд.',
          ),
          SizedBox(height: 14),
          _GameRuleCard(
            title: 'Элиас',
            description: 'Команды объясняют слова друг другу на время.',
            goal: 'Набрать нужное количество очков быстрее остальных команд.',
            flow:
                'Один объясняет слово без однокоренных подсказок, команда угадывает, затем сразу идёт следующее.',
            finish:
                'Побеждает команда, которая первой добирается до цели по очкам.',
          ),
          SizedBox(height: 14),
          _GameRuleCard(
            title: 'Мафия',
            description: 'Скрытые роли, обсуждение и блеф.',
            goal:
                'Мирным нужно вычислить мафию, а мафии — пережить голосования и взять численный перевес.',
            flow:
                'Ночью роли действуют тайно, днём все обсуждают произошедшее и голосуют против подозреваемого.',
            finish:
                'Игра заканчивается, когда одна из сторон полностью выполняет свою цель.',
          ),
          SizedBox(height: 14),
          _GameRuleCard(
            title: 'Бункер',
            description:
                'Нужно решить, кто действительно достоин места в бункере.',
            goal:
                'Убедить остальных в своей полезности и выбрать самый сильный состав выживших.',
            flow:
                'Игроки постепенно раскрывают характеристики, спорят, защищаются и голосуют за исключение.',
            finish:
                'Финал открывается после обсуждений, когда группа определилась с тем, кто остаётся.',
          ),
        ],
      ),
    );
  }
}

class _GameRuleCard extends StatelessWidget {
  const _GameRuleCard({
    required this.title,
    required this.description,
    required this.goal,
    required this.flow,
    required this.finish,
  });

  final String title;
  final String description;
  final String goal;
  final String flow;
  final String finish;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Text(description),
          const SizedBox(height: 14),
          _RuleLine(label: 'Цель', text: goal),
          const SizedBox(height: 10),
          _RuleLine(label: 'Как проходит игра', text: flow),
          const SizedBox(height: 10),
          _RuleLine(label: 'Когда завершать', text: finish),
        ],
      ),
    );
  }
}

class _RuleLine extends StatelessWidget {
  const _RuleLine({required this.label, required this.text});

  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(text),
      ],
    );
  }
}
