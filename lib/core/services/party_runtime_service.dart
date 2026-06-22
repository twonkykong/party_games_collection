import '../../data/repositories/alias_words_repository.dart';
import '../../data/models/bunker_catalog.dart';
import '../../data/repositories/bunker_repository.dart';
import '../../data/repositories/mafia_repository.dart';
import '../../data/repositories/spy_words_repository.dart';
import '../../data/repositories/whoami_words_repository.dart';
import '../../features/games/alias/alias_party_state.dart';
import '../../features/games/bunker/bunker_party_state.dart';
import '../../features/games/mafia/mafia_party_state.dart';
import '../../features/games/spy/spy_party_state.dart';
import '../../features/games/whoami/whoami_party_state.dart';
import '../models/active_party.dart';
import '../models/game_type.dart';
import '../models/party_configuration.dart';
import 'deterministic_random.dart';
import 'party_code_codec.dart';

class PartyRuntimeService {
  const PartyRuntimeService({
    required this.codec,
    required this.spyRepository,
    required this.whoAmIRepository,
    required this.mafiaRepository,
    required this.bunkerRepository,
    required this.aliasRepository,
  });

  final PartyCodeCodec codec;
  final SpyWordsRepository spyRepository;
  final WhoAmIWordsRepository whoAmIRepository;
  final MafiaRepository mafiaRepository;
  final BunkerRepository bunkerRepository;
  final AliasWordsRepository aliasRepository;

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
    return resolveSpyParty(
      entries: entries,
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
    return resolveWhoAmIParty(
      entries: entries,
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
      throw const PartyCodeException('Для этого числа игроков нет сценария Бункера.');
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
    final random = DeterministicRandom(configuration.seed);
    final deck =
        random.shuffled(words).map((entry) => entry.value).take(120).toList();
    return AliasPartyState(
      words: deck,
      teamCount: configuration.playerCount,
      roundSeconds: configuration.aliasRoundSeconds ?? 60,
      targetScore: configuration.aliasTargetScore ?? 30,
    );
  }
}
