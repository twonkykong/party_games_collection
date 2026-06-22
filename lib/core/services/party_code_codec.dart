import 'dart:math';

import '../models/dictionary_mode.dart';
import '../models/game_type.dart';
import '../models/party_code_version.dart';
import '../models/party_configuration.dart';

class PartyCodeCodec {
  const PartyCodeCodec();

  static const _alphabet =
      '23456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';
  static const _base = 57;
  static const _legacyCodeLength = 11;
  static const aliasRoundSecondsOptions = [30, 45, 60, 75, 90, 120];

  String encode(PartyConfiguration configuration) {
    if (configuration.version == PartyCodeVersion.v1) {
      return _encodeFixed(_packLegacy(configuration));
    }
    if (configuration.version == PartyCodeVersion.v2) {
      return _encodeVariable(_packLegacy(configuration));
    }
    return _encodeVariable(_packV3(configuration));
  }

  PartyConfiguration decode(String rawCode) {
    final code = rawCode.trim();
    if (code.isEmpty) {
      throw const PartyCodeException('Неверный формат кода.');
    }

    final encodedValue = _decodeBase57(code);
    if (code.length == _legacyCodeLength) {
      final legacy = _tryUnpack(encodedValue);
      if (legacy != null && legacy.version == PartyCodeVersion.v1) {
        return legacy;
      }
    }

    final modern = _tryUnpack(encodedValue);
    if (modern == null) {
      throw const PartyCodeException('Код распознан не полностью.');
    }
    return modern;
  }

  int generateSeed() {
    final micros = DateTime.now().microsecondsSinceEpoch;
    return micros & 0xFFFFFFFFFFFF;
  }

  String _encodeFixed(BigInt payload) {
    final buffer = StringBuffer();
    var value = payload;
    for (var i = 0; i < _legacyCodeLength; i++) {
      final index = value % BigInt.from(_base);
      buffer.write(_alphabet[index.toInt()]);
      value ~/= BigInt.from(_base);
    }
    return buffer.toString().split('').reversed.join();
  }

  String _encodeVariable(BigInt value) {
    if (value == BigInt.zero) {
      return _alphabet[0];
    }
    final buffer = StringBuffer();
    var current = value;
    final base = BigInt.from(_base);
    while (current > BigInt.zero) {
      final index = current % base;
      buffer.write(_alphabet[index.toInt()]);
      current ~/= base;
    }
    return buffer.toString().split('').reversed.join();
  }

  BigInt _decodeBase57(String code) {
    var value = BigInt.zero;
    final base = BigInt.from(_base);
    for (final char in code.split('')) {
      final index = _alphabet.indexOf(char);
      if (index == -1) {
        throw const PartyCodeException('Код содержит недопустимые символы.');
      }
      value = value * base + BigInt.from(index);
    }
    return value;
  }

  BigInt _packLegacy(PartyConfiguration configuration) {
    final version = BigInt.from(configuration.version.value & 0x7);
    final game = BigInt.from(configuration.gameType.index & 0x3);
    final players = BigInt.from((configuration.playerCount - 2) & 0xF);
    final mode = BigInt.from(configuration.dictionaryMode.index & 0x3);
    final extra = BigInt.from(_encodeLegacyExtra(configuration) & 0x7);
    final seed = BigInt.from(configuration.seed);

    return version |
        (game << 3) |
        (players << 5) |
        (mode << 9) |
        (extra << 11) |
        (seed << 14);
  }

  BigInt _packV3(PartyConfiguration configuration) {
    final version = BigInt.from(configuration.version.value & 0x7);
    final game = BigInt.from(configuration.gameType.index & 0x7);
    final count = BigInt.from((configuration.playerCount - 2) & 0xF);
    final mode = BigInt.from(configuration.dictionaryMode.index & 0x3);
    final extraA = BigInt.from(_encodeV3ExtraA(configuration) & 0xF);
    final extraB = BigInt.from(_encodeV3ExtraB(configuration) & 0x3F);
    final seed = BigInt.from(configuration.seed);

    return version |
        (game << 3) |
        (count << 6) |
        (mode << 10) |
        (extraA << 12) |
        (extraB << 16) |
        (seed << 22);
  }

  PartyConfiguration? _tryUnpack(BigInt value) {
    final versionValue = (value & BigInt.from(0x7)).toInt();
    if (versionValue == PartyCodeVersion.v3.value) {
      return _tryUnpackV3(value);
    }
    return _tryUnpackLegacy(value);
  }

  PartyConfiguration? _tryUnpackLegacy(BigInt value) {
    final versionValue = (value & BigInt.from(0x7)).toInt();
    final gameValue = ((value >> 3) & BigInt.from(0x3)).toInt();
    final players = (((value >> 5) & BigInt.from(0xF)).toInt()) + 2;
    final modeValue = ((value >> 9) & BigInt.from(0x3)).toInt();
    final extra = ((value >> 11) & BigInt.from(0x7)).toInt();
    final seed = (value >> 14).toInt();

    try {
      final version = PartyCodeVersion.fromValue(versionValue);
      final gameType = GameType.values[gameValue];
      final dictionaryMode = DictionaryMode.values[modeValue];
      return PartyConfiguration(
        version: version,
        gameType: gameType,
        playerCount: players,
        dictionaryMode: dictionaryMode,
        seed: seed,
        spyCount: _decodeLegacyExtra(gameType, extra),
      );
    } catch (_) {
      return null;
    }
  }

  PartyConfiguration? _tryUnpackV3(BigInt value) {
    final versionValue = (value & BigInt.from(0x7)).toInt();
    final gameValue = ((value >> 3) & BigInt.from(0x7)).toInt();
    final count = (((value >> 6) & BigInt.from(0xF)).toInt()) + 2;
    final modeValue = ((value >> 10) & BigInt.from(0x3)).toInt();
    final extraA = ((value >> 12) & BigInt.from(0xF)).toInt();
    final extraB = ((value >> 16) & BigInt.from(0x3F)).toInt();
    final seed = (value >> 22).toInt();

    try {
      final version = PartyCodeVersion.fromValue(versionValue);
      final gameType = GameType.values[gameValue];
      final dictionaryMode = DictionaryMode.values[modeValue];
      return PartyConfiguration(
        version: version,
        gameType: gameType,
        playerCount: count,
        dictionaryMode: dictionaryMode,
        seed: seed,
        spyCount: gameType == GameType.spy ? extraA + 1 : null,
        mafiaPresetId:
            gameType == GameType.mafia
                ? (extraA == 1 ? 'expanded' : 'classic')
                : null,
        aliasRoundSeconds:
            gameType == GameType.alias
                ? aliasRoundSecondsOptions[extraA.clamp(
                  0,
                  aliasRoundSecondsOptions.length - 1,
                )]
                : null,
        aliasTargetScore:
            gameType == GameType.alias ? extraB.clamp(1, 63) : null,
      );
    } catch (_) {
      return null;
    }
  }

  int _encodeLegacyExtra(PartyConfiguration configuration) {
    switch (configuration.gameType) {
      case GameType.spy:
        return max(0, (configuration.spyCount ?? 1) - 1);
      case GameType.whoAmI:
      case GameType.mafia:
      case GameType.bunker:
      case GameType.alias:
        return 0;
    }
  }

  int? _decodeLegacyExtra(GameType gameType, int extra) {
    switch (gameType) {
      case GameType.spy:
        return extra + 1;
      case GameType.whoAmI:
      case GameType.mafia:
      case GameType.bunker:
      case GameType.alias:
        return null;
    }
  }

  int _encodeV3ExtraA(PartyConfiguration configuration) {
    switch (configuration.gameType) {
      case GameType.spy:
        return max(0, (configuration.spyCount ?? 1) - 1);
      case GameType.whoAmI:
      case GameType.bunker:
        return 0;
      case GameType.mafia:
        return configuration.mafiaPresetId == 'expanded' ? 1 : 0;
      case GameType.alias:
        final roundSeconds = configuration.aliasRoundSeconds ?? 60;
        return aliasRoundSecondsOptions.indexOf(roundSeconds).clamp(0, 15);
    }
  }

  int _encodeV3ExtraB(PartyConfiguration configuration) {
    switch (configuration.gameType) {
      case GameType.alias:
        return (configuration.aliasTargetScore ?? 30).clamp(1, 63);
      case GameType.spy:
      case GameType.whoAmI:
      case GameType.mafia:
      case GameType.bunker:
        return 0;
    }
  }
}

class PartyCodeException implements Exception {
  const PartyCodeException(this.message);

  final String message;

  @override
  String toString() => message;
}
