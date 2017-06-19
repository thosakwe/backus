import 'dart:io';
import 'package:test/test.dart';
import 'grammars/env.backus.g.dart';

main() {
  test('key', () {
    var p = new EnvParser('foo');
    var tok = p.parseKey();
    expect(tok, isNotNull);
    expect(tok.span.text, 'foo');
  });
}