import 'ast_node.dart';
import 'left_hand_side.dart';
import 'right_hand_side.dart';

class RuleContext extends AstNode {
  final LeftHandSideContext left;
  final RightHandSideContext right;
  RuleContext(this.left, this.right);
}