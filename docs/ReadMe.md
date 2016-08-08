# Documentation #

I think I'd like this to be the main place to keep documentation. For the most part this file should just link to other files that discuss the issues at hand.

## Style Guidelines, Design Decisions, & Challenges ##

- [General guiding principles](style_guidelines/general_principles.md) (An overview)
- [Contributing](style_guidelines/contributing.md)
- Library goals, stability, & contributing
- [Naming Standards](style_guidelines/naming_standards.md)
- [Code Style](style_guidelines/code_style.md)

## Library Subsets ##
- [array](../+sl/+array/ReadMe.md)
- cellstr - functions specific to cell arrays of strings aka cellstr (cell strings)
- cmd_window - command window
- datetime
- dir - functions related to files and folder listing/management
- error - 
- gui
- help
- in
- indices - functions that are specific to the manipulation of indices
- mex
- obj
- os
- path
- plot
- stack
- str
- struct
- test
- warning
- xyz

## Design Decisions ##
- How to handle mex files?
  - automatic compilation rules
  - function shadowing rules
- How to run tests? 
