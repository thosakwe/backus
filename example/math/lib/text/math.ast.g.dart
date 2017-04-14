library math.ast;

import 'package:backus/backus.dart';

class SumContext extends AstNode<String> {}

abstract class SumContextVisitor {
  visitSum(SumContext ctx);
}

class ExprContext extends AstNode<String> {
  SumContext sum;
}

abstract class ExprContextVisitor {
  visitExpr(ExprContext ctx);
}

abstract class MathVisitor implements SumContextVisitor, ExprContextVisitor {
  @override
  visitSum(SumContext ctx);

  @override
  visitExpr(ExprContext ctx);
}

class MathBaseVisitor implements MathVisitor {
  @override
  visitSum(SumContext ctx) {}

  @override
  visitExpr(ExprContext ctx) {
    if (ctx.sum != null) {
      visitSum(ctx.sum);
    }
  }
}
