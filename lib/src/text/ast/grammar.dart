import 'ast_node.dart';
import 'rule.dart';

class GrammarContext extends AstNode {
  final List<RuleContext> _rules = [];
  List<RuleContext> get rules => new List<RuleContext>.unmodifiable(_rules);

  GrammarContext([Iterable<RuleContext> rules = const []]) {
    _rules.addAll(rules ?? []);
  }
}
