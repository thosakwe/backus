import 'dart:io';
import 'package:backus/src/gen/build_grammar.dart';
import 'package:test/test.dart';

main() {
  test('json', () async {
    var file = new File('test/grammars/json.ebnf');
    var grammar = await buildGrammar(await file.readAsString(), file.uri);
    print(grammar.rules);
  });
}
