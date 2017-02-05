library json.parser;

import 'package:backus/backus.dart';
import 'json.ast.g.dart';
import 'json.tokens.g.dart';

class JsonParser extends BaseParser<TokenType> {
  JsonParser([List<Token<TokenType>> tokens = null]) : super(tokens);

  DigitContext parseDigit() {
    var result = new DigitContext();
    if (next(TokenType.DIGIT)) {
      var ref0 = current;
      result.tokens.add(ref0);
      return result;
    } else
      throw expectedType(TokenType.DIGIT);
  }

  IdContext parseId() {
    var result = new IdContext();
    if (next(TokenType.ID)) {
      var ref0 = current;
      result.tokens.add(ref0);
      return result;
    } else
      throw expectedType(TokenType.ID);
  }

  PairContext parsePair() {
    var result = new PairContext();
    final id = parseId();
    if (id != null) {
      if (next(TokenType.TOKEN_2)) {
        final expr = parseExpr();
        if (expr != null) {
          result.id = id;
          result.expr = expr;
          return result;
        } else
          throw error('Expected expr');
      } else
        throw error('TODO: Identify this');
    } else
      throw error('TODO: Identify this');
  }

  ObjectContext parseObject() {
    var result = new ObjectContext();
    if (next(TokenType.TOKEN_3)) {
      if (false) {
        if (next(TokenType.TOKEN_4)) {
          var ref2 = current;
          result.tokens.add(ref2);
          result.pairs.add(pair);
          return result;
        } else
          throw expectedType(TokenType.TOKEN_4);
      } else
        throw error('TODO: Identify this');
    } else
      throw error('TODO: Identify this');
  }

  ExprContext parseExpr() {
    var result = new ExprContext();
    final digit = parseDigit();
    if (digit != null) {
      result.digit = digit;
      return result;
    } else
      throw error('Expected digit');
  }

  PlusContext parsePlus() {
    var result = new PlusContext();
    if (next(TokenType.PLUS)) {
      var ref0 = current;
      result.tokens.add(ref0);
      return result;
    } else
      throw expectedType(TokenType.PLUS);
  }

  ArrowContext parseArrow() {
    var result = new ArrowContext();
    if (next(TokenType.TOKEN_6)) {
      if (next(TokenType.TOKEN_7)) {
        var ref1 = current;
        result.tokens.add(ref1);
        return result;
      } else
        throw expectedType(TokenType.TOKEN_7);
    } else
      throw error('TODO: Identify this');
  }
}
