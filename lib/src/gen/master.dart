import 'package:code_builder/code_builder.dart';
import 'grammar.dart';

LibraryBuilder generateMasterLibrary(Grammar grammar) {
  var lib = new LibraryBuilder('${grammar.name.snakeCase}.backus.g.dart');
  lib.addDirective(new ExportBuilder('${grammar.name.snakeCase}.ast.g.dart'));
  lib.addDirective(new ExportBuilder('${grammar.name.snakeCase}.parser.g.dart'));
  return lib;
}
