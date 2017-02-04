library json.ast;

import 'package:backus/backus.dart';
import 'json.tokens.g.dart';

class ArrowContext extends AstNode<TokenType> {
  ArrowContext([span = null]) : super(span);
}
