import '../text/text.dart';

class Grammar {
  final String name;
  final Map<String, RightHandSideContext> rules = {};

  Grammar(this.name);

  RightHandSideContext resolveReference(String ref) {
    if (!rules.containsKey(ref)) {
      throw 'Cannot reference undefined rule "$ref".';
    } else
      return rules[ref];
  }
}
