import '../../core/models/dictionary_mode.dart';
import '../models/alias_word_entry.dart';
import 'asset_json_loader.dart';

class AliasWordsRepository {
  AliasWordsRepository({AssetJsonLoader? loader})
    : _loader = loader ?? AssetJsonLoader();

  static const _assetPath = 'assets/data/alias_words_ultra.json';
  static const _peopleAssetPath = 'assets/data/people_lists_update.json';
  final AssetJsonLoader _loader;
  List<AliasWordEntry>? _cache;

  Future<List<AliasWordEntry>> load(DictionaryMode mode) async {
    _cache ??= await _readAll();
    final filtered =
        _cache!.where((entry) => mode.allows(entry.rating)).toList();
    if (filtered.isEmpty) {
      throw StateError('Для выбранного режима словарь Элиаса пуст.');
    }
    return filtered;
  }

  Future<List<AliasWordEntry>> _readAll() async {
    final decoded = await _loader.load<Map<String, dynamic>>(_assetPath);
    final peopleDecoded = await _loader.load<Map<String, dynamic>>(_peopleAssetPath);
    final words = decoded['words'] as List<dynamic>? ?? const [];
    final baseEntries =
        words
            .map((item) => AliasWordEntry.fromJson(item as Map<String, dynamic>))
            .toList();
    final merged = <String, AliasWordEntry>{
      for (final entry in baseEntries) entry.value.trim().toLowerCase(): entry,
    };

    void addPeopleList(String key, String rating) {
      final items = peopleDecoded[key] as List<dynamic>? ?? const [];
      for (final item in items) {
        final value = '$item'.trim();
        if (value.isEmpty) {
          continue;
        }
        merged.putIfAbsent(
          value.toLowerCase(),
          () => AliasWordEntry(value: value, rating: rating),
        );
      }
    }

    addPeopleList('clean_people', 'family');
    addPeopleList('dirty_people', 'dirty');

    return merged.values.toList(growable: false);
  }
}
