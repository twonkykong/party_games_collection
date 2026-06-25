class CustomWordsTransfer {
  static const _prefix = 'PGC_WORDS_V1';

  static String encode(List<String> words) {
    final normalized = words
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
    return '$_prefix\n${normalized.join('\n')}';
  }

  static List<String>? decode(String raw) {
    final normalized = raw.trim();
    if (!normalized.startsWith(_prefix)) {
      return null;
    }
    final lines = normalized
        .split('\n')
        .skip(1)
        .map((item) => item.trim().replaceAll(RegExp(r'\s+'), ' '))
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
    return lines;
  }
}
