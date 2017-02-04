# backus
Generates parsers in Dart from EBNF grammars.

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
  
# To-do
* Base runtime
* Parser
* Grammar spec
* Builder
