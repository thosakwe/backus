library math.scanner;

import 'package:backus/backus.dart';
import 'math.tokens.g.dart';

class MathScanner extends BaseScanner<String> {
  MathScanner({sourceUrl}) : super(TokenType.ILLEGAL, sourceUrl) {
    patterns.addAll({
      new RegExp('-?[0-9]+(\\.[0-9]+)?'): TokenType.NUMBER,
      '+': TokenType.PLUS
    });
    skip.addAll([new RegExp('[ \\n\\r\\t]+')]);
  }

  @override
  void dump(String text) => print(text);
}
