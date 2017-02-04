import 'package:compiler_tools/compiler_tools.dart';
import 'package:source_span/source_span.dart';
import 'package:string_scanner/string_scanner.dart';
import 'token_type.dart';

final RegExp _comment = new RegExp(r'\(\*(.|\n)*\*\)');
final RegExp _whitespace = new RegExp(r'( |\r\n\t)+');
final RegExp _terminal1 = new RegExp(
    r'"((\\(["\\/bfnrt]|(u[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F])))|([^"\\]))*"');
final RegExp _terminal2 = new RegExp(
    r"'((\\(['\\/bfnrt]|(u[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F])))|([^'\\]))*'");
final RegExp _id =
    new RegExp(r'[_A-Za-z](([A-Za-z0-9_])|(-[A-Za-z0-9][A-Za-z]))*');
final RegExp _regex = new RegExp(r'\/(\\\/|[^\/])+\/i?');

final Map<Pattern, TokenType> _patterns = {
  ',': TokenType.COMMA,
  '{': TokenType.CURLY_L,
  '}': TokenType.CURLY_R,
  '=': TokenType.EQUALS,
  '-': TokenType.MINUS,
  '(': TokenType.PAREN_L,
  ')': TokenType.PAREN_R,
  '|': TokenType.PIPE,
  ';': TokenType.SEMI,
  '[': TokenType.SQUARE_L,
  ']': TokenType.SQUARE_R,
  _comment: TokenType.COMMENT,
  _regex: TokenType.REGEX,
  _terminal1: TokenType.TERMINAL,
  _terminal2: TokenType.TERMINAL,
  _id: TokenType.ID
};

List<Token<TokenType>> lex(String text) {
  List<Token<TokenType>> tokens = [];
  var scanner = new SpanScanner(text);

  while (!scanner.isDone) {
    var start = scanner.emptySpan.start;
    List<Token<TokenType>> potential = [];

    if (scanner.scan(_whitespace)) {
      // If we find whitespace after an illegal entry, let's tack it
      // onto the previous one.
      if (tokens.isNotEmpty && tokens.last.type == TokenType.ILLEGAL) {
        var cur = scanner.state;
        int off = cur.position - start.offset,
            offCol = cur.column - start.column,
            offLine = cur.line - start.line;
        var end = new SourceLocation(start.offset + off,
            line: start.line + offLine, column: start.column + offCol);

        var illegalStart = tokens.last.span.start,
            illegalText = tokens.last.text;
        tokens.removeLast();
        /*tokens.add(new Token(TokenType.ILLEGAL,
            span: new SourceSpan(
                illegalStart, end, illegalText + scanner.lastMatch[0])));*/
      }

      continue;
    }

    _patterns.forEach((pattern, type) {
      if (scanner.matches(pattern)) {
        var end = scanner.lastSpan.end;
        potential.add(new Token(type,
            span: new SourceSpan(start, end, scanner.lastMatch[0])));
      }
    });

    if (potential.isEmpty) {
      var end = new SourceLocation(start.offset + 1,
          line: start.line, column: start.column);
      // Check if there is an existing illegal token. If so,
      // replace with a longer one.
      /* if (false && tokens.isNotEmpty && tokens.last.type == TokenType.ILLEGAL) {
        var illegalStart = tokens.last.span.start,
            illegalText = tokens.last.text;
        tokens.removeLast();
        tokens.add(new Token(TokenType.ILLEGAL,
            span: new SourceSpan(illegalStart, end,
                illegalText + new String.fromCharCode(scanner.readChar()))));
      } else {*/
      tokens.add(new Token(TokenType.ILLEGAL,
          span: new SourceSpan(
              start, end, new String.fromCharCode(scanner.readChar()))));
      //}
    } else {
      potential.sort((a, b) => b.text.length.compareTo(a.text.length));
      tokens.add(potential.first);
      scanner.scan(potential.first.text);
    }
  }

  return tokens.where((t) => t.type != TokenType.COMMENT).toList();
}
