import 'dart:async';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:inflection/inflection.dart';
import 'package:path/path.dart' as p;
import 'common.dart';
import 'package:recase/recase.dart';

class AstBuilder implements Builder {
  const AstBuilder();

  @override
  List<AssetId> declareOutputs(AssetId inputId) =>
      [inputId.changeExtension('.ast.g.dart')];

  @override
  Future build(BuildStep buildStep) async {
    var ebnf = await buildStep.readAsString(buildStep.inputId);
    var grammar = parseGrammar(ebnf, buildStep.inputId.path);
    var dart = prettyToSource(compile(grammar, buildStep.inputId).buildAst());
    buildStep.writeAsString(
        buildStep.inputId.changeExtension('.ast.g.dart'), dart);
  }

  LibraryBuilder compile(GrammarContext grammar, AssetId inputId) {
    var ctx = GeneratorContext.process(grammar);
    var rc = getLibraryName(inputId);
    var lib = new LibraryBuilder('${rc.snakeCase}.ast');
    lib.addDirective(new ImportBuilder('package:backus/backus.dart'));

    ctx.ruleNames.forEach((name, rhs) {
      if (!isTerminal(rhs)) {
        lib.addMembers(
            [compileContext(name, rhs, ctx), compileVisitor(name, rhs, ctx)]);
      }
    });

    return lib;
  }

  ClassBuilder compileContext(
      String name, RightHandSideContext rhs, GeneratorContext ctx) {
    var rc = new ReCase(name);
    var clazz = new ClassBuilder('${rc.pascalCase}Context', asImplements: [
      new TypeBuilder('AstNode', genericTypes: [new TypeBuilder('String')])
    ]);

    // Add fields if necessary, whether List or individual
    Map<String, int> fields = {};
    countReferences(rhs, fields, ctx);

    fields.forEach((name, count) {
      if (count > 0) {
        var rc = new ReCase(name);
        var type = new TypeBuilder('${rc.pascalCase}Context');

        if (count == 1) {
          clazz.addField(varField(rc.camelCase, type: type));
        } else {
          clazz.addField(varField(pluralize(rc.camelCase),
              type: new TypeBuilder('List', genericTypes: [type]),
              value: list([])));
        }
      }
    });

    // TODO: Add overridden get text
    var sourceText = new MethodBuilder.getter('sourceText',
        returnType: new TypeBuilder('String'),
        returns: new TypeBuilder('UnsupportedError').newInstance([
          literal(
              '${rc.pascalCase}Context: Backus does not yet support retrieving AST node source text.')
        ]).asThrow());
    sourceText.addAnnotation(reference('override'));

    return clazz..addMethod(sourceText);
  }

  ClassBuilder compileVisitor(
      String name, RightHandSideContext rhs, GeneratorContext ctx) {
    var rc = new ReCase(name);
    var clazz =
        new ClassBuilder('${rc.pascalCase}ContextVisitor', asAbstract: true);
    clazz.addMethod(new MethodBuilder('visit${rc.pascalCase}', asAbstract: true)
      ..addPositional(
          parameter('ctx', [new TypeBuilder('${rc.pascalCase}Context')])));

    return clazz;
  }

  void countReferences(
      RightHandSideContext rhs, Map<String, int> fields, GeneratorContext ctx) {
    if (rhs is IdentifierContext && !rhs.name.startsWith('skip-')) {
      var ref = ctx.ruleNames[rhs.name];

      if (ref == null)
        throw new UnsupportedError('Unknown rule reference "${rhs.name}".');
      else if (!isTerminal(ref)) _increment(rhs.name, fields);
    }
    if (rhs is TerminalContext || rhs is RegularExpressionContext)
      countDeepReferences(rhs, fields, ctx);
    else if (rhs is AlternationContext) {
      countDeepReferences(rhs.left, fields, ctx);
      countDeepReferences(rhs.right, fields, ctx);
    } else if (rhs is ConcatenationContext) {
      countDeepReferences(rhs.left, fields, ctx);
      countDeepReferences(rhs.right, fields, ctx);
    } else if (rhs is GroupContext)
      countDeepReferences(rhs.context, fields, ctx);
    else if (rhs is OptionalContext)
      countDeepReferences(rhs.context, fields, ctx);
    else if (rhs is RepetitionContext) {
      // Do it twice, repeat it...
      countDeepReferences(rhs.context, fields, ctx);
      countDeepReferences(rhs.context, fields, ctx);
    }
  }

  void countDeepReferences(
      RightHandSideContext rhs, Map<String, int> fields, GeneratorContext ctx) {
    if (rhs is IdentifierContext) {
      countReferences(rhs, fields, ctx);
    } else {
      if (ctx.ruleNames.containsValue(rhs)) {
        for (var key in ctx.ruleNames.keys) {
          if (ctx.ruleNames[key] == rhs) {
            _increment(key, fields);
            break;
          }
        }
      }

      if (rhs is! TerminalContext && rhs is! RegularExpressionContext) {
        countReferences(rhs, fields, ctx);
      }
    }
  }

  void _increment(String name, Map<String, int> fields) {
    if (fields.containsKey(name))
      fields[name]++;
    else
      fields[name] = 1;
  }
}
