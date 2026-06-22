import '../models/bunker_catalog.dart';
import 'asset_json_loader.dart';

class BunkerRepository {
  BunkerRepository({AssetJsonLoader? loader})
    : _loader = loader ?? AssetJsonLoader();

  static const _assetPath = 'assets/data/bunker_ultra.json';
  static const _fallbackProfessions = <String>[
    'Хирург',
    'Терапевт',
    'Военный врач',
    'Инженер-электрик',
    'Механик',
    'Сантехник',
    'Повар',
    'Фермер',
    'Вирусолог',
    'Биолог',
    'Химик',
    'Программист',
    'Системный администратор',
    'Учитель',
    'Психолог',
    'Психиатр',
    'Полицейский',
    'Пожарный',
    'Спасатель',
    'Военный',
    'Сапер',
    'Пилот',
    'Водитель грузовика',
    'Охотник',
    'Строитель',
    'Архитектор',
    'Сварщик',
    'Электромонтер',
    'Фармацевт',
    'Ветеринар',
    'Садовник',
    'Пекарь',
    'Предприниматель',
    'Бухгалтер',
    'Журналист',
    'Музыкант',
    'Таксист',
    'Шахтер',
    'Геолог',
    'Моряк',
    'Рыбак',
    'Инструктор по выживанию',
    'Охранник',
    'Лаборант',
    'Парамедик',
    'Диетолог',
    'Ботаник',
    'Агроном',
    'Тренер',
    'Плотник',
    'Логист',
    'Техник связи',
    'Радиолюбитель',
    'Анестезиолог',
    'Судмедэксперт',
  ];

  final AssetJsonLoader _loader;
  BunkerCatalog? _cache;

  Future<BunkerCatalog> load() async {
    _cache ??= await _readAll();
    return _cache!;
  }

  Future<BunkerCatalog> _readAll() async {
    final decoded = await _loader.load<Map<String, dynamic>>(_assetPath);
    final progressionJson =
        decoded['roundProgressions'] as Map<String, dynamic>? ?? const {};
    final biologicalJson =
        decoded['biological'] as Map<String, dynamic>? ?? const {};
    final finalLoreJson =
        decoded['finalLore'] as Map<String, dynamic>? ?? const {};

    return BunkerCatalog(
      introLore:
          (decoded['introLore'] as List<dynamic>? ?? const [])
              .map(
                (item) => BunkerIntroLore(
                  title: (item as Map<String, dynamic>)['title'] as String,
                  summary: item['summary'] as String,
                  details: item['details'] as String,
                ),
              )
              .toList(),
      disasters: List<String>.from(
        decoded['disasters'] as List<dynamic>? ?? const [],
      ),
      locations: List<String>.from(
        decoded['locations'] as List<dynamic>? ?? const [],
      ),
      capacities: List<String>.from(
        decoded['capacities'] as List<dynamic>? ?? const [],
      ),
      survivalTerms: List<String>.from(
        decoded['survivalTerms'] as List<dynamic>? ?? const [],
      ),
      globalConditions: List<String>.from(
        decoded['globalConditions'] as List<dynamic>? ?? const [],
      ),
      biologicalSex: List<String>.from(
        biologicalJson['sex'] as List<dynamic>? ?? const [],
      ),
      biologicalAges: List<String>.from(
        biologicalJson['age'] as List<dynamic>? ?? const [],
      ),
      biologicalOrientations: List<String>.from(
        biologicalJson['orientation'] as List<dynamic>? ?? const [],
      ),
      professions: _readStringList(
        decoded,
        'professions',
        fallback: _fallbackProfessions,
      ),
      health: List<String>.from(
        decoded['health'] as List<dynamic>? ?? const [],
      ),
      phobias: List<String>.from(
        decoded['phobias'] as List<dynamic>? ?? const [],
      ),
      hobbies: List<String>.from(
        decoded['hobbies'] as List<dynamic>? ?? const [],
      ),
      character: List<String>.from(
        decoded['character'] as List<dynamic>? ?? const [],
      ),
      baggage: List<String>.from(
        decoded['baggage'] as List<dynamic>? ?? const [],
      ),
      facts: List<String>.from(
        decoded['additionalInfo'] as List<dynamic>? ??
            decoded['facts'] as List<dynamic>? ??
            const [],
      ),
      actions: List<String>.from(
        decoded['actions'] as List<dynamic>? ?? const [],
      ),
      conditions: List<String>.from(
        decoded['conditions'] as List<dynamic>? ?? const [],
      ),
      roundProgressions: {
        for (final entry in progressionJson.entries)
          int.parse(entry.key): List<BunkerRoundStep>.from(
            (entry.value as List<dynamic>).map(
              (item) => BunkerRoundStep(
                round: (item as Map<String, dynamic>)['round'] as int,
                openPerPlayer: item['openPerPlayer'] as int,
                kicks: item['kicks'] as int,
              ),
            ),
          ),
      },
      finalGood: _parseFinalLore(finalLoreJson['good'] as List<dynamic>?),
      finalMixed: _parseFinalLore(finalLoreJson['mixed'] as List<dynamic>?),
      finalBad: _parseFinalLore(finalLoreJson['bad'] as List<dynamic>?),
    );
  }

  List<BunkerEndingEntry> _parseFinalLore(List<dynamic>? items) {
    return (items ?? const [])
        .map(
          (item) => BunkerEndingEntry(
            title: (item as Map<String, dynamic>)['title'] as String,
            text: item['text'] as String,
          ),
        )
        .toList();
  }

  List<String> _readStringList(
    Map<String, dynamic> decoded,
    String key, {
    List<String> fallback = const <String>[],
  }) {
    final raw = decoded[key];
    if (raw is List<dynamic>) {
      final values = List<String>.from(raw);
      if (values.isNotEmpty) {
        return values;
      }
    }
    return fallback;
  }
}
