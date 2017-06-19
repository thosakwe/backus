import 'right_hand_side.dart';

class RepetitionContext extends RightHandSideContext {
  final RightHandSideContext context;
  RepetitionContext(this.context);
  @override
  bool get isScannerRule => context.isScannerRule;
}
