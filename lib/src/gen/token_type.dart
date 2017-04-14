import 'dart:async';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:recase/recase.dart';
import 'common.dart';

class TokenTypeBuilder implements Builder {
  const TokenTypeBuilder();

  @override
  List<AssetId> declareOutputs(AssetId inputId) =>
      [inputId.changeExtension('.tokens.g.dart')];

  @override
  Future build(BuildStep buildStep) async {
    var ebnf = await buildStep.readAsString(buildStep.inputId);
    var grammar = parseGrammar(ebnf, buildStep.inputId.path);
    var dart = prettyToSource(
        compile(grammar, getLibraryName(buildStep.inputId)).buildAst());
    buildStep.writeAsString(
        buildStep.inputId.changeExtension('.tokens.g.dart'), dart);
  }

  LibraryBuilder compile(GrammarContext grammar, ReCase rc) {
    return new LibraryBuilder('${rc.snakeCase}.tokens')
      ..addMember(compileEnum(grammar));
  }

  ClassBuilder compileEnum(GrammarContext grammar) {
    // For now, `package:code_builder` does not provide for building enum classes.
    //
    // So, token types will merely be Strings. :)
    var clazz = new ClassBuilder('TokenType', asAbstract: true);
    var ctx = GeneratorContext.process(grammar);

    clazz.addField(
        varConst('ILLEGAL',
            type: new TypeBuilder('String'), value: literal('<illegal token>')),
        asStatic: true);

    for (var name in ctx.ruleNames.keys) {
      if (!name.startsWith('skip-')) {
        var rc = new ReCase(name);
        clazz.addField(
            varConst(rc.constantCase,
                type: new TypeBuilder('String'),
                value: literal('TokenType.${rc.constantCase}')),
            asStatic: true);
      }
    }

    return clazz;
  }
}
