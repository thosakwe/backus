import 'package:code_builder/dart/core.dart';
import 'package:code_builder/code_builder.dart';
import 'package:inflection/inflection.dart';
import 'package:recase/recase.dart';
import '../text/text.dart';
import 'grammar.dart';

LibraryBuilder generateAstLibrary(Grammar grammar) {
  var lib = new LibraryBuilder('${grammar.name.snakeCase}.ast.g.dart');
  lib.addDirective(new ImportBuilder('package:backus/backus.dart'));
  grammar.rules.forEach((name, rhs) {
    if (!grammar.isTerminal(rhs))
      lib.addMember(generateAstClass(name, rhs, grammar));
  });
  return lib;
}

ClassBuilder generateAstClass(
    String name, RightHandSideContext rhs, Grammar grammar) {
  var rc = new ReCase(name);
  var clazz = new ClassBuilder('${rc.pascalCase}Context',
      asExtends: new TypeBuilder('AstNode'));
  var ast = grammar.getRuleAst(name, rhs);

  for (var field in ast.fields) {
    var childType =
        new TypeBuilder(new ReCase(field.name).pascalCase + 'Context');
    if (field.isList) {
      clazz.addField(varFinal(field.fieldName,
          type: new TypeBuilder('List', genericTypes: [childType]),
          value: list([])));
    } else {
      clazz.addField(varField(field.fieldName, type: childType));
    }
  }

  clazz.addConstructor(new ConstructorBuilder(invokeSuper: [reference('text')])
    ..addPositional(parameter('text', [lib$core.String])));
  return clazz;
}
