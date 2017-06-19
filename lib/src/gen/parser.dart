import 'package:backus/src/text/ast/right_hand_side.dart';
import 'package:code_builder/dart/core.dart';
import 'package:code_builder/code_builder.dart';
import 'package:recase/recase.dart';
import '../text/text.dart';
import 'grammar.dart';

LibraryBuilder generateParserLibrary(Grammar grammar) {
  var lib = new LibraryBuilder('${grammar.name.snakeCase}.parser.g.dart');
  lib.addDirective(new ImportBuilder('package:backus/backus.dart'));
  lib.addDirective(new ImportBuilder('${grammar.name.snakeCase}.ast.g.dart'));
  lib.addDirective(
      new ImportBuilder('${grammar.name.snakeCase}.tokens.g.dart'));

  var clazz = new ClassBuilder('${grammar.name.pascalCase}Parser',
      asExtends: new TypeBuilder('Parser', genericTypes: [lib$core.String]));

  // Add constructor
  clazz.addConstructor(new ConstructorBuilder(
      invokeSuper: [reference('text'), reference('sourceUrl')])
    ..addPositional(parameter('text', [lib$core.String]))
    ..addPositional(parameter('sourceUrl').asOptional()));

  List<String> terminalNames = [];

  // Add parseX() for any terminal
  grammar.rules.forEach((name, rhs) {
    if (grammar.hasTokenType(name)) {
      var rc = new ReCase(name);
      terminalNames.add('parse${rc.pascalCase}');
      clazz.addMethod(generateTerminalParserMethod(name, rhs, clazz, grammar));
    }
  });

  // Add `nextToken`
  clazz.addMethod(generateNextTokenMethod(terminalNames));

  // Add parseX() for any non-terminal
  grammar.rules.forEach((name, rhs) {
    if (!grammar.hasTokenType(name)) {
      clazz.addMethod(
          generateNonTerminalParserMethod(name, rhs, clazz, grammar));
    }
  });

  // TODO: parseAny()

  return lib..addMember(clazz);
}

MethodBuilder generateTerminalParserMethod(String name,
    RightHandSideContext rhs, ClassBuilder clazz, Grammar grammar) {
  var tokenType = new TypeBuilder('Token', genericTypes: [lib$core.String]);
  var rc = new ReCase(name);
  var method =
      new MethodBuilder('parse${rc.pascalCase}', returnType: tokenType);
  var rgxName = '_rgx${grammar.tokenType(name)}';
  clazz.addField(
      varFinal(rgxName,
          type: lib$core.RegExp,
          value: lib$core.RegExp
              .newInstance([literal(generateRegexPattern(rhs, grammar))])),
      asStatic: true);
  method.addStatement(
      ifThen(reference('scanner').invoke('scan', [reference(rgxName)]), [
    tokenType.newInstance([
      reference('TokenType').property(grammar.tokenType(name)),
      reference('scanner').property('lastSpan')
    ]).asReturn(),
    elseThen([literal(null).asReturn()])
  ]));
  return method;
}

String generateRegexPattern(RightHandSideContext rhs, Grammar grammar) {
  if (rhs is GroupContext) {
    var inner = generateRegexPattern(rhs.context, grammar);
    return '($inner)';
  } else if (rhs is RepetitionContext) {
    var inner = generateRegexPattern(rhs.context, grammar);
    return '($inner)+';
  } else if (rhs is OptionalContext) {
    var inner = generateRegexPattern(rhs.context, grammar);
    return '($inner)?';
  } else if (rhs is ConcatenationContext) {
    var left = generateRegexPattern(rhs.left, grammar);
    var right = generateRegexPattern(rhs.right, grammar);
    return '($left)($right)';
  } else if (rhs is AlternationContext) {
    var left = generateRegexPattern(rhs.left, grammar);
    var right = generateRegexPattern(rhs.right, grammar);
    return '(($left)|($right))';
  } else if (rhs is RegularExpressionContext) {
    return rhs.pattern;
  } else if (rhs is TerminalContext) {
    return rhs.text;
  } else if (rhs is IdentifierContext) {
    return generateRegexPattern(grammar.resolveReference(rhs.name), grammar);
  } else
    throw new UnsupportedError('Cannot compile to Regex: $rhs');
}

MethodBuilder generateNextTokenMethod(List<String> terminalNames) {
  var method = new MethodBuilder('nextToken',
      returnType: new TypeBuilder('Token', genericTypes: [lib$core.String]));
  method.addAnnotation(lib$core.override);
  method.addStatement(varField('tok',
      type: new TypeBuilder('Token', genericTypes: [lib$core.String])));
  var tok = reference('tok');

  for (var name in terminalNames) {
    method.addStatement(reference(name).call([]).asAssign(tok));
    method.addStatement(ifThen(tok.notEquals(literal(null)), [tok.asReturn()]));
  }

  method.addStatement(literal(null).asReturn());
  return method;
}

MethodBuilder generateNonTerminalParserMethod(String name,
    RightHandSideContext rhs, ClassBuilder clazz, Grammar grammar) {
  // TODO: AST...
  var rc = new ReCase(name);
  var method = new MethodBuilder('parse${rc.pascalCase}');
  // TODO: Compile...
  return method;
}
