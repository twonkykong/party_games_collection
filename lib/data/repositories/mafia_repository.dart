import '../models/mafia_catalog.dart';
import '../models/mafia_role.dart';
import 'asset_json_loader.dart';

class MafiaRepository {
  MafiaRepository({AssetJsonLoader? loader})
    : _loader = loader ?? AssetJsonLoader();

  static const _assetPath = 'assets/data/mafia_roles_ultra.json';
  final AssetJsonLoader _loader;
  MafiaCatalog? _cache;

  Future<MafiaCatalog> load() async {
    _cache ??= await _readAll();
    return _cache!;
  }

  Future<MafiaCatalog> _readAll() async {
    final decoded = await _loader.load<Map<String, dynamic>>(_assetPath);
    final roles =
        (decoded['roles'] as List<dynamic>? ?? const [])
            .map((item) => MafiaRole.fromJson(item as Map<String, dynamic>))
            .toList();
    final presetsJson = decoded['presets'] as Map<String, dynamic>? ?? const {};
    final presets = <String, MafiaPresetDefinition>{};

    for (final entry in presetsJson.entries) {
      final value = entry.value as Map<String, dynamic>;
      final countsJson =
          value['playerCounts'] as Map<String, dynamic>? ?? const {};
      presets[entry.key] = MafiaPresetDefinition(
        id: entry.key,
        title: value['title'] as String,
        description: value['description'] as String,
        playerCounts: {
          for (final count in countsJson.entries)
            int.parse(count.key): List<String>.from(
              count.value as List<dynamic>,
            ),
        },
      );
    }

    return MafiaCatalog(
      rolesById: {for (final role in roles) role.id: role},
      presetsById: presets,
    );
  }
}
