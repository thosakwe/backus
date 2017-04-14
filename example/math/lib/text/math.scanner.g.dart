library math.scanner;

import 'package:backus/backus.dart';
import 'math.tokens.g.dart';

class MathScanner extends BaseScanner<String> {
  MathScanner() : super(TokenType.ILLEGAL) {
    patterns
        .addAll({new RegExp('[0-9]+'): TokenType.DIGIT, '+': TokenType.PLUS});
    skip.addAll([new RegExp('[ \\n\\r\\t]+')]);
  }
}
