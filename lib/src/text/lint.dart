import 'package:compiler_tools/compiler_tools.dart';
import 'token_type.dart';

List<Token<TokenType>> lint(List<Token<TokenType>> input) {
  List<Token> output = [];
  List errors = [];

  for (var token in input) {
    if (token.type == TokenType.ILLEGAL)
      errors.add(
          "line ${token.span.start.line}, col ${token.span.start.column}: Unexpected '${token.text}'.");
    else
      output.add(token);
  }

  if (errors.isNotEmpty) throw new LinterError()..errors.addAll(errors);
  return output;
}

class LinterError {
  final List errors = [];

  String toString() => (['Found ${errors.length} error(s) in your code:']
        ..addAll(errors
            .map((e) => '$e'.replaceAll('\n', '\\n'))
            .map((e) => '  * $e')))
      .join('\n');
}
