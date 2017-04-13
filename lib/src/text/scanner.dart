import 'package:compiler_tools/compiler_tools.dart';
import 'package:string_scanner/string_scanner.dart';
import 'token_type.dart';

final RegExp _COMMENT = new RegExp(r'\(\*(.|\n)*\*\)');
final RegExp _WHITESPACE = new RegExp(r'[ \r\t\n]+');
final RegExp _TERMINAL1 = new RegExp(
    r'"((\\(["\\/bfnrt]|(u[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F])))|([^"\\]))*"');
final RegExp _TERMINAL2 = new RegExp(
    r"'((\\(['\\/bfnrt]|(u[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F])))|([^'\\]))*'");
final RegExp _ID =
    new RegExp(r'[_A-Za-z](([A-Za-z0-9_])|(-[A-Za-z0-9][A-Za-z]))*');
final RegExp _REGEX = new RegExp(r'/(\\/|[^/])+/i?');

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
  _COMMENT: TokenType.COMMENT,
  _REGEX: TokenType.REGEX,
  _TERMINAL1: TokenType.TERMINAL,
  _TERMINAL2: TokenType.TERMINAL,
  _ID: TokenType.ID
};

class Scanner {
  LineScannerState _invalidState;
  final List<Token<TokenType>> _tokens = [];
  final List<SyntaxError> errors = [];

  List<Token<TokenType>> get tokens {
    if (errors.isEmpty)
      return _tokens;
    else {
      throw new StateError(
          '${errors.length} syntax error(s) were encountered while scanning text.');
    }
  }

  void flush(SpanScanner scanner) {
    if (_invalidState != null) {
      var span = scanner.spanFrom(_invalidState);
      var token = new Token(TokenType.ILLEGAL, span: span);
      tokens.add(token);
      errors.add(new SyntaxError('Invalid input "${span.text}".',
          offendingToken: token));
      _invalidState = null;
    }
  }

  void scan(String text, {sourceUrl}) {
    var scanner = new SpanScanner(text, sourceUrl: sourceUrl);

    while (!scanner.isDone) {
      if (scanner.scan(_WHITESPACE))
        continue;
      else {
        List<Token<TokenType>> potential = [];

        _patterns.forEach((k, v) {
          if (scanner.matches(k))
            potential.add(new Token(v, span: scanner.lastSpan));
        });

        if (potential.isEmpty) {
          if (_invalidState == null) _invalidState = scanner.state;
          scanner.readChar();
        } else {
          flush(scanner);
          potential.sort((a, b) => b.text.length.compareTo(a.text.length));
          var token = potential.first;
          tokens.add(token);
          scanner.scan(token.text);
        }
      }
    }

    flush(scanner);
  }
}
