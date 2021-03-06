import 'right_hand_side.dart';

class RegularExpressionContext extends RightHandSideContext {
  final String pattern;
  RegularExpressionContext(this.pattern);

  @override
  String toString() => 'Regular Expression: /$pattern/';
}
