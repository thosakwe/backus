library json.ast;

import 'package:backus/backus.dart';
import 'json.tokens.g.dart';

class PlusContext extends AstNode<TokenType> {
  PlusContext([span = null]) : super(span);
}

class ExprContext extends AstNode<TokenType> {
  DigitContext digit;

  SumContext sum;

  ExprContext([span = null]) : super(span);
}

class SumContext extends AstNode<TokenType> {
  final List<ExprContext> exprs = [];

  PlusContext plus;

  SumContext([span = null]) : super(span);
}
