library json.parser;

import 'package:backus/backus.dart';
import 'json.ast.g.dart';
import 'json.tokens.g.dart';

class JsonParser extends BaseParser<TokenType> {
  JsonParser([List<Token<TokenType>> tokens = null]) : super(tokens);

  DigitContext parseDigit() {
    if (!(next(TokenType.DIGIT))) {
      return null;
    }
  }

  IdContext parseId() {
    if (!(next(TokenType.ID))) {
      return null;
    }
  }

  PairContext parsePair() {}

  ObjectContext parseObject() {}

  ExprContext parseExpr() {}

  PlusContext parsePlus() {
    if (!(next(TokenType.PLUS))) {
      return null;
    }
  }
}
