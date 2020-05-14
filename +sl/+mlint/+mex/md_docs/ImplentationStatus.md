# Implementation Status #

See also: [mlintmex](mlintmex.md)


## LEGEND ##
````
- not yet completed
+ completed
- ??? don't know what this is
````

## Function List ##
- sl.mlint
- sl.mlint.all
- sl.mlint.all_msg
- sl.mlint.calls
- sl.mlint.editc
- sl.mlint.lex

## checkcode only ##
- string

## LIST OF OPTIONS ##
````
- all    : ??? Not sure what this is
+ allmsg : documentation of all MLINT ids and msgs
- amb    : explains things that are ambiguous
	  : provides locations
	  : .editc() says function calls are ambiguous but does not provide a line #
- body   : ??? Not sure what this is
+ callops - documents all function calls
+ calls   - same as callops
- codegen : ???
- config=factory
- config=settings.txt
- com - ???
- cyc - Evaluates McCabe complexity for methods ...
      - NOTE: this has a side effect of telling you where the methods are
			
- dty - Not sure what thsi is ...
		% *** [1] linttype <0> CLASSDEF   CLASSDEF, ''
		% *** [1] linttype <1> <CEXPR>   <CEXPR>, ''
		% *** [1] linttype <2> '<'   '<', ''
		% *** [1] linttype <3> extracellular_stim     ClassDef (1)   extracellular_stim, ''
		% *** [1] linttype <4> NEURON.simulation     ClassRef (2)   NEURON.simulation, ''
+ edit - exposed as editc due to Matlab naming restrictions ... I'm not actually sure what information this class provides.
- id MLINT
- ja NOT VALID
+ lex : Gives position of all operators as well as certain (all?) reserved words
- m0   : MLINT
- m1   : MLINT
- m2   : MLINT
- m3   : MLINT
- mess : "message" related to errors and warnings
- msg  : similiar to all_msg but omits levels 5 & 7
- notok : oks are not ok
- pf   : parallel for loop
- set  : Very confusing output
- spmd : Parrallel Computing Toolbox's spmd
- stmt : 
- string :
- struct : MLINT
- tab  : Confusing
- tmtree : invalid
- tmw : invalid
- toks : ?????
- tree :
````