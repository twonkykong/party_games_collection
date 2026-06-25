import 'package:flutter/foundation.dart';

import '../../data/repositories/spy_words_repository.dart';
import '../../data/repositories/whoami_words_repository.dart';
import '../../data/repositories/alias_words_repository.dart';
import '../../data/repositories/bunker_repository.dart';
import '../../data/repositories/mafia_repository.dart';
import '../models/active_party.dart';
import '../models/app_theme_preference.dart';
import '../models/dictionary_mode.dart';
import '../models/game_setup_drafts.dart';
import '../models/game_type.dart';
import '../models/mafia_preset.dart';
import '../models/saved_last_party.dart';
import '../models/word_source_mode.dart';
import 'local_storage_service.dart';
import 'party_code_codec.dart';
import 'party_runtime_service.dart';
import 'ui_sound_service.dart';

class AppController extends ChangeNotifier {
  AppController({
    required this.codec,
    required this.storage,
    required this.spyRepository,
    required this.whoAmIRepository,
    required this.mafiaRepository,
    required this.bunkerRepository,
    required this.aliasRepository,
    required this.uiSoundService,
  });

  final PartyCodeCodec codec;
  final LocalStorageService storage;
  final SpyWordsRepository spyRepository;
  final WhoAmIWordsRepository whoAmIRepository;
  final MafiaRepository mafiaRepository;
  final BunkerRepository bunkerRepository;
  final AliasWordsRepository aliasRepository;
  final UiSoundService uiSoundService;
  final ValueNotifier<AppThemePreference> themePreferenceListenable =
      ValueNotifier(AppThemePreference.system);

  late final PartyRuntimeService runtime = PartyRuntimeService(
    codec: codec,
    spyRepository: spyRepository,
    whoAmIRepository: whoAmIRepository,
    mafiaRepository: mafiaRepository,
    bunkerRepository: bunkerRepository,
    aliasRepository: aliasRepository,
    storage: storage,
  );

  SpySetupDraft _spySetupDraft = const SpySetupDraft(
    playerCount: 5,
    spyCount: 1,
    dictionaryMode: DictionaryMode.family,
    wordSourceMode: WordSourceMode.builtIn,
  );
  WhoAmISetupDraft _whoAmISetupDraft = const WhoAmISetupDraft(
    playerCount: 4,
    dictionaryMode: DictionaryMode.family,
    wordSourceMode: WordSourceMode.builtIn,
  );
  MafiaSetupDraft _mafiaSetupDraft = const MafiaSetupDraft(
    playerCount: 6,
    preset: MafiaPreset.classic,
  );
  BunkerSetupDraft _bunkerSetupDraft = const BunkerSetupDraft(playerCount: 6);
  AliasSetupDraft _aliasSetupDraft = const AliasSetupDraft(
    teamCount: 1,
    roundSeconds: 60,
    targetScore: 30,
    dictionaryMode: DictionaryMode.family,
    wordSourceMode: WordSourceMode.builtIn,
  );
  SavedLastParty? _lastParty;
  AppThemePreference _themePreference = AppThemePreference.system;
  bool _uiSoundsEnabled = true;
  bool _dirtyWordsEnabled = false;
  List<String> _customWords = const [];

  SpySetupDraft get spySetupDraft => _spySetupDraft;
  WhoAmISetupDraft get whoAmISetupDraft => _whoAmISetupDraft;
  MafiaSetupDraft get mafiaSetupDraft => _mafiaSetupDraft;
  BunkerSetupDraft get bunkerSetupDraft => _bunkerSetupDraft;
  AliasSetupDraft get aliasSetupDraft => _aliasSetupDraft;
  SavedLastParty? get lastParty => _lastParty;
  AppThemePreference get themePreference => _themePreference;
  bool get uiSoundsEnabled => _uiSoundsEnabled;
  bool get dirtyWordsEnabled => _dirtyWordsEnabled;
  List<String> get customWords => _customWords;
  List<String> get customSpyWords => _customWords;
  List<String> get customWhoAmIWords => _customWords;
  List<String> get customAliasWords => _customWords;

  Future<void> initialize() async {
    _spySetupDraft = await storage.loadSpySetupDraft();
    _whoAmISetupDraft = await storage.loadWhoAmISetupDraft();
    _mafiaSetupDraft = await storage.loadMafiaSetupDraft();
    _bunkerSetupDraft = await storage.loadBunkerSetupDraft();
    _aliasSetupDraft = await storage.loadAliasSetupDraft();
    _lastParty = await storage.loadLastParty();
    _themePreference = await storage.loadThemePreference();
    themePreferenceListenable.value = _themePreference;
    _uiSoundsEnabled = await storage.loadUiSoundsEnabled();
    _dirtyWordsEnabled = await storage.loadDirtyWordsEnabled();
    _customWords = await storage.loadCustomWords(GameType.spy);
    uiSoundService.setEnabled(_uiSoundsEnabled);
    notifyListeners();
  }

  Future<void> updateSpySetupDraft(SpySetupDraft draft) async {
    _spySetupDraft = draft;
    notifyListeners();
    await storage.saveSpySetupDraft(draft);
  }

  Future<void> updateWhoAmISetupDraft(WhoAmISetupDraft draft) async {
    _whoAmISetupDraft = draft;
    notifyListeners();
    await storage.saveWhoAmISetupDraft(draft);
  }

  Future<void> updateMafiaSetupDraft(MafiaSetupDraft draft) async {
    _mafiaSetupDraft = draft;
    notifyListeners();
    await storage.saveMafiaSetupDraft(draft);
  }

  Future<void> updateBunkerSetupDraft(BunkerSetupDraft draft) async {
    _bunkerSetupDraft = draft;
    notifyListeners();
    await storage.saveBunkerSetupDraft(draft);
  }

  Future<void> updateAliasSetupDraft(AliasSetupDraft draft) async {
    _aliasSetupDraft = draft;
    notifyListeners();
    await storage.saveAliasSetupDraft(draft);
  }

  Future<void> saveLastParty(SavedLastParty party) async {
    _lastParty = party;
    notifyListeners();
    await storage.saveLastParty(party);
  }

  Future<void> saveActiveParty(ActiveParty party) async {
    await saveLastParty(
      SavedLastParty(
        code: party.code,
        playerIndex: party.playerIndex,
        gameType: party.gameType,
        savedAtIso: DateTime.now().toIso8601String(),
      ),
    );
  }

  Future<void> updateThemePreference(AppThemePreference preference) async {
    _themePreference = preference;
    themePreferenceListenable.value = preference;
    notifyListeners();
    await storage.saveThemePreference(preference);
  }

  Future<void> setUiSoundsEnabled(bool enabled) async {
    _uiSoundsEnabled = enabled;
    uiSoundService.setEnabled(enabled);
    notifyListeners();
    await storage.saveUiSoundsEnabled(enabled);
  }

  Future<void> setDirtyWordsEnabled(bool enabled) async {
    _dirtyWordsEnabled = enabled;
    notifyListeners();
    await storage.saveDirtyWordsEnabled(enabled);
  }

  List<String> customWordsFor(GameType gameType) {
    switch (gameType) {
      case GameType.spy:
        return customWords;
      case GameType.whoAmI:
        return customWords;
      case GameType.alias:
        return customWords;
      case GameType.mafia:
      case GameType.bunker:
        return const [];
    }
  }

  Future<int> addSharedCustomWords(Iterable<String> rawWords) async {
    return addCustomWords(GameType.spy, rawWords);
  }

  Future<int> addCustomWords(
    GameType gameType,
    Iterable<String> rawWords,
  ) async {
    final next = List<String>.from(customWordsFor(gameType));
    final existingKeys = next.map((item) => item.toLowerCase()).toSet();
    var added = 0;
    for (final raw in rawWords) {
      final normalized = raw.trim().replaceAll(RegExp(r'\s+'), ' ');
      if (normalized.isEmpty) {
        continue;
      }
      final key = normalized.toLowerCase();
      if (existingKeys.contains(key)) {
        continue;
      }
      next.add(normalized);
      existingKeys.add(key);
      added += 1;
    }
    await _saveCustomWords(gameType, next);
    return added;
  }

  Future<void> removeCustomWord(GameType gameType, String word) async {
    final next =
        customWordsFor(
          gameType,
        ).where((item) => item.toLowerCase() != word.toLowerCase()).toList();
    await _saveCustomWords(gameType, next);
  }

  Future<void> removeSharedCustomWord(String word) async {
    await removeCustomWord(GameType.spy, word);
  }

  Future<void> clearCustomWords(GameType gameType) async {
    await _saveCustomWords(gameType, const []);
  }

  Future<void> clearSharedCustomWords() async {
    await clearCustomWords(GameType.spy);
  }

  Future<void> _saveCustomWords(GameType gameType, List<String> words) async {
    switch (gameType) {
      case GameType.spy:
      case GameType.whoAmI:
      case GameType.alias:
        _customWords = words;
      case GameType.mafia:
      case GameType.bunker:
        return;
    }
    notifyListeners();
    await storage.saveCustomWords(gameType, words);
  }

  void playSound(UiSound sound) {
    uiSoundService.play(sound);
  }

  Future<void> clearLastParty() async {
    _lastParty = null;
    notifyListeners();
    await storage.clearLastParty();
  }

  @override
  void dispose() {
    themePreferenceListenable.dispose();
    uiSoundService.dispose();
    super.dispose();
  }
}
