import 'right_hand_side.dart';

class RegularExpressionContext extends RightHandSideContext {
  final String pattern;
  RegularExpressionContext(this.pattern);
  @override
  bool get isScannerRule => true;

  @override
  String toString() => 'Regular Expression: /$pattern/';
}
