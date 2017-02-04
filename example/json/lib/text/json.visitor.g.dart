library json.visitor;

import 'json.ast.g.dart';

class BaseJsonVisitor<T> {
  T visitArrow(ArrowContext ctx) {
    throw new UnimplementedError('Unimplemented visitor method: visitArrow');
  }
}
