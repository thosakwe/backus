import 'package:compiler_tools/compiler_tools.dart';
import 'token_type.dart';

List<Token<TokenType>> lenient(List<Token<TokenType>> input) =>
    input.where((t) => t.type != TokenType.ILLEGAL).toList();
