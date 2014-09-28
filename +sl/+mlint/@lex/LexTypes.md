## Lex Types ##

This is meant to document the different types that are parsed
out from the lex parser.


??? - are these seen in other functions?


- '%' - line comment, these also seem to appear for continuation comments 
  - i.e. => something ... this is a comment
  - They also appear for lines that make up group comments, except for the start and end lines, which are indicated as group comment lines
- '&' 
- '&&'
- '('
- ')'
- '*'
- '+'
- ','
- '-'
- '.'
- ':'
- ';'
- '&lt;'
- '&lt;='
- '&lt;DOUBLE&gt;'
- '&lt;EOL&gt;' - end of line character. NOTE, for lines with '...' the EOL character is not present. This points to the \n character.
- '&lt;INT&gt;'
- '&lt;NAME&gt;'
- '&lt;STRING&gt;'
- '='
- '=='
- '&gt;'
- '@'
- 'BREAK'
- 'CASE'
- 'CATCH'
- 'CLASSDEF'
- 'CONTINUE'
- 'ELSE'
- 'ELSEIF'
- 'END'
- 'FOR'
- 'FUNCTION'
- 'GLOBAL'
- 'IF'
- 'METHODS'
- 'NUL' - I think this is reserved for the end of the file
- 'OTHERWISE'
- 'PERSISTENT'
- 'PROPERTIES'
- 'RETURN'
- 'SWITCH'
- 'TRY'
- 'WHILE'
- '['
- ']'
- '{'
- '||'
- '}'
- '~' - this does not distinguish between tilde and not
- '~='

NOT PRESENT   =============================================================
...

%}