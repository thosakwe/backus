import 'dart:async';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:code_builder/src/builders/expression.dart';
import 'package:code_builder/src/builders/statement.dart';
import 'package:inflection/inflection.dart';
import 'package:path/path.dart' as p;
import 'package:recase/recase.dart';
import 'ast.dart' as backus;
import 'common.dart';

class ParserBuilder implements Builder {
  final bool debug, importIO;

  static final TypeBuilder TYPE_TOKEN_LIST =
      new TypeBuilder('List', genericTypes: [
    new TypeBuilder('Token', genericTypes: [new TypeBuilder('String')])
  ]);

  const ParserBuilder({this.debug, this.importIO: false});

  @override
  List<AssetId> declareOutputs(AssetId inputId) =>
      [inputId.changeExtension('.parser.g.dart')];

  @override
  Future build(BuildStep buildStep) async {
    var ebnf = await buildStep.readAsString(buildStep.inputId);
    var grammar = parseGrammar(ebnf, buildStep.inputId.path);
    var dart = prettyToSource(compile(grammar, buildStep.inputId).buildAst());
    buildStep.writeAsString(
        buildStep.inputId.changeExtension('.parser.g.dart'), dart);
  }

  LibraryBuilder compile(GrammarContext grammar, AssetId inputId) {
    var ctx = GeneratorContext.process(grammar);
    var rc = getLibraryName(inputId);
    var lib = new LibraryBuilder('${rc.snakeCase}.parser');

    if (importIO == true) lib.addDirective(new ImportBuilder('dart:io'));

    lib.addDirective(new ImportBuilder('package:backus/backus.dart'));
    lib.addDirective(new ImportBuilder(
        p.basename(inputId.changeExtension('.ast.g.dart').path)));
    lib.addDirective(new ImportBuilder(
        p.basename(inputId.changeExtension('.tokens.g.dart').path)));

    return lib..addMember(compileParser(rc, ctx));
  }

  ClassBuilder compileParser(ReCase rc, GeneratorContext ctx) {
    var clazz = new ClassBuilder('${rc.pascalCase}Parser',
        asExtends: new TypeBuilder('Parser',
            genericTypes: [new TypeBuilder('String')]));

    // Add constructor
    var c = new ConstructorBuilder(invokeSuper: [reference('tokens')])
      ..addPositional(parameter('tokens', [TYPE_TOKEN_LIST]))
      ..addStatement(reference('read').call([]));

    if (debug == true) {
      c.addStatement(reference('print').call([
        reference('tokens').property('length').invoke('toString', []) +
            literal(' token(s):')
      ]));
      c.addStatement(new ForStatementBuilder.forEach(
          'token', reference('tokens'))
        ..addStatement(reference('print').call(
            [literal('  * ') + reference('token').invoke('toString', [])])));

      // Add custom peek, next
      var peek = new MethodBuilder('peek'), next = new MethodBuilder('next');

      peek
        ..addPositional(parameter('n', [new TypeBuilder('int'), literal(1)]))
        ..addStatements([
          reference('print').call(
              [literal('Index: ') + reference('index').invoke('toString', [])]),
          varField('result', value: superRef.invoke('peek', [reference('n')])),
          ifThen(reference('result').notEquals(literal(null)), [
            reference('print').call([
              literal('Peek:') + reference('result').invoke('toString', [])
            ]),
            elseThen([
              reference('print').call([literal('Peek: null')])
            ])
          ]),
          ifThen(reference('current').notEquals(literal(null)), [
            reference('print').call([
              literal('Current:') + reference('current').invoke('toString', [])
            ]),
            elseThen([
              reference('print').call([literal('Current: null')])
            ])
          ]),
          reference('result').asReturn()
        ])
        ..addAnnotation(reference('override'));

      next
        ..addPositional(parameter('type', [new TypeBuilder('String')]))
        ..addStatements([
          varField('result',
              value: superRef.invoke('next', [reference('type')])),
          reference('print').call([
            literal('Next is <') +
                reference('type') +
                literal('>? ') +
                reference('result').invoke('toString', [])
          ]),
          reference('result').asReturn()
        ])
        ..addAnnotation(reference('override'));

      clazz..addMethod(peek)..addMethod(next);
    }

    clazz.addConstructor(c);

    ctx.ruleNames.forEach((key, rhs) {
      if (!isTerminal(rhs)) {
        // TODO: Method stubs
        // TODO: If there are any errors, dump them
        clazz.addMethod(compileMethod(key, rhs, ctx));
      }
    });

    return clazz;
  }

  MethodBuilder compileMethod(
      String key, RightHandSideContext rhs, GeneratorContext ctx) {
    Map<String, int> fields = {};
    backus.AstBuilder.countReferences(rhs, fields, ctx);

    var rc = new ReCase(key);
    var type = new TypeBuilder('${rc.pascalCase}Context');
    var m = new MethodBuilder('parse${rc.pascalCase}', returnType: type);
    m.addStatement(varField('ctx', value: type.newInstance([])));
    /*m.addStatement(varField('tokens',
        value: new TypeBuilder('List', genericTypes: [TYPE_TOKEN_LIST])));*/
    m.addStatement(varField('tokens', value: list([]), type: TYPE_TOKEN_LIST));
    var blocks = compileInto(rhs, m, fields, ctx);

    for (var block in blocks) {
      block.addStatement(reference('ctx')
          .property('tokens')
          .invoke('addAll', [reference('tokens')]));
      block.addStatement(safe(reference('ctx')).asReturn());
    }

    return m;
  }

  ExpressionBuilder safe(ExpressionBuilder expr) {
    return reference('safe').call([
      expr,
      importIO == true
          ? reference('stderr').property('writeln')
          : reference('print')
    ]);
  }

  String toError(RightHandSideContext rhs, GeneratorContext ctx) {
    if (rhs is TerminalContext)
      return rhs.text;
    else if (rhs is RegularExpressionContext)
      return 'a match for regex /${rhs.pattern}/';
    else if (rhs is IdentifierContext) {
      var resolved = ctx.ruleNames[rhs.name];

      if (resolved == null) {
        throw new UnsupportedError('Unknown rule reference "${rhs.name}".');
      } else if (isTerminal(resolved)) {
        return toError(resolved, ctx);
      } else
        return new ReCase(rhs.name).camelCase;
    } else if (rhs is AlternationContext)
      return '${toError(rhs.left, ctx)} or ${toError(rhs.right, ctx)}';
    else
      throw new UnsupportedError(
          'Cannot represent ${rhs.runtimeType} as error Strings yet...');
  }

  ExpressionBuilder compileCondition(ReCase rc, HasStatements block,
      RightHandSideContext rhs, GeneratorContext ctx) {
    if (rhs is TerminalContext || rhs is RegularExpressionContext)
      return reference('next')
          .call([new TypeBuilder('TokenType').property(rc.constantCase)]).or(
              reference('current').notEquals(literal(null)).and(
                  reference('current').property('type').equals(
                      new TypeBuilder('TokenType').property(rc.constantCase))));
    else if (rhs is IdentifierContext) {
      var resolved = ctx.ruleNames[rhs.name];

      if (resolved == null) {
        throw new UnsupportedError('Unknown rule reference "${rhs.name}".');
      } else if (isTerminal(resolved)) {
        return compileCondition(
            rc ?? new ReCase(rhs.name), block, resolved, ctx);
      } else {
        print(
            'Warning: Should never call compileCondition on IdentifierContext: ${rhs
                .name}');
        var r = rc ?? new ReCase(rhs.name);
        var name = ctx.variable(r.camelCase);
        block.addStatement(
            varField(name, value: reference('parse${r.pascalCase}').call([])));
        return reference(name).notEquals(literal(null));
      }
    } else
      throw new UnsupportedError(
          'Cannot compile ${rhs.runtimeType} conditions yet...');
  }

  Iterable<HasStatements> compileInto(RightHandSideContext rhs,
      HasStatements block, Map<String, int> fields, GeneratorContext ctx,
      [bool redoIf = true]) {
    if (rhs is TerminalContext || rhs is RegularExpressionContext)
      return compileLiteral(rhs, block, fields, ctx);
    else if (rhs is IdentifierContext)
      return compileIdentifier(rhs, block, fields, ctx, redoIf != false);
    else if (rhs is ConcatenationContext)
      return compileConcatenation(rhs, block, fields, ctx);
    else if (rhs is AlternationContext)
      return compileAlternation(rhs, block, fields, ctx);
    else
      throw new UnsupportedError(
          'Cannot compile ${rhs.runtimeType} parsers yet...');
  }

  Iterable<HasStatements> compileLiteral(RightHandSideContext rhs,
      HasStatements block, Map<String, int> fields, GeneratorContext ctx) {
    if (!ctx.ruleNames.containsValue(rhs)) {
      throw new UnsupportedError(
          'Cannot compile rule without associated name: $rhs');
    }

    for (var key in ctx.ruleNames.keys) {
      if (ctx.ruleNames[key] == rhs) {
        var rc = new ReCase(key);
        var condition = compileCondition(rc, block, rhs, ctx);
        var stmt = ifThen(condition, [
          reference('tokens').invoke('add', [reference('current')]),
          elseThen([
            reference('errors').invoke('add', [
              reference('error').call([literal('Expected ${rc.constantCase}')])
            ]),
            safe(literal(null)).asReturn()
          ])
        ]);
        block.addStatement(stmt);
        return [stmt];
      }
    }

    return null;
  }

  Iterable<HasStatements> compileIdentifier(IdentifierContext id,
      HasStatements block, Map<String, int> fields, GeneratorContext ctx,
      [bool redoIf = true]) {
    if (!ctx.ruleNames.containsKey(id.name))
      throw new UnsupportedError('Unknown rule reference "${id.name}".');

    var rhs = ctx.ruleNames[id.name];

    if (isTerminal(rhs)) {
      return compileLiteral(rhs, block, fields, ctx);
    }

    var rc = new ReCase(id.name);
    String name;

    if (redoIf == false) {
      var old = ctx.currentVariable(rc.camelCase);
      block.addStatement(
          varField(name = ctx.variable(rc.camelCase), value: reference(old)));
    } else {
      name = ctx.variable(rc.camelCase);
      block.addStatement(
          varField(name, value: reference('parse${rc.pascalCase}').call([])));
    }

    StatementBuilder adder;
    var count = fields[id.name];

    if (count == null) {
      throw new UnsupportedError('Unknown rule reference "${id.name}".');
    } else if (count <= 0) {
      throw new UnsupportedError(
          'Cannot reference rule "${id.name}" - it was not listed in the rule declaration.');
    } else if (count == 1) {
      adder = reference(name).asAssign(reference('ctx').property(rc.camelCase));
    } else {
      adder = reference('ctx')
          .property(pluralize(rc.camelCase))
          .invoke('add', [reference(name)]);
    }

    var stmt = ifThen(reference(name).notEquals(literal(null)), [
      reference('tokens')
          .invoke('addAll', [reference(name).property('tokens')]),
      adder,
      elseThen([
        reference('errors').invoke('add', [
          reference('error').call([literal('Expected ${rc.camelCase}')])
        ]),
        safe(literal(null)).asReturn()
      ])
    ]);

    block.addStatement(stmt);
    return [stmt];
  }

  Iterable<HasStatements> compileConcatenation(ConcatenationContext rhs,
      HasStatements block, Map<String, int> fields, GeneratorContext ctx) {
    List<HasStatements> stmts = [];

    var left = compileInto(rhs.left, block, fields, ctx);

    for (var l in left) {
      stmts.addAll(compileInto(rhs.right, l, fields, ctx));
    }

    return stmts;
  }

  Iterable<HasStatements> compileAlternation(AlternationContext rhs,
      HasStatements block, Map<String, int> fields, GeneratorContext ctx) {
    List<HasStatements> stmts = [];

    var alt = ifThen(compileCondition(null, block, rhs.right, ctx));
    stmts.addAll(compileInto(rhs.right, alt, fields, ctx));

    var main = ifThen(compileCondition(null, block, rhs.left, ctx), [
      elseIf(alt),
      elseThen([
        reference('errors').invoke('add', [
          reference('error')
              .call([literal('Expected ') + literal(toError(rhs, ctx))])
        ]),
        safe(literal(null)).asReturn()
      ])
    ]);

    stmts.addAll(compileInto(rhs.left, main, fields, ctx, false));
    stmts.add(main);
    block.addStatement(main);
    return stmts;
  }
}
