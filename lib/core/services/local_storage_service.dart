import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_theme_preference.dart';
import '../models/dictionary_mode.dart';
import '../models/game_setup_drafts.dart';
import '../models/game_type.dart';
import '../models/mafia_preset.dart';
import '../models/saved_last_party.dart';
import '../models/word_source_mode.dart';

class LocalStorageService {
  static const _spySetupKey = 'spy_setup';
  static const _whoAmISetupKey = 'whoami_setup';
  static const _mafiaSetupKey = 'mafia_setup';
  static const _bunkerSetupKey = 'bunker_setup';
  static const _aliasSetupKey = 'alias_setup';
  static const _sharedCustomWordsKey = 'custom_words_shared';
  static const _customWhoAmIWordsKey = 'custom_words_whoami';
  static const _customAliasWordsKey = 'custom_words_alias';
  static const _customSpyWordsKey = 'custom_words_spy';
  static const _lastPartyKey = 'last_party';
  static const _themePreferenceKey = 'theme_preference';
  static const _uiSoundsEnabledKey = 'ui_sounds_enabled';
  static const _dirtyWordsEnabledKey = 'dirty_words_enabled';
  static const _mafiaTrackerPrefix = 'mafia_tracker_';
  static const _bunkerStatePrefix = 'bunker_state_';
  static const _aliasStatePrefix = 'alias_state_';

  Future<SpySetupDraft> loadSpySetupDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_spySetupKey);
    if (jsonString == null) {
      return const SpySetupDraft(
        playerCount: 5,
        spyCount: 1,
        dictionaryMode: DictionaryMode.family,
        wordSourceMode: WordSourceMode.builtIn,
      );
    }
    return SpySetupDraft.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
  }

  Future<WhoAmISetupDraft> loadWhoAmISetupDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_whoAmISetupKey);
    if (jsonString == null) {
      return const WhoAmISetupDraft(
        playerCount: 4,
        dictionaryMode: DictionaryMode.family,
        wordSourceMode: WordSourceMode.builtIn,
      );
    }
    return WhoAmISetupDraft.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
  }

  Future<SavedLastParty?> loadLastParty() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_lastPartyKey);
    if (jsonString == null) {
      return null;
    }
    return SavedLastParty.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
  }

  Future<MafiaSetupDraft> loadMafiaSetupDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_mafiaSetupKey);
    if (jsonString == null) {
      return const MafiaSetupDraft(playerCount: 6, preset: MafiaPreset.classic);
    }
    return MafiaSetupDraft.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
  }

  Future<BunkerSetupDraft> loadBunkerSetupDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_bunkerSetupKey);
    if (jsonString == null) {
      return const BunkerSetupDraft(playerCount: 6);
    }
    return BunkerSetupDraft.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
  }

  Future<AliasSetupDraft> loadAliasSetupDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_aliasSetupKey);
    if (jsonString == null) {
      return const AliasSetupDraft(
        teamCount: 1,
        roundSeconds: 60,
        targetScore: 30,
        dictionaryMode: DictionaryMode.family,
        wordSourceMode: WordSourceMode.builtIn,
      );
    }
    return AliasSetupDraft.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
  }

  Future<AppThemePreference> loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    return AppThemePreference.fromCode(prefs.getString(_themePreferenceKey));
  }

  Future<bool> loadUiSoundsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_uiSoundsEnabledKey) ?? true;
  }

  Future<bool> loadDirtyWordsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_dirtyWordsEnabledKey) ?? false;
  }

  Future<void> saveSpySetupDraft(SpySetupDraft draft) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_spySetupKey, jsonEncode(draft.toJson()));
  }

  Future<void> saveWhoAmISetupDraft(WhoAmISetupDraft draft) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_whoAmISetupKey, jsonEncode(draft.toJson()));
  }

  Future<void> saveLastParty(SavedLastParty party) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastPartyKey, jsonEncode(party.toJson()));
  }

  Future<void> saveMafiaSetupDraft(MafiaSetupDraft draft) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_mafiaSetupKey, jsonEncode(draft.toJson()));
  }

  Future<void> saveBunkerSetupDraft(BunkerSetupDraft draft) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_bunkerSetupKey, jsonEncode(draft.toJson()));
  }

  Future<void> saveAliasSetupDraft(AliasSetupDraft draft) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_aliasSetupKey, jsonEncode(draft.toJson()));
  }

  Future<void> saveThemePreference(AppThemePreference preference) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themePreferenceKey, preference.code);
  }

  Future<void> saveUiSoundsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_uiSoundsEnabledKey, enabled);
  }

  Future<void> saveDirtyWordsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dirtyWordsEnabledKey, enabled);
  }

  Future<void> clearLastParty() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastPartyKey);
  }

  Future<List<String>> loadCustomWords(GameType gameType) async {
    final prefs = await SharedPreferences.getInstance();
    final sharedValues = prefs.getStringList(_sharedCustomWordsKey);
    if (sharedValues != null) {
      return List<String>.from(sharedValues);
    }

    final merged = <String>[];
    final seen = <String>{};
    for (final key in const [
      _customWhoAmIWordsKey,
      _customAliasWordsKey,
      _customSpyWordsKey,
    ]) {
      final values = prefs.getStringList(key) ?? const [];
      for (final value in values) {
        final normalized = value.trim().replaceAll(RegExp(r'\s+'), ' ');
        if (normalized.isEmpty) {
          continue;
        }
        final token = normalized.toLowerCase();
        if (seen.add(token)) {
          merged.add(normalized);
        }
      }
    }
    if (merged.isNotEmpty) {
      await prefs.setStringList(_sharedCustomWordsKey, merged);
    }
    return merged;
  }

  Future<void> saveCustomWords(GameType gameType, List<String> words) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_sharedCustomWordsKey, words);
    await prefs.remove(_customWhoAmIWordsKey);
    await prefs.remove(_customAliasWordsKey);
    await prefs.remove(_customSpyWordsKey);
  }

  Future<Map<String, dynamic>> loadJsonState(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null) {
      return <String, dynamic>{};
    }
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> saveJsonState(String key, Map<String, dynamic> value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(value));
  }

  String mafiaTrackerKey(String code) => '$_mafiaTrackerPrefix$code';

  String bunkerStateKey(String code) => '$_bunkerStatePrefix$code';

  String aliasStateKey(String code, int teamIndex) =>
      '$_aliasStatePrefix${code}_$teamIndex';
}
