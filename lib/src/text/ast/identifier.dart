import 'right_hand_side.dart';

class IdentifierContext extends RightHandSideContext {
  final String name;
  IdentifierContext(this.name);
  @override
  bool get isScannerRule => false;
}
