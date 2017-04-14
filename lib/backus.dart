/// Runtime for Backus-generated parsers.
library backus;

import 'package:compiler_tools/compiler_tools.dart';
import 'package:string_scanner/string_scanner.dart';
import 'package:source_span/source_span.dart';
export 'package:compiler_tools/compiler_tools.dart';
export 'package:string_scanner/string_scanner.dart';
export 'package:source_span/source_span.dart';

abstract class BaseScanner<TokenType> {
  LineScannerState _invalidState;
  final List<Token<TokenType>> _tokens = [];
  final List<SyntaxError> errors = [];
  final Map<Pattern, TokenType> patterns = {};
  final List<Pattern> skip = [];
  final TokenType illegalType;
  final sourceUrl;

  BaseScanner(this.illegalType, [this.sourceUrl]);

  void dump(String text);

  List<Token<TokenType>> get tokens {
    if (errors.isEmpty)
      return _tokens;
    else {
      if (errors.isNotEmpty) {
        if (sourceUrl != null)
          dump(
              'Scanning of "$sourceUrl" failed. ${errors.length} syntax error(s) found:');
        else
          dump('Scanning of failed. ${errors.length} syntax error(s) found:');

        for (var error in errors) {
          dump('  * $error');
        }

        throw new StateError('Scanning of the provided text failed.');
      }

      throw new StateError(
          '${errors.length} syntax error(s) were encountered while scanning text.');
    }
  }

  void _flush(SpanScanner scanner) {
    if (_invalidState != null) {
      var span = scanner.spanFrom(_invalidState);
      var token = new Token(illegalType, span: span);
      tokens.add(token);
      errors.add(new SyntaxError('Invalid input "${span.text}".',
          offendingToken: token));
      _invalidState = null;
    }
  }

  void scan(String text) {
    var scanner = new SpanScanner(text, sourceUrl: sourceUrl);

    while (!scanner.isDone) {
      bool skipped = false;

      for (var pattern in skip) {
        if (scanner.scan(pattern)) {
          skipped = true;
          break;
        }
      }

      if (skipped)
        continue;
      else {
        List<Token<TokenType>> potential = [];

        patterns.forEach((k, v) {
          if (scanner.matches(k))
            potential.add(new Token(v, span: scanner.lastSpan));
        });

        if (potential.isEmpty) {
          if (_invalidState == null) _invalidState = scanner.state;
          scanner.readChar();
        } else {
          _flush(scanner);
          potential.sort((a, b) => b.text.length.compareTo(a.text.length));
          var token = potential.first;
          tokens.add(token);
          scanner.scan(token.text);
        }
      }
    }

    _flush(scanner);
  }
}

// TODO: Tune-up parser
/// A base parser that traverses a list of tokens.
class Parser<TokenType> {
  int _index = -1;
  SourceLocation _location;
  final List<SyntaxError> errors = [];
  final sourceUrl;

  int get index => _index;

  /// The tokens, scanned from source code, that are being parsed.
  final List<Token<TokenType>> tokens;

  Parser(this.tokens, {this.sourceUrl});

  /// Returns the [Token] at the current position.
  Token<TokenType> get current => eof() || _index == -1 ? null : tokens[_index];

  /// Returns the current location of the parser within source code.
  SourceLocation get location => _location;

  /// Returns `true` if the parser has reached the end of the token stream.
  bool eof() => _index >= tokens.length;

  /// Returns the given value, *IF AND ONLY IF* there are no errors.
  T safe<T>(T value, void dump(String text)) {
    if (errors.isNotEmpty) {
      if (sourceUrl != null)
        dump(
            'Parsing of "$sourceUrl" failed. ${errors.length} syntax error(s) found:');
      else
        dump('Parsing of input text failed. ${errors.length} syntax error(s) found:');

      for (var error in errors) {
        dump('  * $error');
        if (error.offendingToken != null)
          dump('    > offending token: ${error.offendingToken}');
      }

      throw new StateError('Parsing of the provided text failed.');
    }

    return value;
  }

  /// Advances a negative [n] number of steps, and returns the token at the new position.
  Token<TokenType> backtrack([int n]) => read((n ?? 1) * -1);

  /// Returns a [SyntaxError] with the given message, and [current] as the offending token.
  SyntaxError error(String msg) {
    return new SyntaxError(msg, offendingToken: current);
  }

  /// Throws a [SyntaxError] indicating that an expected token type was not found.
  SyntaxError expectedType(TokenType type) {
    return error('Expected $type, ${current?.type ?? "nothing"} found.');
  }

  /// Checks if the next token is of the given [type]. If `true`, it will be consumed.
  bool next(TokenType type) {
    if (_index >= tokens.length - 1) {
      return false;
    }

    if (peek()?.type == type) {
      read();
      return true;
    }

    return false;
  }

  /// Looks ahead an [n] number of steps without advancing the position.
  Token<TokenType> peek([int n]) {
    var i = _index + (n ?? 1);

    if (i >= tokens.length || i < 0)
      return null;
    else
      return tokens[_index + (n ?? 1)];
  }

  /// Looks behind an [n] number of steps without advancing the position.
  Token<TokenType> peekBehind([int n]) => peek((n ?? -1) * -1);

  /// Advances the stream an [n] number of steps, and returns the token at the new position.
  Token<TokenType> read([int n]) {
    var i = _index + (n ?? 1);

    if (i >= tokens.length)
      return null;
    else {
      var tok = tokens[_index += (n ?? 1)];
      _location = tok.span.start;
      return tok;
    }
  }
}

abstract class AstNode<T> {
  final List<Token<T>> tokens = [];

  String get sourceText => tokens.map((t) => t.text).join();
}
