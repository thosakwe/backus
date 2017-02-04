import 'package:compiler_tools/compiler_tools.dart';
import 'ast/ast.dart';
import '../util.dart' as util;
import 'token_type.dart';

typedef RightHandSideContext PrefixParselet(
    Parser parser, Token<TokenType> token);

typedef RightHandSideContext InfixParselet(
    Parser parser, RightHandSideContext left, Token token);

class Parser extends BaseParser<TokenType> {
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

      if (right == null)
        throw new SyntaxError(
            'Expected right-hand-side within alternation, found \'${current?.text}\' instead.',
            offendingToken: current);

      return new AlternationContext(left, right);
    };

    infixParselets[TokenType.COMMA] = (parser, left, token) {
      var right = parseRightHandSide();

      if (right == null)
        throw new SyntaxError(
            'Expected right-hand-side within concatenation, found \'${current?.text}\' instead.',
            offendingToken: current);

      return new ConcatenationContext(left, right);
    };
  }

  @override
  SyntaxError expectedType(TokenType type) {
    return error('Expected $type, \'${peek()?.text ?? "nothing"}\' found.');
  }

  GrammarContext parseGrammar() {
    final List<RuleContext> rules = [];
    RuleContext rule = parseRule();

    while (rule != null) {
      rules.add(rule);
      rule = parseRule();
    }

    if (rules.isEmpty)
      throw new SyntaxError('Grammars must have at least one rule.',
          offendingToken: current);

    return new GrammarContext(rules);
  }

  RuleContext parseRule() {
    var left = parseLeftHandSide();
    if (left == null) return null;

    if (!next(TokenType.EQUALS)) throw expectedType(TokenType.EQUALS);

    var right = parseRightHandSide();

    if (right == null)
      throw new SyntaxError(
          'Expected right-hand side, found \'${current?.text}\' instead.',
          offendingToken: current);

    /* print('Current in RHS: ${current?.type} -> ${current?.text}');
    print('Next: ${peek()?.type} -> ${peek()?.text}'); */

    if (!next(TokenType.SEMI)) throw expectedType(TokenType.SEMI);
    return new RuleContext(left, right);
  }

  LeftHandSideContext parseLeftHandSide() {
    var name = parseIdentifier();
    return name == null ? null : new LeftHandSideContext(name);
  }

  RightHandSideContext parseRightHandSide() {
    var token = peek();
    var prefix = prefixParselets[token.type];

    if (prefix == null) throw error('Could not parse \'${token.text}\'.');

    RightHandSideContext left = prefix(this, token);

    try {
      token = peek();
      var infix = infixParselets[token.type];

      if (infix == null)
        return left;
      else {
        read();
        var result = infix(this, left, token);
        // print('Infix created $result');
        return result;
      }
    } catch (e) {
      if (e is RangeError)
        return left;
      else
        rethrow;
    }
  }

  OptionalContext parseOptional() {
    if (!next(TokenType.SQUARE_L)) return null;
    var context = parseRightHandSide();

    if (context == null)
      throw new SyntaxError(
          'Expected right-hand-side within optional, found \'${current?.text}\' instead.',
          offendingToken: current);

    if (!next(TokenType.SQUARE_R)) throw expectedType(TokenType.SQUARE_R);
    return new OptionalContext(context);
  }

  RepetitionContext parseRepetition() {
    if (!next(TokenType.CURLY_L)) return null;
    var context = parseRightHandSide();

    if (context == null)
      throw new SyntaxError(
          'Expected right-hand-side within repetition, found \'${current?.text}\' instead.',
          offendingToken: current);

    if (!next(TokenType.CURLY_R)) throw expectedType(TokenType.CURLY_R);
    return new RepetitionContext(context);
  }

  GroupContext parseGroup() {
    if (!next(TokenType.PAREN_L)) return null;
    var context = parseRightHandSide();

    if (context == null)
      throw new SyntaxError(
          'Expected right-hand-side within group, found \'${current?.text}\' instead.',
          offendingToken: current);

    if (!next(TokenType.PAREN_R)) throw expectedType(TokenType.PAREN_R);
    return new GroupContext(context);
  }

  AlternationContext parseAlternation() {
    var left = parseRightHandSide();
    if (left == null) return null;
    if (!next(TokenType.PIPE)) return null;
    var right = parseRightHandSide();

    if (right == null)
      throw new SyntaxError(
          'Expected right-hand-side within alternation, found \'${current?.text}\' instead.',
          offendingToken: current);

    return new AlternationContext(left, right);
  }

  ConcatenationContext parseConcatenation() {
    var left = parseRightHandSide();
    if (left == null) return null;
    if (!next(TokenType.COMMA)) return null;
    var right = parseRightHandSide();

    if (right == null)
      throw new SyntaxError(
          'Expected right-hand-side within concatenation, found \'${current?.text}\' instead.',
          offendingToken: current);

    return new ConcatenationContext(left, right);
  }

  RegularExpressionContext parseRegularExpression() {
    if (!next(TokenType.REGEX)) return null;
    return new RegularExpressionContext(util.getRegexPattern(current.text));
  }

  TerminalContext parseTerminal() {
    if (!next(TokenType.TERMINAL)) return null;
    return new TerminalContext(util.getTerminalText(current.text));
  }

  IdentifierContext parseIdentifier() {
    if (!next(TokenType.ID)) return null;
    return new IdentifierContext(current.text);
  }
}
