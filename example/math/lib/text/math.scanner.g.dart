library math.scanner;

import 'package:backus/backus.dart';
import 'math.tokens.g.dart';

class MathScanner extends BaseScanner<String> {
  MathScanner() : super(TokenType.ILLEGAL) {
    patterns.addAll({'+': TokenType.PLUS});
    skip.addAll([new RegExp('[ \\n\\r\\t]+')]);
  }
}
