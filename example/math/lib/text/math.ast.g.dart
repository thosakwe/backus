library math.ast;

import 'package:backus/backus.dart';

class ExprContext implements AstNode<String> {
  SumContext sum;

  @override
  String get sourceText => throw new UnsupportedError(
      'ExprContext: Backus does not yet support retrieving AST node source text.');
}

abstract class ExprContextVisitor {
  visitExpr(ExprContext ctx);
}

class SumContext implements AstNode<String> {
  List<ExprContext> exprs = [];

  @override
  String get sourceText => throw new UnsupportedError(
      'SumContext: Backus does not yet support retrieving AST node source text.');
}

abstract class SumContextVisitor {
  visitSum(SumContext ctx);
}
