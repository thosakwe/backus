import 'right_hand_side.dart';

class OptionalContext extends RightHandSideContext {
  final RightHandSideContext context;
  OptionalContext(this.context);
  @override
  bool get isScannerRule => context.isScannerRule;
}
