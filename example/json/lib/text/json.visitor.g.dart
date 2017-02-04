library json.visitor;

import 'json.ast.g.dart';

class BaseJsonVisitor<T> {
  T visitDigit(DigitContext ctx) {
    throw new UnimplementedError('Unimplemented visitor method: visitDigit');
  }

  T visitId(IdContext ctx) {
    throw new UnimplementedError('Unimplemented visitor method: visitId');
  }

  T visitPair(PairContext ctx) {
    throw new UnimplementedError('Unimplemented visitor method: visitPair');
  }

  T visitObject(ObjectContext ctx) {
    throw new UnimplementedError('Unimplemented visitor method: visitObject');
  }

  T visitExpr(ExprContext ctx) {
    throw new UnimplementedError('Unimplemented visitor method: visitExpr');
  }

  T visitPlus(PlusContext ctx) {
    throw new UnimplementedError('Unimplemented visitor method: visitPlus');
  }
}
