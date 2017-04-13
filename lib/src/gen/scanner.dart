import 'dart:async';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:path/path.dart' as p;
import 'common.dart';
import 'package:recase/recase.dart';

class ScannerBuilder implements Builder {
  const ScannerBuilder();

  @override
  List<AssetId> declareOutputs(AssetId inputId) =>
      [inputId.changeExtension('.scanner.g.dart')];

  @override
  Future build(BuildStep buildStep) async {
    var ebnf = await buildStep.readAsString(buildStep.inputId);
    var grammar = parseGrammar(ebnf, buildStep.inputId.path);
    var dart = prettyToSource(compile(grammar, buildStep.inputId).buildAst());
    buildStep.writeAsString(
        buildStep.inputId.changeExtension('.scanner.g.dart'), dart);
  }

  LibraryBuilder compile(GrammarContext grammar, AssetId inputId) {
    var rc = getLibraryName(inputId);
    var lib = new LibraryBuilder('${rc.snakeCase}.scanner');
    lib.addDirective(new ImportBuilder('package:backus/backus.dart'));
    lib.addDirective(new ImportBuilder(
        p.basename(inputId.changeExtension('.tokens.g.dart').path)));
    return lib..addMember(compileClass(grammar, rc));
  }

  ClassBuilder compileClass(GrammarContext grammar, ReCase rc) {
    // For now, `package:code_builder` does not provide for building enum classes.
    //
    // So, token types will merely be Strings. :)
    var ctx = GeneratorContext.process(grammar);
    var clazz = new ClassBuilder('${rc.pascalCase}Scanner',
        asExtends: new TypeBuilder('BaseScanner',
            genericTypes: [new TypeBuilder('String')]));

    // Add constructor to set illegal type
    var c = new ConstructorBuilder(
        invokeSuper: [new TypeBuilder('TokenType').property('ILLEGAL')]);

    // Initialize `patterns` map
    Map<ExpressionBuilder, ExpressionBuilder> patterns = {};

    ctx.ruleNames.forEach((k, v) {
      if (isTerminal(v) && !k.startsWith('skip-')) {
        var rc = new ReCase(k);
        var left = terminalToExpression(v);
        var right = new TypeBuilder('TokenType').property(rc.constantCase);
        patterns[left] = right;
      }
    });

    if (patterns.isNotEmpty)
      c.addStatement(reference('patterns').invoke('addAll', [map(patterns)]));

    // Add patterns to `skip` list
    List<ExpressionBuilder> skip = [];

    ctx.ruleNames.forEach((k, v) {
      if (isTerminal(v) && k.startsWith('skip-')) {
        skip.add(terminalToExpression(v));
      }
    });

    if (skip.isNotEmpty)
      c.addStatement(reference('skip').invoke('addAll', [list(skip)]));

    return clazz..addConstructor(c);
  }
}
