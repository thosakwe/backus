library json.visitor;

import 'json.ast.g.dart';

class BaseJsonVisitor<T> {
  T visitPlus(PlusContext ctx) {
    throw new UnimplementedError('Unimplemented visitor method: visitPlus');
  }

  T visitExpr(ExprContext ctx) {
    throw new UnimplementedError('Unimplemented visitor method: visitExpr');
  }

  T visitSum(SumContext ctx) {
    throw new UnimplementedError('Unimplemented visitor method: visitSum');
  }
}
