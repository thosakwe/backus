library json.lexer;

import 'package:backus/backus.dart';
import 'json.tokens.g.dart';

final Map<Pattern, TokenType> _patterns = {
  '=': TokenType.TOKEN_0,
  '>': TokenType.TOKEN_1
};
List<Token<TokenType>> lex(String text) {
  var scanner = new SpanScanner(text);
  List<Token<TokenType>> tokens = [];
  while (!(scanner.isDone)) {
    var start = scanner.emptySpan.start;
    List<Token<TokenType>> potential = [];
    if (tokens.isNotEmpty && tokens.last.type == TokenType.ILLEGAL) {
      tokens.removeLast();
    }
    _patterns.forEach((pattern, type) {
      if (scanner.matches(pattern)) {
        final end = scanner.lastSpan.end;
        potential.add(new Token<TokenType>(type,
            span: new SourceSpan(start, end, scanner.lastMatch.group(0))));
      }
    });
    if (potential.isEmpty) {
      var end = new SourceLocation(start.offset + 1,
          line: start.line, column: start.column);
      tokens.add(new Token(TokenType.ILLEGAL,
          span: new SourceSpan(
              start, end, new String.fromCharCode(scanner.readChar()))));
    } else {
      pushScanner(potential, tokens, scanner);
    }
  }
  return tokens;
}
