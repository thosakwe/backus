import 'package:compiler_tools/compiler_tools.dart';
import 'ast/ast.dart';
import '../util.dart' as util;
import 'token_type.dart';

typedef RightHandSideContext PrefixParselet(
    Parser parser, Token<TokenType> token);

typedef RightHandSideContext InfixParselet(
    Parser parser, RightHandSideContext left, Token token);

class Parser extends BaseParser<TokenType> {
  final List<SyntaxError> errors = [];
  final Map<TokenType, PrefixParselet> prefixParselets = {};
  final Map<TokenType, InfixParselet> infixParselets = {};

  Parser(List<Token<TokenType>> tokens) : super(tokens) {
    // Prefix
    prefixParselets[TokenType.ID] = (parser, token) => parser.parseIdentifier();
    prefixParselets[TokenType.REGEX] =
        (parser, token) => parser.parseRegularExpression();
    prefixParselets[TokenType.TERMINAL] =
        (parser, token) => parser.parseTerminal();
    prefixParselets[TokenType.CURLY_L] =
        (parser, token) => parser.parseRepetition();
    prefixParselets[TokenType.PAREN_L] = (parser, token) => parser.parseGroup();
    prefixParselets[TokenType.SQUARE_L] =
        (parser, token) => parser.parseOptional();

    // Infix
    infixParselets[TokenType.PIPE] = (parser, left, token) {
      var right = parseRightHandSide();

      if (right == null) {
        errors.add(new SyntaxError(
            'Expected right-hand-side within alternation, found \'${current
                ?.text}\' instead.',
            offendingToken: current));
        return null;
      }

      return new AlternationContext(left, right);
    };

    infixParselets[TokenType.COMMA] = (parser, left, token) {
      var right = parseRightHandSide();

      if (right == null) {
        errors.add(new SyntaxError(
            'Expected right-hand-side within concatenation, found \'${current
                ?.text}\' instead.',
            offendingToken: current));
        return null;
      }

      return new ConcatenationContext(left, right);
    };
  }

  void eatComments() {
    if (current == null && !eof()) read();

    if (current?.type == TokenType.COMMENT) {
      while (!eof() && current?.type == TokenType.COMMENT) {
        read();
      }
    } else {
      try {
        while (peek()?.type == TokenType.COMMENT) read();
      } catch (e) {}
    }
  }

  @override
  SyntaxError expectedType(TokenType type) {
    return error('Expected $type, \'${peek()?.text ?? "nothing"}\' found.');
  }

  GrammarContext parseGrammar() {
    final List<RuleContext> rules = [];
    eatComments();
    RuleContext rule = parseRule();

    while (rule != null) {
      rules.add(rule);
      rule = parseRule();
    }

    if (rules.isEmpty) {
      errors.add(new SyntaxError('Grammars must have at least one rule.',
          offendingToken: current));
      return null;
    }

    return new GrammarContext(rules);
  }

  RuleContext parseRule() {
    var left = parseLeftHandSide();
    eatComments();
    if (left == null) return null;

    if (!next(TokenType.EQUALS)) {
      errors.add(expectedType(TokenType.EQUALS));
      return null;
    }

    var right = parseRightHandSide();

    if (right == null) {
      errors.add(new SyntaxError(
          'Expected right-hand side, found \'${current?.text}\' instead.',
          offendingToken: current));
      return null;
    }

    /* print('Current in RHS: ${current?.type} -> ${current?.text}');
    print('Next: ${peek()?.type} -> ${peek()?.text}'); */

    if (!next(TokenType.SEMI)) {
      errors.add(expectedType(TokenType.SEMI));
      return null;
    }

    return new RuleContext(left, right);
  }

  LeftHandSideContext parseLeftHandSide() {
    var name = parseIdentifier();
    eatComments();
    return name == null ? null : new LeftHandSideContext(name);
  }

  RightHandSideContext parseRightHandSide() {
    var token = peek();
    var prefix = prefixParselets[token.type];

    if (prefix == null) {
      errors.add(error('Could not parse \'${token.text}\'.'));
      return null;
    }

    RightHandSideContext left = prefix(this, token);
    eatComments();

    try {
      token = peek();
      var infix = infixParselets[token.type];

      if (infix == null)
        return left;
      else {
        read();
        eatComments();
        var result = infix(this, left, token);
        eatComments();
        // print('Infix created $result');
        return result;
      }
    } catch (e) {
      eatComments();
      if (e is RangeError)
        return left;
      else
        rethrow;
    }
  }

  OptionalContext parseOptional() {
    if (!next(TokenType.SQUARE_L)) return null;
    var context = parseRightHandSide();
    eatComments();

    if (context == null) {
      errors.add(new SyntaxError(
          'Expected right-hand-side within optional, found \'${current
              ?.text}\' instead.',
          offendingToken: current));
      return null;
    }

    if (!next(TokenType.SQUARE_R)) {
      errors.add(expectedType(TokenType.SQUARE_R));
      return null;
    }

    eatComments();
    return new OptionalContext(context);
  }

  RepetitionContext parseRepetition() {
    if (!next(TokenType.CURLY_L)) return null;
    var context = parseRightHandSide();
    eatComments();

    if (context == null) {
      errors.add(new SyntaxError(
          'Expected right-hand-side within repetition, found \'${current?.text}\' instead.',
          offendingToken: current));
      return null;
    }

    if (!next(TokenType.CURLY_R)) {
      errors.add(expectedType(TokenType.CURLY_R));
      return null;
    }

    eatComments();
    return new RepetitionContext(context);
  }

  GroupContext parseGroup() {
    if (!next(TokenType.PAREN_L)) return null;
    var context = parseRightHandSide();
    eatComments();

    if (context == null) {
      errors.add(new SyntaxError(
          'Expected right-hand-side within group, found \'${current
              ?.text}\' instead.',
          offendingToken: current));
      return null;
    }

    if (!next(TokenType.PAREN_R)) {
      errors.add(expectedType(TokenType.PAREN_R));
      return null;
    }

    eatComments();
    return new GroupContext(context);
  }

  AlternationContext parseAlternation() {
    var left = parseRightHandSide();
    eatComments();
    if (left == null) return null;
    if (!next(TokenType.PIPE)) return null;
    var right = parseRightHandSide();
    eatComments();

    if (right == null) {
      errors.add(new SyntaxError(
          'Expected right-hand-side within alternation, found \'${current?.text}\' instead.',
          offendingToken: current));
      return null;
    }

    eatComments();
    return new AlternationContext(left, right);
  }

  ConcatenationContext parseConcatenation() {
    var left = parseRightHandSide();
    eatComments();
    if (left == null) return null;
    if (!next(TokenType.COMMA)) return null;
    var right = parseRightHandSide();
    eatComments();

    if (right == null) {
      errors.add(new SyntaxError(
          'Expected right-hand-side within concatenation, found \'${current?.text}\' instead.',
          offendingToken: current));
      return null;
    }

    eatComments();
    return new ConcatenationContext(left, right);
  }

  RegularExpressionContext parseRegularExpression() {
    if (!next(TokenType.REGEX) && current?.type != TokenType.TERMINAL) return null;
    var expr = new RegularExpressionContext(util.getRegexPattern(current.text));
    eatComments();
    return expr;
  }

  TerminalContext parseTerminal() {
    if (!next(TokenType.TERMINAL) && current?.type != TokenType.REGEX) return null;
    var expr = new TerminalContext(util.getTerminalText(current.text));
    eatComments();
    return expr;
  }

  IdentifierContext parseIdentifier() {
    if (!next(TokenType.ID) && current?.type != TokenType.ID) return null;
    var expr = new IdentifierContext(current.text);
    eatComments();
    return expr;
  }
}
