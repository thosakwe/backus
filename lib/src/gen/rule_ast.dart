import 'package:inflection/inflection.dart';
import 'package:recase/recase.dart';

class RuleAst {
  final List<RuleAstField> fields = [];
}

class RuleAstField {
  final String name;
  final bool isList;
  String _fieldName;
  RuleAstField(this.name, {this.isList: false});

  String get fieldName {
    if (_fieldName != null)
      return _fieldName;
    else if (!isList)
      return _fieldName = new ReCase(name).camelCase;
    else {
      var rc = new ReCase(name);
      return _fieldName = pluralize(rc.camelCase);
    }
  }
}
