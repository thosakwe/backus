import 'package:backus/src/gen/build_grammar.dart';
import 'package:test/test.dart';

main() {
  test('do', () async {
    var grammar = await buildGrammar('foo = "bar";', Uri.parse('/Users/bar/baz.ebnf'));
    print(grammar.rules);
  });

  test('error', () async {
    var grammar = await buildGrammar('foo: 34', Uri.parse('/Users/bar/baz.ebnf'));
  });
}
