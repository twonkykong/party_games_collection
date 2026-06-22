import 'mafia_role.dart';

class MafiaPresetDefinition {
  const MafiaPresetDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.playerCounts,
  });

  final String id;
  final String title;
  final String description;
  final Map<int, List<String>> playerCounts;
}

class MafiaCatalog {
  const MafiaCatalog({required this.rolesById, required this.presetsById});

  final Map<String, MafiaRole> rolesById;
  final Map<String, MafiaPresetDefinition> presetsById;
}
