library json.parser;

import 'package:backus/backus.dart';
import 'json.ast.g.dart';
import 'json.tokens.g.dart';

class JsonParser extends BaseParser<TokenType> {
  JsonParser([List<Token<TokenType>> tokens = null]) : super(tokens);

  PlusContext parsePlus() {
    var result = new PlusContext();
    if (next(TokenType.PLUS)) {
      var ref0 = current;
      result.tokens.add(ref0);
      return result;
    } else
      throw expectedType(TokenType.PLUS);
  }

  ExprContext parseExpr() {
    var result = new ExprContext();
    result.digit = digit;
    result.sum = sum;
    return result;
  }

  SumContext parseSum() {
    var result = new SumContext();
    final expr = parseExpr();
    if (expr != null) {
      final plus = parsePlus();
      if (plus != null) {
        final expr = parseExpr();
        if (expr != null) {
          result.exprs.add(expr);
          result.plus = plus;
          return result;
        } else
          throw error('Expected expr');
      } else
        throw error('TODO: Identify this');
    } else
      throw error('TODO: Identify this');
  }
}
