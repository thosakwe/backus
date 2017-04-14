import 'dart:io';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:path/path.dart' as p;
import 'package:recase/recase.dart';
import '../text/ast/ast.dart';
import '../text/parser.dart';
import '../text/scanner.dart';
export '../text/ast/ast.dart';

ReCase getLibraryName(AssetId inputId) {
  var name = p.basenameWithoutExtension(inputId.path);
  return new ReCase(name);
}

bool isTerminal(RightHandSideContext rhs) {
  if (rhs is TerminalContext)
    return true;
  else if (rhs is RegularExpressionContext)
    return true;
  else if (rhs is RepetitionContext)
    return isTerminal(rhs.context);
  else if (rhs is OptionalContext)
    return isTerminal(rhs.context);
  else if (rhs is GroupContext)
    return isTerminal(rhs.context);
  else if (rhs is ConcatenationContext)
    return isTerminal(rhs.left) && isTerminal(rhs.right);
  else if (rhs is AlternationContext)
    return isTerminal(rhs.left) && isTerminal(rhs.right);
  else
    return false;
}

ExpressionBuilder terminalToExpression(RightHandSideContext rhs) {
  if (rhs is TerminalContext)
    return literal(rhs.stringValue);
  else if (rhs is RegularExpressionContext)
    return new TypeBuilder('RegExp').newInstance([literal(rhs.pattern)]);
  else
    throw new UnsupportedError('Unsupported terminal: $rhs');
}

GrammarContext parseGrammar(String text, sourceUrl) {
  var scanner = new Scanner()..scan(text, sourceUrl: sourceUrl);

  if (scanner.errors.isNotEmpty) {
    stderr.writeln(
        'Compilation of "$sourceUrl" failed. ${scanner.errors.length} syntax error(s) found:');

    for (var error in scanner.errors) {
      stderr.writeln('  * $error');
    }

    throw new StateError('Scanning of the provided grammar failed.');
  }

  var parser = new Parser(scanner.tokens);
  var grammar = parser.parseGrammar();

  if (parser.errors.isNotEmpty) {
    stderr.writeln(
        'Compilation of "$sourceUrl" failed. ${parser.errors.length} syntax error(s) found:');

    for (var error in parser.errors) {
      stderr.writeln('  * $error');
    }

    throw new StateError('Parsing of the provided grammar failed.');
  }

  return grammar;
}

class GeneratorContext {
  final Map<String, int> _variables = {};
  final Map<String, RightHandSideContext> ruleNames = {};

  GeneratorContext._();

  static GeneratorContext process(GrammarContext grammar) {
    var ctx = new GeneratorContext._();
    ctx._populateRuleNames(grammar);
    return ctx;
  }

  String variable(String root) {
    int n;

    if (_variables.containsKey(root))
      n = ++_variables[root];
    else
      n = _variables[root] = 0;

    return '_$root$n';
  }

  void _populateRuleNames(GrammarContext grammar) {
    for (var rule in grammar.rules) {
      var name = rule.left.name.name;
      ruleNames[name] = rule.right;
    }
  }

  String currentVariable(String root) {
    int n;

    if (_variables.containsKey(root))
      n = _variables[root];
    else
      n = _variables[root] = 0;

    return '_$root$n';
  }
}
