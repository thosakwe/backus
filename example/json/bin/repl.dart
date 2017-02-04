import 'dart:convert';
import 'dart:io';
import 'package:backus_json/backus_json.dart';

main() {
  stdout.write('Enter text to lex it:');

  stdin
      .transform(UTF8.decoder)
      .map((str) => str.trim())
      .map(lex)
      .listen((tokens) {
    print('Lexed ${tokens.length} token(s)');
    tokens.forEach(print);

    stdout.write('\nEnter text to lex it:');
  });
}
