import 'package:backus/src/text/text.dart';
import 'package:test/test.dart';

Matcher idEquals(String name) => predicate((String str) {
      print('Parsing: `$str`');
      var parser = new Parser(lex(str));
      var id = parser.parseIdentifier();
      print('Parsed ID: $id, name: ${id?.name}');
      return id?.name == name;
    }, 'ID with name \'$name\'');

main() {
  group('identifier', () {
    test('simple', () {
      expect('foo; (* comment *)', idEquals('foo'));
    });
  });
}
