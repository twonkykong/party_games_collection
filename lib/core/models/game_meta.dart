import 'package:flutter/material.dart';

import 'game_type.dart';

class GameMeta {
  const GameMeta({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    required this.accent,
  });

  final GameType type;
  final String title;
  final String description;
  final IconData icon;
  final Color accent;
}
