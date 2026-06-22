import '../../core/models/dictionary_mode.dart';
import '../models/spy_word_entry.dart';
import 'asset_json_loader.dart';

class SpyWordsRepository {
  SpyWordsRepository({AssetJsonLoader? loader})
    : _loader = loader ?? AssetJsonLoader();

  static const _assetPath = 'assets/data/spy_words_ultra.json';
  final AssetJsonLoader _loader;
  List<SpyWordEntry>? _cache;

  Future<List<SpyWordEntry>> load(DictionaryMode mode) async {
    _cache ??= await _readAll();
    final filtered =
        _cache!.where((entry) => mode.allows(entry.rating)).toList();
    if (filtered.isEmpty) {
      throw StateError('Для выбранного режима словарь пуст.');
    }
    return filtered;
  }

  Future<List<SpyWordEntry>> _readAll() async {
    final decoded = await _loader.load<List<dynamic>>(_assetPath);
    return decoded
        .map((item) => SpyWordEntry.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
