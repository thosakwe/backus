import 'dart:async';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:inflection/inflection.dart';
import 'package:recase/recase.dart';
import 'common.dart';

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

    return lib
      ..addMember(compileMasterVisitor(rc, ctx))
      ..addMember(compileBaseVisitor(rc, ctx));
  }

  ClassBuilder compileContext(
      String name, RightHandSideContext rhs, GeneratorContext ctx) {
    var rc = new ReCase(name);
    var clazz = new ClassBuilder('${rc.pascalCase}Context',
        asExtends: new TypeBuilder('AstNode',
            genericTypes: [new TypeBuilder('String')]));

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
          clazz.addField(varFinal(pluralize(rc.camelCase),
              type: new TypeBuilder('List', genericTypes: [type]),
              value: list([])));
        }
      }
    });

    return clazz;
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

  static void countReferences(
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

  static void countDeepReferences(
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

  static void _increment(String name, Map<String, int> fields) {
    if (fields.containsKey(name))
      fields[name]++;
    else
      fields[name] = 1;
  }

  ClassBuilder compileMasterVisitor(ReCase rc, GeneratorContext ctx) {
    List<TypeBuilder> asImplements = [];

    ctx.ruleNames.forEach((name, rhs) {
      if (!isTerminal(rhs)) {
        var rc = new ReCase(name);
        asImplements.add(new TypeBuilder('${rc.pascalCase}ContextVisitor'));
      }
    });

    var clazz = new ClassBuilder('${rc.pascalCase}Visitor',
        asAbstract: true, asImplements: asImplements);

    ctx.ruleNames.forEach((name, rhs) {
      if (!isTerminal(rhs)) {
        var rc = new ReCase(name);
        clazz.addMethod(new MethodBuilder('visit${rc.pascalCase}',
            asAbstract: true)
          ..addPositional(
              parameter('ctx', [new TypeBuilder('${rc.pascalCase}Context')]))
          ..addAnnotation(reference('override')));
      }
    });

    // Master `visit` method
    // TODO: https://github.com/dart-lang/code_builder/issues/101
    /*var masterVisit = new MethodBuilder('visit')
      ..addPositional(parameter('ctx', [
        new TypeBuilder('AstNode', genericTypes: [new TypeBuilder('String')])
      ]));

    clazz.addMethod(masterVisit);*/

    return clazz;
  }

  ClassBuilder compileBaseVisitor(ReCase rc, GeneratorContext ctx) {
    var clazz = new ClassBuilder('${rc.pascalCase}BaseVisitor',
        asImplements: [new TypeBuilder('${rc.pascalCase}Visitor')]);

    ctx.ruleNames.forEach((name, rhs) {
      if (!isTerminal(rhs)) {
        var rc = new ReCase(name);
        var m = new MethodBuilder('visit${rc.pascalCase}')
          ..addPositional(
              parameter('ctx', [new TypeBuilder('${rc.pascalCase}Context')]))
          ..addAnnotation(reference('override'));
        clazz.addMethod(m);

        Map<String, int> fields = {};
        countReferences(rhs, fields, ctx);

        fields.forEach((key, count) {
          if (count > 0) {
            var rhs = ctx.ruleNames[key];

            if (!isTerminal(rhs)) {
              var rc = new ReCase(key);

              if (count == 1) {
                m.addStatement(ifThen(
                    reference('ctx')
                        .property(rc.camelCase)
                        .notEquals(literal(null)),
                    [
                      reference('visit${rc.pascalCase}')
                          .call([reference('ctx').property(rc.camelCase)])
                    ]));
              } else {
                m.addStatement(ifThen(
                    reference('ctx')
                        .property(pluralize(rc.camelCase))
                        .property('isNotEmpty'),
                    [
                      new ForStatementBuilder.forEach(rc.camelCase,
                          reference('ctx').property(pluralize(rc.camelCase)))
                        ..addStatement(reference('visit${rc.pascalCase}')
                            .call([reference(rc.camelCase)]))
                    ]));
              }
            }
          }
        });
      }
    });

    return clazz;
  }
}
