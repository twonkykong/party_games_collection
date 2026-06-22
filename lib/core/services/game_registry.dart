import 'package:flutter/material.dart';

import '../models/game_meta.dart';
import '../models/game_type.dart';

class GameRegistry {
  static const games = [
    GameMeta(
      type: GameType.spy,
      title: 'Шпион',
      description:
          'Общее слово для команды и секретная роль для одного или двух игроков.',
      icon: Icons.visibility_rounded,
      accent: Color(0xFFB45E3C),
    ),
    GameMeta(
      type: GameType.whoAmI,
      title: 'Кто я',
      description:
          'Уникальные слова для всех игроков и два локальных режима показа.',
      icon: Icons.psychology_alt_rounded,
      accent: Color(0xFFD79A49),
    ),
    GameMeta(
      type: GameType.mafia,
      title: 'Мафия',
      description:
          'Детерминированная раздача ролей по коду и локальный трекер состава партии.',
      icon: Icons.nightlife_rounded,
      accent: Color(0xFF8F5D52),
    ),
    GameMeta(
      type: GameType.bunker,
      title: 'Бункер',
      description:
          'Личные характеристики, обзор игроков, раунды и локальный прогресс выживания.',
      icon: Icons.shield_moon_rounded,
      accent: Color(0xFF5F6A5D),
    ),
    GameMeta(
      type: GameType.alias,
      title: 'Элиас',
      description:
          'Командная игра с локальным счётом, таймером и детерминированной колодой слов.',
      icon: Icons.bolt_rounded,
      accent: Color(0xFFB9804A),
    ),
  ];

  static GameMeta byType(GameType type) {
    return games.firstWhere((game) => game.type == type);
  }
}
