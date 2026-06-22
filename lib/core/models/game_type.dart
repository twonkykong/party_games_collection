enum GameType {
  spy('spy', 'Шпион'),
  whoAmI('whoami', 'Кто я'),
  mafia('mafia', 'Мафия'),
  bunker('bunker', 'Бункер'),
  alias('alias', 'Элиас');

  const GameType(this.code, this.title);

  final String code;
  final String title;

  static GameType fromCode(String code) {
    return GameType.values.firstWhere((value) => value.code == code);
  }
}
