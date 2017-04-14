import 'right_hand_side.dart';

final RegExp _escape = new RegExp(r'\\([A-Za-z]+)');
final RegExp _unicode = new RegExp(r'\\([0-9]+)');
final RegExp _quotes = new RegExp('(^")|(^\')|("\$)|(\'\$)');

class TerminalContext extends RightHandSideContext {
  final String text;
  TerminalContext(this.text);

  String get stringValue =>
      text.replaceAll(_quotes, '').replaceAllMapped(_unicode, (m) {
        var n = int.parse(m[1]);
        return new String.fromCharCode(n);
      }).replaceAllMapped(_escape, (m) {
        switch (m[1]) {
          case 'n':
            return '\n';
          case 'r':
            return '\r';
          case 't':
            return '\t';
          case 'b':
            return '\b';
          default:
            return m[0];
        }
      });

  @override
  String toString() => "Terminal (String): $text";
}
