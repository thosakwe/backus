import 'package:build_runner/build_runner.dart';
import 'src/gen/ast.dart';
import 'src/gen/library.dart';
import 'src/gen/parser.dart';
import 'src/gen/scanner.dart';
import 'src/gen/token_type.dart';
export 'src/gen/ast.dart';
export 'src/gen/library.dart';
export 'src/gen/parser.dart';
export 'src/gen/scanner.dart';
export 'src/gen/token_type.dart';

Phase backusPhase(InputSet inputSet,
    {bool debug: false, bool importIO: false}) {
  return new Phase()
    ..addAction(const AstBuilder(), inputSet)
    ..addAction(const TokenTypeBuilder(), inputSet)
    ..addAction(new ScannerBuilder(importIO: importIO == true), inputSet)
    ..addAction(
        new ParserBuilder(debug: debug == true, importIO: importIO == true),
        inputSet)
    ..addAction(const GrammarLibraryBuilder(), inputSet);
}
