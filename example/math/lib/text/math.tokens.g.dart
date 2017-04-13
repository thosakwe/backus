library math.tokens;

abstract class TokenType {
  static const String ILLEGAL = '<illegal token>';

  static const String SKIP_WHITESPACE = 'TokenType::skip-whitespace';

  static const String PLUS = 'TokenType::plus';

  static const String EXPR = 'TokenType::expr';

  static const String SUM = 'TokenType::sum';
}
