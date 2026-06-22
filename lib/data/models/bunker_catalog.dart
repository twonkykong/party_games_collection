class BunkerRoundStep {
  const BunkerRoundStep({
    required this.round,
    required this.openPerPlayer,
    required this.kicks,
  });

  final int round;
  final int openPerPlayer;
  final int kicks;
}

class BunkerIntroLore {
  const BunkerIntroLore({
    required this.title,
    required this.summary,
    required this.details,
  });

  final String title;
  final String summary;
  final String details;
}

class BunkerEndingEntry {
  const BunkerEndingEntry({required this.title, required this.text});

  final String title;
  final String text;
}

class BunkerCatalog {
  const BunkerCatalog({
    required this.introLore,
    required this.disasters,
    required this.locations,
    required this.capacities,
    required this.survivalTerms,
    required this.globalConditions,
    required this.biologicalSex,
    required this.biologicalAges,
    required this.biologicalOrientations,
    required this.professions,
    required this.health,
    required this.phobias,
    required this.hobbies,
    required this.character,
    required this.baggage,
    required this.facts,
    required this.actions,
    required this.conditions,
    required this.roundProgressions,
    required this.finalGood,
    required this.finalMixed,
    required this.finalBad,
  });

  final List<BunkerIntroLore> introLore;
  final List<String> disasters;
  final List<String> locations;
  final List<String> capacities;
  final List<String> survivalTerms;
  final List<String> globalConditions;
  final List<String> biologicalSex;
  final List<String> biologicalAges;
  final List<String> biologicalOrientations;
  final List<String> professions;
  final List<String> health;
  final List<String> phobias;
  final List<String> hobbies;
  final List<String> character;
  final List<String> baggage;
  final List<String> facts;
  final List<String> actions;
  final List<String> conditions;
  final Map<int, List<BunkerRoundStep>> roundProgressions;
  final List<BunkerEndingEntry> finalGood;
  final List<BunkerEndingEntry> finalMixed;
  final List<BunkerEndingEntry> finalBad;
}
