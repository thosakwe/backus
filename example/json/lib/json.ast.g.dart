library json.ast;

import 'package:backus/backus.dart';
import 'json.tokens.g.dart';

class DigitContext extends AstNode<TokenType> {
  DigitContext([span = null]) : super(span);
}

class IdContext extends AstNode<TokenType> {
  IdContext([span = null]) : super(span);
}

class PairContext extends AstNode<TokenType> {
  IdContext id;

  ExprContext expr;

  PairContext([span = null]) : super(span);
}

class ObjectContext extends AstNode<TokenType> {
  final List<PairContext> pairs = [];

  ObjectContext([span = null]) : super(span);
}

class ExprContext extends AstNode<TokenType> {
  DigitContext digit;

  ExprContext([span = null]) : super(span);
}
