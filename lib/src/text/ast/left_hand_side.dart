import 'ast_node.dart';
import 'identifier.dart';

class LeftHandSideContext extends AstNode {
  final IdentifierContext name;
  LeftHandSideContext(this.name);
}
