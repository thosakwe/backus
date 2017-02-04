import 'package:backus/src/text/text.dart';
import 'package:test/test.dart';

const String MATH = '''
digit = "num";
''';

const String MATH2 = '''
digit = "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" ;
sum = expr, "+", expr;
expr = digit | sum;
''';

GrammarContext parseGrammar(String str) {
  var tokens = lenient(lex(str));
  tokens.forEach(print);
  var parser = new Parser(tokens);
  return parser.parseGrammar();
}

main() {
  group('grammar', () {
    test('math', () {
      var grammar = parseGrammar(MATH);
      print(grammar.rules.length);
    });
  });
}
