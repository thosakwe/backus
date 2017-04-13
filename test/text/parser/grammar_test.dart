import 'package:backus/src/text/text.dart';
import 'package:test/test.dart';

const String FOO = '''
foo = "num";
''';

const String MATH = '''
digit = "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" ;
sum = expr, "+", expr;
expr = digit | sum;
''';

GrammarContext parseGrammar(String str) {
  var scanner = new Scanner()..scan(str);
  var tokens = scanner.tokens;
  tokens.forEach(print);
  var parser = new Parser(tokens);
  return parser.parseGrammar();
}

main() {
  group('grammar', () {
    test('foo', () {
      var grammar = parseGrammar(FOO);
      expect(grammar.rules, hasLength(1));
    });

    test('math', () {
      var grammar = parseGrammar(MATH);
      expect(grammar.rules, hasLength(3));
    });
  });
}
