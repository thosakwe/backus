import 'dart:async';
import 'dart:io';
import 'package:compiler_tools/compiler_tools.dart';
import 'package:path/path.dart' as p;
import 'package:recase/recase.dart';
import 'compilers/compilers.dart';
import '../text/text.dart';
import 'grammar.dart';

void friendlyPrintError(SyntaxError error, String filePath) {
  if (error.offendingToken == null) {
    stderr.writeln('Syntax error in "$filePath": ${error.cause}');
  } else {
    var span = error.offendingToken.span;
    stderr.writeln(
        'Syntax error in "$filePath" at line ${span.start.line}, column ${span.start.column}: ${error.cause}');
    stderr.writeln(span.message(error.cause, color: true));
    stderr.writeln(span.highlight());
  }
}

Future<Grammar> buildGrammar(String contents, Uri sourceUrl) async {
  var name = new ReCase(p.basenameWithoutExtension(sourceUrl.path));
  var grammar = new Grammar(name);
  var scanner = new Scanner()..scan(contents, sourceUrl: sourceUrl);

  if (scanner.errors.isNotEmpty) {
    var filePath = sourceUrl.toFilePath();
    scanner.errors.forEach((error) => friendlyPrintError(error, filePath));
    throw 'Grammar parsing completed with ${scanner.errors.length} syntax error(s).';
  }

  var parser = new Parser(scanner.tokens);
  var grammarContext = parser.parseGrammar();

  if (parser.errors.isNotEmpty) {
    var filePath = sourceUrl.toFilePath();
    parser.errors.forEach((error) => friendlyPrintError(error, filePath));
    throw 'Grammar parsing completed with ${parser.errors.length} syntax error(s).';
  }

  for (var rule in grammarContext.rules) {
    var name = rule.left.name.name;
    grammar.rules[name] = rule.right;
  }

  grammar.rules.forEach((name, rhs) {
    if (grammar.isTerminal(rhs))
      grammar.tokenType(name);
  });

  return grammar;
}