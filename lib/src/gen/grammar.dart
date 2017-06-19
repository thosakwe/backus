import 'package:inflection/inflection.dart';
import 'package:recase/recase.dart';
import '../text/text.dart';
import 'rule_ast.dart';

class Grammar {
  final ReCase name;
  final Map<String, RuleAst> _ast = {};
  final Map<String, RightHandSideContext> rules = {};
  final Map<String, String> _tokenTypes = {};

  Grammar(this.name);

  bool hasTokenType(String ref) => _tokenTypes.containsKey(ref);

  RightHandSideContext resolveReference(String ref) {
    if (!rules.containsKey(ref)) {
      throw 'Cannot reference undefined rule "$ref".';
    } else
      return rules[ref];
  }

  String tokenType(String ref) {
    var str = new ReCase(ref).constantCase;
    return _tokenTypes.putIfAbsent(ref, () => str);
  }

  bool isTerminal(RightHandSideContext rhs) {
    if (rhs is OptionalContext)
      return isTerminal(rhs.context);
    else if (rhs is GroupContext)
      return isTerminal(rhs.context);
    else if (rhs is RepetitionContext)
      return isTerminal(rhs.context);
    else if (rhs is AlternationContext)
      return isTerminal(rhs.left) && isTerminal(rhs.right);
    else if (rhs is ConcatenationContext)
      return isTerminal(rhs.left) && isTerminal(rhs.right);
    else if (rhs is TerminalContext)
      return true;
    else if (rhs is RegularExpressionContext)
      return true;
    else if (rhs is IdentifierContext)
      return false;
    // return isTerminal(resolveReference(rhs.name));
    else
      throw new UnsupportedError('Unsupported rule: $rhs');
  }

  RuleAst getRuleAst(String ref, RightHandSideContext source) {
    return _ast.putIfAbsent(ref, () {
      Map<String, int> occurrences = {};

      void collectOccurrences(RightHandSideContext rhs) {
        // Unary
        if (rhs is GroupContext)
          collectOccurrences(rhs.context);
        else if (rhs is OptionalContext)
          collectOccurrences(rhs.context);
        else if (rhs is RepetitionContext)
          collectOccurrences(rhs.context);

        // Binary
        else if (rhs is AlternationContext) {
          collectOccurrences(rhs.left);
          collectOccurrences(rhs.right);
        } else if (rhs is ConcatenationContext) {
          collectOccurrences(rhs.left);
          collectOccurrences(rhs.right);
        }

        // ID
        else if (rhs is IdentifierContext) {
          var name = rhs.name;
          var resolved = resolveReference(name);
          if (!isTerminal(resolved)) {
            if (occurrences.containsKey(name))
              occurrences[name]++;
            else
              occurrences[name] = 1;
          }
        }
      }

      collectOccurrences(source);
      var fields = occurrences.keys.fold<List<RuleAstField>>([], (out, k) {
        return out..add(new RuleAstField(k, isList: occurrences[k] > 1));
      });
      return new RuleAst()..fields.addAll(fields);
    });
  }
}
