# backus
Generates parsers in Dart from EBNF grammars.
Currently only supports LL(1) grammars.

# Goals
* Generate recursive descent parsers
* LR parsers
* Maybe LALR
* Generate AST classes
  * AST should be manually creatable in code
* Support `package:build` primarily :)
* Support generating code from AST's?
* Skip whitespace by default
  * Allow config to override this
* Support LL(k) grammars (have to manually specify k)
  
# To-do
* Base runtime
* Parser
* Grammar spec
* Builder
* Add locals to rules
* Visitor generator
  * With anonymous visitor, kind of like Angel's `AnonymousService`

# Notes
* Implicit tokens
  * i.e. if you come across a string in a parser rule, check if there is an existing token for it; otherwise, create new token type and sub it in
  * This will just make grammar writing faster ;)
* Parse methods, as well as AST classes, should include source rules as comments