import 'right_hand_side.dart';

class AlternationContext extends RightHandSideContext {
  final RightHandSideContext left, right;
  AlternationContext(this.left, this.right);
}