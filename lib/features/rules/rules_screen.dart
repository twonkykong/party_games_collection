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
            description:
                'Один игрок знает меньше остальных и пытается не выдать себя.',
            createParty:
                'Выберите игроков, число шпионов и подбор слов, затем поделитесь кодом.',
            joinParty: 'Введите код и выберите свой индекс через карусель.',
            playerView:
                'Обычный игрок видит общее слово, шпион получает только подсказку.',
            roundFlow:
                'Обсуждайте слово, задавайте вопросы и ищите шпиона. Шпиону нужно понять, о чём говорят остальные.',
            ending:
                'Остановитесь, когда группа уверена в шпионе или шпион уже догадался о слове.',
          ),
          SizedBox(height: 14),
          _GameRuleCard(
            title: 'Кто я',
            description:
                'Каждый игрок получает слово и пытается отгадать его по вопросам остальных.',
            createParty:
                'Выберите игроков и подбор слов, затем создайте код партии.',
            joinParty:
                'Введите код, выберите свой индекс и откройте игру на своём устройстве.',
            playerView:
                'В режиме «Ко лбу» своё слово открывается удержанием, в режиме «Список» ведущий видит все слова.',
            roundFlow:
                'Игрок задаёт вопросы о себе, остальные отвечают коротко, а слово постепенно сужается.',
            ending:
                'Завершайте раунд, когда все отгадали свои слова или вы выбрали победителя.',
          ),
          SizedBox(height: 14),
          _GameRuleCard(
            title: 'Элиас',
            description:
                'Команды объясняют слова друг другу на время и набирают очки.',
            createParty:
                'Настройте команды, длительность раунда, цель по очкам и словарь.',
            joinParty:
                'Введите код и выберите свою команду через ту же карусель.',
            playerView:
                'Команда видит текущее слово, таймер и счёт именно своей партии.',
            roundFlow:
                'Один объясняет, остальные угадывают. За угаданное слово плюс, за пропуск переход к следующему.',
            ending:
                'Игра заканчивается, когда команда достигает цели по очкам или вы решаете остановить матч.',
          ),
          SizedBox(height: 14),
          _GameRuleCard(
            title: 'Мафия',
            description:
                'Скрытые роли, блеф и обсуждение того, кому можно доверять.',
            createParty:
                'Выберите число игроков и пресет ролей, затем создайте код партии.',
            joinParty:
                'Каждый игрок вводит код и открывает свою роль под своим индексом.',
            playerView:
                'Игрок видит только собственную роль, а ведущий может использовать общий код партии.',
            roundFlow:
                'Ночь чередуется с днём: роли действуют, затем группа обсуждает и голосует.',
            ending:
                'Заканчивайте, когда мафия получила перевес или мирные вычислили всех мафиози.',
          ),
          SizedBox(height: 14),
          _GameRuleCard(
            title: 'Бункер',
            description:
                'Группа решает, кто действительно нужен, чтобы пережить катастрофу под землёй.',
            createParty:
                'Выберите игроков, создайте код и откройте каждому личную карточку через свой индекс.',
            joinParty:
                'Каждый участник вводит один и тот же код и получает свой детерминированный набор характеристик.',
            playerView:
                'Личное досье скрыто от других, а в обзоре постепенно раскрываются общие данные о каждом.',
            roundFlow:
                'Открывайте характеристики по раундам, спорьте, применяйте действия и решайте, кого оставить в бункере.',
            ending:
                'После всех обсуждений удержанием открывайте финал и смотрите, чем закончилась история группы.',
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
    required this.createParty,
    required this.joinParty,
    required this.playerView,
    required this.roundFlow,
    required this.ending,
  });

  final String title;
  final String description;
  final String createParty;
  final String joinParty;
  final String playerView;
  final String roundFlow;
  final String ending;

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
          _RuleLine(label: 'Создать партию', text: createParty),
          const SizedBox(height: 10),
          _RuleLine(label: 'Присоединиться', text: joinParty),
          const SizedBox(height: 10),
          _RuleLine(label: 'Что видит игрок', text: playerView),
          const SizedBox(height: 10),
          _RuleLine(label: 'Как проходит игра', text: roundFlow),
          const SizedBox(height: 10),
          _RuleLine(label: 'Когда завершать', text: ending),
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
