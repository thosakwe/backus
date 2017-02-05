import 'dart:convert';
import 'dart:io';
import 'package:backus_json/backus_json.dart';

main() {
  stdout.write('Enter text to lex it:');

  var stream = stdin
      .transform(UTF8.decoder)
      .map((str) => str.trim())
      .map(lex)
      .asBroadcastStream();

  stream
    ..listen((tokens) {
      var parser = new JsonParser(tokens);
      var arrow = parser.parseArrow();
      if (arrow == null)
        print('No arrow found.');
      else
        print('Found arrow with text `${arrow.sourceText}`');
    })
    ..listen((tokens) {
      print('Lexed ${tokens.length} token(s)');
      tokens.forEach(print);

      stdout.write('\nEnter text to lex it:');
    });
}
