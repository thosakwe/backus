import 'dart:async';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'build_grammar.dart';
import 'ast.dart';
import 'master.dart';
import 'parser.dart';
import 'token_type.dart';

class BackusBuilder implements Builder {
  const BackusBuilder();

  @override
  Map<String, List<String>> get buildExtensions => {
        '.ebnf': [
          '.ast.g.dart',
          '.backus.g.dart',
          '.parser.g.dart',
          '.tokens.g.dart'
        ]
      };

  @override
  Future build(BuildStep buildStep) async {
    var grammar = await buildGrammar(
        await buildStep.readAsString(buildStep.inputId), buildStep.inputId.uri);
    Map<String, LibraryBuilder> libraries = {
      '.ast.g.dart': generateAstLibrary(grammar),
      '.backus.g.dart': generateMasterLibrary(grammar),
      '.parser.g.dart': generateParserLibrary(grammar),
      '.tokens.g.dart': generateTokenTypeLibrary(grammar),
    };

    await Future.wait(libraries.keys.map((k) {
      return buildStep.writeAsString(buildStep.inputId.changeExtension(k),
          prettyToSource(libraries[k].buildAst()));
    }));
  }
}
