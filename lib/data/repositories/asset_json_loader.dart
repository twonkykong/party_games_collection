import 'dart:convert';

import 'package:flutter/services.dart';

class AssetJsonLoader {
  final Map<String, Object?> _cache = {};

  Future<T> load<T>(String assetPath) async {
    if (_cache.containsKey(assetPath)) {
      return _cache[assetPath] as T;
    }
    final jsonString = await rootBundle.loadString(assetPath);
    final decoded = jsonDecode(jsonString);
    _cache[assetPath] = decoded;
    return decoded as T;
  }
}
