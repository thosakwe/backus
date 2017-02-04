/// Runtime for Backus-generated parsers.
library backus;

import 'package:compiler_tools/compiler_tools.dart';
import 'package:source_span/source_span.dart';
export 'package:compiler_tools/compiler_tools.dart';
export 'package:string_scanner/string_scanner.dart';

abstract class AstNode<T> {
  final List<Token<T>> tokens = [];
  final SourceSpan span;

  String get sourceText => tokens.map((t) => t.text).join();

  AstNode([this.span]);
}
