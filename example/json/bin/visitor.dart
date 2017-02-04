import 'package:backus_json/backus_json.dart';

const String TEXT = '''
{ thirteen: 13, four: 2 }
''';

main() {
  print(lex(TEXT.trim()));
  var expr = new JsonParser(lex(TEXT)).parseExpr();
  new MyVisitor().visitExpr(expr);
}

class MyVisitor extends BaseJsonVisitor<String> {
  @override
  visitExpr(ExprContext ctx) {
    print('Expr: ' + (ctx?.digit?.span?.text).toString());
  }
}