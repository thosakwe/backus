import 'package:code_builder/dart/core.dart';
import 'package:code_builder/code_builder.dart';
import 'grammar.dart';

LibraryBuilder generateTokenTypeLibrary(Grammar grammar) {
  var lib = new LibraryBuilder('${grammar.name.snakeCase}.tokens.g.dart');
  var clazz = new ClassBuilder('TokenType', asAbstract: true);

  grammar.rules.forEach((name, _) {
    if (grammar.hasTokenType(name)) {
      clazz.addField(
          varConst(grammar.tokenType(name),
              type: lib$core.String, value: literal(name)),
          asStatic: true);
    }
  });

  return lib..addMember(clazz);
}
