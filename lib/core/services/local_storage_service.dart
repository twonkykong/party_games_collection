import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_theme_preference.dart';
import '../models/dictionary_mode.dart';
import '../models/game_setup_drafts.dart';
import '../models/mafia_preset.dart';
import '../models/saved_last_party.dart';

class LocalStorageService {
  static const _spySetupKey = 'spy_setup';
  static const _whoAmISetupKey = 'whoami_setup';
  static const _mafiaSetupKey = 'mafia_setup';
  static const _bunkerSetupKey = 'bunker_setup';
  static const _aliasSetupKey = 'alias_setup';
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
        teamCount: 2,
        roundSeconds: 60,
        targetScore: 30,
        dictionaryMode: DictionaryMode.family,
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
