final RegExp _quotes = new RegExp(r'''(^")|("$)|(^')|('$)''');
final RegExp _regex = new RegExp(r'(^\/)|(\/$)');

String getRegexPattern(String regex) => regex.replaceAll(_regex, '');

String getTerminalText(String terminal) =>
    terminal.replaceAll(_quotes, '').replaceAll('\"', '"');

String plural(String str) {
  if (str.endsWith('y')) return str.substring(0, str.length - 1) + 'ies';
  if (str.endsWith('s'))
    return str.substring(0, str.length - 1) + 's';
  else if (str.endsWith('us'))
    return str.substring(0, str.length - 2) + 'i';
  else
    return str + 's';
}
