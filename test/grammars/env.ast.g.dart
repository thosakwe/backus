library env.ast.g.dart;

import 'package:backus/backus.dart';

class EntryContext extends AstNode {
  EntryContext(String text) : super(text);
}

class EntryListContext extends AstNode {
  final List<EntryContext> entries = [];

  EntryListContext(String text) : super(text);
}

class EnvFileContext extends AstNode {
  EntryListContext entryList;

  EnvFileContext(String text) : super(text);
}
