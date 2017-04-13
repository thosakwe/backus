import 'package:backus/src/text/text.dart';
import 'package:test/test.dart';

Matcher idEquals(String name) => predicate((String str) {
      var scanner = new Scanner()..scan(str);
      print('Parsing: `$str`');
      var parser = new Parser(scanner.tokens);
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
