import '../../../data/models/bunker_catalog.dart';

class BunkerPlayerProfile {
  const BunkerPlayerProfile({
    required this.profession,
    required this.age,
    required this.gender,
    required this.orientation,
    required this.health,
    required this.phobia,
    required this.hobby,
    required this.character,
    required this.baggage,
    required this.fact,
    required this.action,
    required this.condition,
  });

  final String profession;
  final int age;
  final String gender;
  final String orientation;
  final String health;
  final String phobia;
  final String hobby;
  final String character;
  final String baggage;
  final String fact;
  final String action;
  final String condition;
}

class BunkerPartyState {
  const BunkerPartyState({
    required this.introLore,
    required this.disaster,
    required this.location,
    required this.capacity,
    required this.survivalTerm,
    required this.globalConditions,
    required this.players,
    required this.rounds,
    required this.finalGood,
    required this.finalMixed,
    required this.finalBad,
  });

  final BunkerIntroLore introLore;
  final String disaster;
  final String location;
  final String capacity;
  final String survivalTerm;
  final List<String> globalConditions;
  final Map<int, BunkerPlayerProfile> players;
  final List<BunkerRoundStep> rounds;
  final BunkerEndingEntry finalGood;
  final BunkerEndingEntry finalMixed;
  final BunkerEndingEntry finalBad;
}
