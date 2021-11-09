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
 	{'S0 86 26 get.x_extents'}
    {'E0 95 11 get.x_extents'}
    {'U1 93 32 end'          }
    {'S0 96 26 get.y_gaps'   }
    {'E0 108 11 get.y_gaps'  }
    {'U1 100 33 get'         }
    {'U1 101 21 iscell'      }
    {'U1 104 31 cellfun'     }
    {'A1 104 39 '            }
    {'E1 104 49 '            }


- codegen : ???
- config=factory
- config=settings.txt
- com - ???
- cyc - Evaluates McCabe complexity for methods ...
      - NOTE: this has a side effect of telling you where the methods are
			
- dty - Not sure what this is ...
		% *** [1] linttype <0> CLASSDEF   CLASSDEF, ''
		% *** [1] linttype <1> <CEXPR>   <CEXPR>, ''
		% *** [1] linttype <2> '<'   '<', ''
		% *** [1] linttype <3> extracellular_stim     ClassDef (1)   extracellular_stim, ''
		% *** [1] linttype <4> NEURON.simulation     ClassRef (2)   NEURON.simulation, ''
+ edit - exposed as editc due to Matlab naming restrictions. Seems to be a list of variable/property/function/method names
	%{'  0               <VOID>  -1 E '         }
    %{'  1           subplotter   0 C  Class'   }
    %{'  2 sl.obj.display_class   0 C  Class'   }
    %{'  3                h_fig   1 V  Property'}
    %{'  4                 dims   1 V  Property'}
    %{'  5              handles   1 V  Property'}
    %{'  6           last_index   1 V  Property'}
    %{'  7   row_first_indexing   1 V  Property'}
    %{'  8               n_rows   1 V  Property'}
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