library json.parser;

import 'package:backus/backus.dart';
import 'json.ast.g.dart';
import 'json.tokens.g.dart';

class JsonParser extends BaseParser<TokenType> {
  JsonParser([List<Token<TokenType>> tokens = null]) : super(tokens);
}
