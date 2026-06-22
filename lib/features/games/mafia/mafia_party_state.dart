import '../../../data/models/mafia_role.dart';

class MafiaPartyState {
  const MafiaPartyState({required this.assignments, required this.partyRoles});

  final Map<int, MafiaRole> assignments;
  final List<MafiaRole> partyRoles;
}
