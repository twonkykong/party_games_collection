import '../../core/models/dictionary_mode.dart';
import '../models/whoami_word_entry.dart';
import 'asset_json_loader.dart';

class WhoAmIWordsRepository {
  WhoAmIWordsRepository({AssetJsonLoader? loader})
    : _loader = loader ?? AssetJsonLoader();

  static const _assetPath = 'assets/data/whoami_words_ultra.json';
  static const _peopleAssetPath = 'assets/data/people_lists_update.json';
  final AssetJsonLoader _loader;
  List<WhoAmIWordEntry>? _cache;

  Future<List<WhoAmIWordEntry>> load(DictionaryMode mode) async {
    _cache ??= await _readAll();
    final filtered =
        _cache!.where((entry) => mode.allows(entry.rating)).toList();
    if (filtered.isEmpty) {
      throw StateError('Для выбранного режима словарь пуст.');
    }
    return filtered;
  }

  Future<List<WhoAmIWordEntry>> _readAll() async {
    final decoded = await _loader.load<List<dynamic>>(_assetPath);
    final peopleDecoded = await _loader.load<Map<String, dynamic>>(_peopleAssetPath);
    final baseEntries =
        decoded
            .map((item) => WhoAmIWordEntry.fromJson(item as Map<String, dynamic>))
            .toList();

    final merged = <String, WhoAmIWordEntry>{
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
          () => WhoAmIWordEntry(value: value, rating: rating),
        );
      }
    }

    addPeopleList('clean_people', 'family');
    addPeopleList('dirty_people', 'dirty');

    return merged.values.toList(growable: false);
  }
}
