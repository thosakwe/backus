library json.parser;

import 'package:backus/backus.dart';
import 'json.ast.g.dart';
import 'json.tokens.g.dart';

class JsonParser extends BaseParser<TokenType> {
  JsonParser([List<Token<TokenType>> tokens = null]) : super(tokens);

  ArrowContext parseArrow() {
    if (next(TokenType.TOKEN_0)) {
      var ref0 = current;
      if (next(TokenType.TOKEN_1)) {
        var ref1 = current;
      } else
        throw expectedType(TokenType.TOKEN_1);
    } else
      throw error('TODO: Identify this');
  }
}
