library env.parser.g.dart;

import 'package:backus/backus.dart';
import 'env.ast.g.dart';
import 'env.tokens.g.dart';

class EnvParser extends Parser<String> {
  static final RegExp _rgxKEY = new RegExp('[^=]+');

  static final RegExp _rgxEQUALS = new RegExp('=');

  static final RegExp _rgxVALUE = new RegExp('[^\\n]+');

  static final RegExp _rgxNEWLINE = new RegExp('\\n');

  EnvParser(String text, [sourceUrl]) : super(text, sourceUrl);

  Token<String> parseKey() {
    if (scanner.scan(_rgxKEY)) {
      return new Token<String>(TokenType.KEY, scanner.lastSpan);
    } else {
      return null;
    }
  }

  Token<String> parseEquals() {
    if (scanner.scan(_rgxEQUALS)) {
      return new Token<String>(TokenType.EQUALS, scanner.lastSpan);
    } else {
      return null;
    }
  }

  Token<String> parseValue() {
    if (scanner.scan(_rgxVALUE)) {
      return new Token<String>(TokenType.VALUE, scanner.lastSpan);
    } else {
      return null;
    }
  }

  Token<String> parseNewline() {
    if (scanner.scan(_rgxNEWLINE)) {
      return new Token<String>(TokenType.NEWLINE, scanner.lastSpan);
    } else {
      return null;
    }
  }

  @override
  Token<String> nextToken() {
    Token<String> tok;
    tok = parseKey();
    if (tok != null) {
      return tok;
    }
    tok = parseEquals();
    if (tok != null) {
      return tok;
    }
    tok = parseValue();
    if (tok != null) {
      return tok;
    }
    tok = parseNewline();
    if (tok != null) {
      return tok;
    }
    return null;
  }

  parseEntry() {}

  parseEntryList() {}

  parseEnvFile() {}
}
