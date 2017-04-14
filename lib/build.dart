import 'package:build_runner/build_runner.dart';
import 'src/gen/ast.dart';
//import 'src/gen/library.dart';
//import 'src/gen/parser.dart';
import 'src/gen/scanner.dart';
import 'src/gen/token_type.dart';
//import 'src/gen/visitor.dart';

Phase backusPhase(InputSet inputSet) {
  return new Phase()
        ..addAction(const AstBuilder(), inputSet)
        ..addAction(const TokenTypeBuilder(), inputSet)
        ..addAction(const ScannerBuilder(), inputSet)
      //..addAction(const ParserBuilder(), inputSet)
      //..addAction(const GrammarLibraryBuilder(), inputSet)
      //..addAction(const VisitorBuilder(), inputSet)
      ;
}
