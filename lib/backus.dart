/// Runtime for Backus-generated parsers.
library backus;

import 'package:compiler_tools/compiler_tools.dart';
import 'package:string_scanner/string_scanner.dart';
import 'package:source_span/source_span.dart';
export 'package:compiler_tools/compiler_tools.dart';
export 'package:string_scanner/string_scanner.dart';
export 'package:source_span/source_span.dart';

class BaseScanner<TokenType> {
  LineScannerState _invalidState;
  final List<Token<TokenType>> _tokens = [];
  final List<SyntaxError> errors = [];
  final Map<Pattern, TokenType> patterns = {};
  final List<Pattern> skip = [];
  final TokenType illegalType;

  BaseScanner(this.illegalType);

  List<Token<TokenType>> get tokens {
    if (errors.isEmpty)
      return _tokens;
    else {
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

  void scan(String text, {sourceUrl}) {
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

abstract class AstNode<T> {
  final List<Token<T>> tokens = [];

  String get sourceText => tokens.map((t) => t.text).join();
}
