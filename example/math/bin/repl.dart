import 'dart:convert';
import 'dart:io';
import 'package:backus_math/text/math.language.g.dart';

const Calculator CALC = const Calculator();

const String PROMPT = 'Enter an equation to solve it: ';

main() {
  stdout.write(PROMPT);
  stdin.transform(UTF8.decoder).transform(const LineSplitter()).listen((line) {
    var scanner = new MathScanner()..scan(line);
    var parser = new MathParser(scanner.tokens);
    var expr = parser.parseExpr();

    if (expr == null) {
      throw new StateError('Invalid math expression given.');
    } else {
      var result = CALC.visitExpr(expr);

      if (result == null)
        throw new StateError('Invalid math expression given.');

      print('Result: $result');
      stdout.write(PROMPT);
    }
  });
}

class Calculator implements MathVisitor {
  const Calculator();

  @override
  num visitExpr(ExprContext ctx) {
    if (ctx.sum != null)
      return visitSum(ctx.sum);
    else
      return num.parse(ctx.sourceText);
  }

  @override
  num visitSum(SumContext ctx) {
    var left = num.parse(ctx.tokens[0].text),
        right = num.parse(ctx.tokens[2].text);
    return left + right;
  }
}
