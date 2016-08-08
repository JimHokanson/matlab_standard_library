## Naming Standards ##

The following are guidelines for names in Matlab. This might need to be expounded upon but it is a start. Discussion on this page can take place at:
https://github.com/JimHokanson/matlab_standard_library/issues/2

## Generic Name Formatting Rules ##

These are the rules I am currently using.

- **local variables**: lower_case_with_underscores
  - variable names should generally be specific
  - short variable names can be used, as long as their definition is clear 
    -  write short functions
    -  describe the variable meaning where necessary
- **packages**: all lowercase
  - abbreviations when needed
  - for common packages, keep this as short as possible without being ambiguous
- **functions**: camelCaseWithLeadingLowercase
- **classes**: lower_case_with_underscores
  - Matt mentioned, CamelCaseWithLeadingCapital, I tend to prefer matching packages
- **class properties**: lower_case_with_underscores
- **class methods**: camelCaseWithLeadingLowercase
- **class and variable constants**: UPPER_CASE_WITH_UNDERSCORES
- **for loop variables**: iVar


## Specific name conventions ##

UNFINISHED
- file_path, base_path
- acronyms
- singular vs plural names
- indices
- local class properties
- logicals - mask
