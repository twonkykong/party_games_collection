import '../../core/models/dictionary_mode.dart';
import '../models/alias_word_entry.dart';
import 'asset_json_loader.dart';

class AliasWordsRepository {
  AliasWordsRepository({AssetJsonLoader? loader})
    : _loader = loader ?? AssetJsonLoader();

  static const _assetPath = 'assets/data/alias_words_ultra.json';
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
    final words = decoded['words'] as List<dynamic>? ?? const [];
    return words
        .map((item) => AliasWordEntry.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
