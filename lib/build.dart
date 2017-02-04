import 'package:build_runner/build_runner.dart';
import 'src/build/ast_builder.dart';
import 'src/build/lexer_builder.dart';
import 'src/build/parser_builder.dart';
import 'src/build/token_type_builder.dart';

Phase backusPhase(InputSet inputSet) {
  return new Phase()
    ..addAction(const AstBuilder(), inputSet)
    ..addAction(const TokenTypeBuilder(), inputSet)
    ..addAction(const LexerBuilder(), inputSet)
    ..addAction(const ParserBuilder(), inputSet);
}
