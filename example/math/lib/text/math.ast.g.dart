library math.ast;

import 'package:backus/backus.dart';

class ExprContext extends AstNode<String> {
  SumContext sum;
}

abstract class ExprContextVisitor {
  visitExpr(ExprContext ctx);
}

class SumContext extends AstNode<String> {
  List<ExprContext> exprs = [];
}

abstract class SumContextVisitor {
  visitSum(SumContext ctx);
}

abstract class MathVisitor implements ExprContextVisitor, SumContextVisitor {
  @override
  visitExpr(ExprContext ctx);

  @override
  visitSum(SumContext ctx);
}

class MathBaseVisitor implements MathVisitor {
  @override
  visitExpr(ExprContext ctx) {}

  @override
  visitSum(SumContext ctx) {}
}
