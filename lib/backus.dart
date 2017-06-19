/// Runtime for Backus-generated parsers.
library backus;

import 'dart:collection';
import 'package:compiler_tools/compiler_tools.dart';
import 'package:string_scanner/string_scanner.dart';
import 'package:source_span/source_span.dart';
export 'package:compiler_tools/compiler_tools.dart';
export 'package:string_scanner/string_scanner.dart';
export 'package:source_span/source_span.dart';

class AstNode {
  final String text;
  AstNode(this.text);
}

abstract class Parser<TokenType> {
  Token<TokenType> _current;
  SpanScanner _scanner;
  final Queue<Token<TokenType>> _queue = new Queue<Token<TokenType>>();

  Token get current => _current;

  SpanScanner get scanner => _scanner;

  Parser(String text, [sourceUrl]) {
    _scanner = new SpanScanner(text, sourceUrl: sourceUrl);
  }

  bool nextIs(TokenType type) {
    var tok = _queue.isNotEmpty ? _queue.removeFirst() : nextToken();
    if (tok?.type == type) {
      _current = tok;
      return true;
    } else if (tok != null) {
      _queue.add(tok);
      return false;
    } else
      return false;
  }

  Token<TokenType> nextToken();
}

class Token<TokenType> {
  final TokenType type;
  final SourceSpan span;

  Token(this.type, this.span);
}
