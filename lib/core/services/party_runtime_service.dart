import '../../data/repositories/alias_words_repository.dart';
import '../../data/models/alias_word_entry.dart';
import '../../data/models/bunker_catalog.dart';
import '../../data/repositories/bunker_repository.dart';
import '../../data/repositories/mafia_repository.dart';
import '../../data/models/spy_word_entry.dart';
import '../../data/repositories/spy_words_repository.dart';
import '../../data/models/whoami_word_entry.dart';
import '../../data/repositories/whoami_words_repository.dart';
import '../../features/games/alias/alias_party_state.dart';
import '../../features/games/bunker/bunker_party_state.dart';
import '../../features/games/mafia/mafia_party_state.dart';
import '../../features/games/spy/spy_party_state.dart';
import '../../features/games/whoami/whoami_party_state.dart';
import '../models/active_party.dart';
import '../models/game_type.dart';
import '../models/party_configuration.dart';
import '../models/word_source_mode.dart';
import 'deterministic_random.dart';
import 'local_storage_service.dart';
import 'party_code_codec.dart';

class PartyRuntimeService {
  const PartyRuntimeService({
    required this.codec,
    required this.spyRepository,
    required this.whoAmIRepository,
    required this.mafiaRepository,
    required this.bunkerRepository,
    required this.aliasRepository,
    required this.storage,
  });

  final PartyCodeCodec codec;
  final SpyWordsRepository spyRepository;
  final WhoAmIWordsRepository whoAmIRepository;
  final MafiaRepository mafiaRepository;
  final BunkerRepository bunkerRepository;
  final AliasWordsRepository aliasRepository;
  final LocalStorageService storage;

  PartyConfiguration previewFromCode(String code) {
    return codec.decode(code.trim());
  }

  ActiveParty buildActivePartyFromCode(String code, int playerIndex) {
    final configuration = previewFromCode(code);
    if (configuration.playerCount < 1) {
      throw const PartyCodeException('Код партии повреждён.');
    }
    final safeIndex = playerIndex.isFinite ? playerIndex : 1;
    if (safeIndex < 1 || safeIndex > configuration.playerCount) {
      throw const PartyCodeException('Индекс игрока вне диапазона партии.');
    }
    return ActiveParty(
      code: code.trim(),
      playerIndex: safeIndex,
      configuration: configuration,
    );
  }

  Future<SpyPartyState> buildSpyPartyFromCode(String code) async {
    final configuration = previewFromCode(code);
    if (configuration.gameType != GameType.spy) {
      throw const PartyCodeException('Код относится к другой игре.');
    }
    final entries = await spyRepository.load(configuration.dictionaryMode);
    final customWords = await storage.loadCustomWords(GameType.spy);
    return resolveSpyParty(
      entries: _resolveSpyEntries(
        builtInEntries: entries,
        customWords: customWords,
        sourceMode: configuration.wordSourceMode,
      ),
      seed: configuration.seed,
      playerCount: configuration.playerCount,
      spyCount: configuration.spyCount ?? 1,
    );
  }

  Future<WhoAmIPartyState> buildWhoAmIPartyFromCode(String code) async {
    final configuration = previewFromCode(code);
    if (configuration.gameType != GameType.whoAmI) {
      throw const PartyCodeException('Код относится к другой игре.');
    }
    final entries = await whoAmIRepository.load(configuration.dictionaryMode);
    final customWords = await storage.loadCustomWords(GameType.whoAmI);
    return resolveWhoAmIParty(
      entries: _resolveWhoAmIEntries(
        builtInEntries: entries,
        customWords: customWords,
        sourceMode: configuration.wordSourceMode,
      ),
      seed: configuration.seed,
      playerCount: configuration.playerCount,
    );
  }

  Future<MafiaPartyState> buildMafiaPartyFromCode(String code) async {
    final configuration = previewFromCode(code);
    if (configuration.gameType != GameType.mafia) {
      throw const PartyCodeException('Код относится к другой игре.');
    }
    final catalog = await mafiaRepository.load();
    final presetId = configuration.mafiaPresetId ?? 'classic';
    final preset = catalog.presetsById[presetId];
    if (preset == null) {
      throw const PartyCodeException('Пресет Мафии не найден.');
    }
    final roleIds = preset.playerCounts[configuration.playerCount];
    if (roleIds == null) {
      throw const PartyCodeException(
        'Для этого числа игроков нет состава ролей.',
      );
    }
    final random = DeterministicRandom(configuration.seed);
    final shuffledIds = random.shuffled(roleIds);
    final partyRoles = roleIds.map((id) => catalog.rolesById[id]!).toList();
    return MafiaPartyState(
      assignments: {
        for (var i = 0; i < shuffledIds.length; i++)
          i + 1: catalog.rolesById[shuffledIds[i]]!,
      },
      partyRoles: partyRoles,
    );
  }

  Future<BunkerPartyState> buildBunkerPartyFromCode(String code) async {
    final configuration = previewFromCode(code);
    if (configuration.gameType != GameType.bunker) {
      throw const PartyCodeException('Код относится к другой игре.');
    }
    final catalog = await bunkerRepository.load();
    final random = DeterministicRandom(configuration.seed);
    if (configuration.playerCount < 1) {
      throw const PartyCodeException('Код бункера повреждён.');
    }
    if (catalog.introLore.isEmpty ||
        catalog.disasters.isEmpty ||
        catalog.locations.isEmpty ||
        catalog.capacities.isEmpty ||
        catalog.survivalTerms.isEmpty ||
        catalog.globalConditions.isEmpty ||
        catalog.biologicalSex.isEmpty ||
        catalog.biologicalAges.isEmpty ||
        catalog.biologicalOrientations.isEmpty ||
        catalog.professions.isEmpty ||
        catalog.health.isEmpty ||
        catalog.phobias.isEmpty ||
        catalog.hobbies.isEmpty ||
        catalog.character.isEmpty ||
        catalog.baggage.isEmpty ||
        catalog.facts.isEmpty ||
        catalog.actions.isEmpty ||
        catalog.conditions.isEmpty ||
        catalog.finalGood.isEmpty ||
        catalog.finalMixed.isEmpty ||
        catalog.finalBad.isEmpty) {
      throw const PartyCodeException('Карточки Бункера не загружены.');
    }
    final rounds =
        catalog.roundProgressions[configuration.playerCount] ??
        (catalog.roundProgressions.isNotEmpty
            ? catalog.roundProgressions.values.first
            : const <BunkerRoundStep>[]);
    if (rounds.isEmpty) {
      throw const PartyCodeException(
        'Для этого числа игроков нет сценария Бункера.',
      );
    }
    final introLore = random.shuffled(catalog.introLore);
    final professions = random.shuffled(catalog.professions);
    final ages = random.shuffled(catalog.biologicalAges);
    final sexes = random.shuffled(catalog.biologicalSex);
    final orientations = random.shuffled(catalog.biologicalOrientations);
    final health = random.shuffled(catalog.health);
    final phobias = random.shuffled(catalog.phobias);
    final hobbies = random.shuffled(catalog.hobbies);
    final characters = random.shuffled(catalog.character);
    final baggage = random.shuffled(catalog.baggage);
    final facts = random.shuffled(catalog.facts);
    final actions = random.shuffled(catalog.actions);
    final conditions = random.shuffled(catalog.conditions);
    final finalGood = random.shuffled(catalog.finalGood);
    final finalMixed = random.shuffled(catalog.finalMixed);
    final finalBad = random.shuffled(catalog.finalBad);

    return BunkerPartyState(
      introLore: introLore.first,
      disaster: catalog.disasters[random.nextInt(catalog.disasters.length)],
      location: catalog.locations[random.nextInt(catalog.locations.length)],
      capacity: catalog.capacities[random.nextInt(catalog.capacities.length)],
      survivalTerm:
          catalog.survivalTerms[random.nextInt(catalog.survivalTerms.length)],
      globalConditions:
          random.shuffled(catalog.globalConditions).take(2).toList(),
      players: {
        for (var index = 0; index < configuration.playerCount; index++)
          index + 1: BunkerPlayerProfile(
            profession: professions[index % professions.length],
            age: int.parse(ages[index % ages.length]),
            gender: sexes[index % sexes.length],
            orientation: orientations[index % orientations.length],
            health: health[index % health.length],
            phobia: phobias[index % phobias.length],
            hobby: hobbies[index % hobbies.length],
            character: characters[index % characters.length],
            baggage: baggage[index % baggage.length],
            fact: facts[index % facts.length],
            action: actions[index % actions.length],
            condition: conditions[index % conditions.length],
          ),
      },
      rounds: rounds,
      finalGood: finalGood.first,
      finalMixed: finalMixed.first,
      finalBad: finalBad.first,
    );
  }

  Future<AliasPartyState> buildAliasPartyFromCode(String code) async {
    final configuration = previewFromCode(code);
    if (configuration.gameType != GameType.alias) {
      throw const PartyCodeException('Код относится к другой игре.');
    }
    final words = await aliasRepository.load(configuration.dictionaryMode);
    final customWords = await storage.loadCustomWords(GameType.alias);
    final sourceWords = _resolveAliasEntries(
      builtInEntries: words,
      customWords: customWords,
      sourceMode: configuration.wordSourceMode,
    );
    final random = DeterministicRandom(configuration.seed);
    final deck =
        random
            .shuffled(sourceWords)
            .map((entry) => entry.value)
            .take(120)
            .toList();
    return AliasPartyState(
      words: deck,
      teamCount: configuration.playerCount,
      roundSeconds: configuration.aliasRoundSeconds ?? 60,
      targetScore: configuration.aliasTargetScore ?? 30,
    );
  }

  List<SpyWordEntry> _resolveSpyEntries({
    required List<SpyWordEntry> builtInEntries,
    required List<String> customWords,
    required WordSourceMode sourceMode,
  }) {
    final customEntries = customWords
        .map(
          (word) => SpyWordEntry(
            word: word,
            hints: _fallbackSpyHints(word),
            rating: 'family',
          ),
        )
        .toList(growable: false);
    return _mergeWordSources(
      builtIn: builtInEntries,
      custom: customEntries,
      sourceMode: sourceMode,
      emptyMessage: 'Для выбранного источника словарь Шпиона пуст.',
      keyOf: (entry) => entry.word,
    );
  }

  List<WhoAmIWordEntry> _resolveWhoAmIEntries({
    required List<WhoAmIWordEntry> builtInEntries,
    required List<String> customWords,
    required WordSourceMode sourceMode,
  }) {
    final customEntries = customWords
        .map((word) => WhoAmIWordEntry(value: word, rating: 'family'))
        .toList(growable: false);
    return _mergeWordSources(
      builtIn: builtInEntries,
      custom: customEntries,
      sourceMode: sourceMode,
      emptyMessage: 'Для выбранного источника словарь "Кто я" пуст.',
      keyOf: (entry) => entry.value,
    );
  }

  List<AliasWordEntry> _resolveAliasEntries({
    required List<AliasWordEntry> builtInEntries,
    required List<String> customWords,
    required WordSourceMode sourceMode,
  }) {
    final customEntries = customWords
        .map((word) => AliasWordEntry(value: word, rating: 'family'))
        .toList(growable: false);
    return _mergeWordSources(
      builtIn: builtInEntries,
      custom: customEntries,
      sourceMode: sourceMode,
      emptyMessage: 'Для выбранного источника словарь Элиаса пуст.',
      keyOf: (entry) => entry.value,
    );
  }

  List<T> _mergeWordSources<T>({
    required List<T> builtIn,
    required List<T> custom,
    required WordSourceMode sourceMode,
    required String emptyMessage,
    required String Function(T item) keyOf,
  }) {
    final merged = switch (sourceMode) {
      WordSourceMode.builtIn => builtIn,
      WordSourceMode.mixed => [...builtIn, ...custom],
      WordSourceMode.customOnly => custom,
    };
    final seen = <String>{};
    final result =
        merged
            .where((item) => seen.add(keyOf(item).trim().toLowerCase()))
            .toList();
    if (result.isEmpty) {
      throw StateError(emptyMessage);
    }
    return result;
  }

  List<String> _fallbackSpyHints(String word) {
    final normalized = word.trim();
    if (normalized.isEmpty) {
      return const ['контекст', 'ассоциация', 'сцена'];
    }
    if (RegExp(r'^[А-ЯA-Z][^ ]+[ -][А-ЯA-Z]').hasMatch(normalized)) {
      return const ['медиа', 'образ', 'узнаваемость', 'ассоциация', 'персона'];
    }
    if (normalized.contains(' ')) {
      return const ['сцена', 'контекст', 'ассоциация', 'образ', 'деталь'];
    }
    final lower = normalized.toLowerCase();
    if (lower.contains('клуб') ||
        lower.contains('бар') ||
        lower.contains('сигар') ||
        lower.contains('виски')) {
      return const ['вечер', 'компания', 'жест', 'атмосфера', 'привычка'];
    }
    if (lower.contains('телефон') ||
        lower.contains('айфон') ||
        lower.contains('ноутбук')) {
      return const ['экран', 'зарядка', 'жест', 'карман', 'техника'];
    }
    return const ['контекст', 'деталь', 'ассоциация', 'жест', 'сцена'];
  }
}
