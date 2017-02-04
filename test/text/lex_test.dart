import 'package:backus/src/text/text.dart';
import 'package:test/test.dart';

const String MATH = '''
digit = "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" ;
sum = expr, "+", expr;
expr = digit | sum;
''';

main() {
  test('wtf', () {
    lex(MATH).where((t) => t.type != TokenType.ILLEGAL).forEach(print);
  });
}
