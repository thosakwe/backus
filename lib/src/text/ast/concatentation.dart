import 'right_hand_side.dart';

class ConcatenationContext extends RightHandSideContext {
  final RightHandSideContext left, right;
  ConcatenationContext(this.left, this.right);
}
