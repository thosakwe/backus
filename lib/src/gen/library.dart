import 'dart:async';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:path/path.dart' as p;
import 'common.dart';

class GrammarLibraryBuilder implements Builder {
  const GrammarLibraryBuilder();

  @override
  List<AssetId> declareOutputs(AssetId inputId) =>
      [inputId.changeExtension('.language.g.dart')];

  @override
  Future build(BuildStep buildStep) async {
    var dart = prettyToSource(compile(buildStep.inputId).buildAst());
    buildStep.writeAsString(
        buildStep.inputId.changeExtension('.language.g.dart'), dart);
  }

  LibraryBuilder compile(AssetId inputId) {
    var rc = getLibraryName(inputId);
    var lib = new LibraryBuilder(rc.snakeCase);
    lib.addDirective(new ExportBuilder(
        p.basename(inputId.changeExtension('.ast.g.dart').path)));
    lib.addDirective(new ExportBuilder(
        p.basename(inputId.changeExtension('.parser.g.dart').path)));
    lib.addDirective(new ExportBuilder(
        p.basename(inputId.changeExtension('.scanner.g.dart').path)));
    lib.addDirective(new ExportBuilder(
        p.basename(inputId.changeExtension('.tokens.g.dart').path)));
    return lib;
  }
}
