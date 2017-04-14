library math.parser;

import 'package:backus/backus.dart';
import 'math.ast.g.dart';
import 'math.tokens.g.dart';

class MathParser extends Parser<String> {
  MathParser(List<Token<String>> tokens) : super(tokens) {
    read();
  }

  SumContext parseSum() {
    var ctx = new SumContext();
    List<Token<String>> tokens = [];
    if (next(TokenType.NUMBER) ||
        current != null && current.type == TokenType.NUMBER) {
      tokens.add(current);
      if (next(TokenType.PLUS) ||
          current != null && current.type == TokenType.PLUS) {
        tokens.add(current);
        if (next(TokenType.NUMBER) ||
            current != null && current.type == TokenType.NUMBER) {
          tokens.add(current);
          ctx.tokens.addAll(tokens);
          return safe(ctx, print);
        } else {
          errors.add(error('Expected NUMBER'));
          return safe(null, print);
        }
      } else {
        errors.add(error('Expected PLUS'));
        return safe(null, print);
      }
    } else {
      errors.add(error('Expected NUMBER'));
      return safe(null, print);
    }
  }

  ExprContext parseExpr() {
    var ctx = new ExprContext();
    List<Token<String>> tokens = [];
    var _sum0 = parseSum();
    if (_sum0 != null) {
      var _sum1 = _sum0;
      if (_sum1 != null) {
        tokens.addAll(_sum1.tokens);
        ctx.sum = _sum1;
        ctx.tokens.addAll(tokens);
        return safe(ctx, print);
      } else {
        errors.add(error('Expected sum'));
        return safe(null, print);
      }
      ctx.tokens.addAll(tokens);
      return safe(ctx, print);
    } else if (next(TokenType.NUMBER) ||
        current != null && current.type == TokenType.NUMBER) {
      if (next(TokenType.NUMBER) ||
          current != null && current.type == TokenType.NUMBER) {
        tokens.add(current);
        ctx.tokens.addAll(tokens);
        return safe(ctx, print);
      } else {
        errors.add(error('Expected NUMBER'));
        return safe(null, print);
      }
    } else {
      errors.add(error(
          'Expected ' + 'sum or a match for regex /-?[0-9]+(\\.[0-9]+)?/'));
      return safe(null, print);
    }
  }
}
