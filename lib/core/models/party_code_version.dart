enum PartyCodeVersion {
  v1(1),
  v2(2),
  v3(3);

  const PartyCodeVersion(this.value);

  final int value;

  static PartyCodeVersion fromValue(int value) {
    return PartyCodeVersion.values.firstWhere((item) => item.value == value);
  }
}
