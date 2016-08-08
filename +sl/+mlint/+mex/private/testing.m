%
%   checkcode - main public file

%??? - what is going on in checkcode?
%=? see line 199 ish

%General input format:
%----------------------------------------------
%filename options
%{filenames} options

%{
When given multiple files, the outputs are returned with the name of the
function.
========== C:\D\SVN_FOLDERS\matlab_toolboxes\database\version_2\hds\@HDS\HDS.m ==========
L 202 (C 72-82): MSNU: A Code Analyzer message was once suppressed here, but the message is no longer generated.
L 329 (C 62-66): When checking if a variable is a matrix consider using ISMATRIX.
========== C:\D\SVN_FOLDERS\matlab_toolboxes\database\version_2\classes\@Trial\Trial.m ==========
L 177 (C 30): This statement (and possibly following ones) cannot be reached.
L 195 (C 21-23): The value assigned here to 'iiA' appears to be unused. Consider replacing it by ~.




m's seem to toggle whether or not the mlint warnings/errors, etc
are returned with the request

%These are notes for the m's with -lex

%-m3 - doesn't show mlint
%No m's
% L 202 (C 72-82): MSNU: A Code Analyzer message was once suppressed here, but the message is no longer generated.
% L 329 (C 62-66): When checking if a variable is a matrix consider using ISMATRIX.
% L 1307 (C 27-28): The value assigned to variable 'ME' might be unused.
% L 1334 (C 27-28): The value assigned to variable 'ME' might be unused.
% L 1355 (C 27-28): The value assigned to variable 'ME' might be unused.
% L 1873 (C 53-63): MSNU: A Code Analyzer message was once suppressed here, but the message is no longer generated.
%
%-m3 nothing
%-m2 same as m3????
%-m1
%L 329 (C 62-66): When checking if a variable is a matrix consider using ISMATRIX.
% L 1307 (C 27-28): The value assigned to variable 'ME' might be unused.
% L 1334 (C 27-28): The value assigned to variable 'ME' might be unused.
% L 1355 (C 27-28): The value assigned to variable 'ME' might be unused.
%-m0
%   same as no m?

%}



%An Invalid Option:
%temp = mlintmex(h,'-asdf');
%-----------------------------------------
%L 0 (C 0): Option '-asdf' is ignored because it is invalid.




%Output structure
%         loc: [104 18 33]  %Line, start and end column
%          id: ''
%     message: 'The function 'init__simulation' has 4 statements.'
%         fix: 0


%==========================================================================
%-all 
%==========================================================================
%
%   EMPTY
%
%-allmsg
%==========================================================================
% INTER    ========== Internal Message Fragments ==========
%    MSHHH  7   this is used for %#ok and should never be seen!
%     BAIL  7   done with run due to error
%     M2LN  7   L <line #> (C <line #>)
%     M3LN  7   L <line #> (C <line #>-<line #>)
%     M4LN  7   L <line #> (C <line #>) and L <line #> (C <line #>)
%     M6LN  7   L <line #> (C <line #>-<line #>) and L <line #> (C <line #>-<line #>)
%    IFILE  7   <FILE>
%    IPATH  7   <FILE>
%    Ifile  7   <file>
%    INAME  7   <NAME>
%    Iname  7   <name>
%    INUMB  7   <number>
%    ILINE  7   <line #>
%    IRESW  7   <reserved word>
%    IFUNC  7   <FUNCTION>
%    IOPER  7   <operator>
%    IOPTN  7   <option>
%    INTRN    ========== Serious Internal Errors and Assertions ==========
%    NOLHS  3   Left side of an assignment is empty.
%    BDLEX  4   Code Analyzer bug: lexer returns unknown token.
%    ASSRT  4   This file caused problems during an earlier run of Code Analyzer.
%    FXBAD  3   Fix message cannot find its trigger message.
%    TMMSG  4   More than 50,000 Code Analyzer messages were generated, leading to some being deleted.
%    TMNOD  4   Code Analyzer node table exceeded due to complexity of this program.
%   MXASET  4   Expression is too complex for code analysis to complete.
%
%   ???? - 
%
%
%-amb   (Ambiguous)
%==========================================================================
%
%   Seems to provide information on what the code analyzer is having
%   difficulty understanding.
% 
% L 87 (C 17-21): Code Analyzer cannot determine whether 'exist' is a variable or a function, and assumes it is a function.
% L 93 (C 17-33): Code Analyzer cannot determine whether 'NEURON.simulation' is a variable or a function, and assumes it is a function.
%
%
%-body
%==========================================================================
%
%   Empty for a class file input. Not sure what it is looking for.
%
%
%-callops
%==========================================================================
%   This seems to ignore calls to methods of classes
%
%   C1 - ????
%   C2 - line number
%   C3 - column
%   C4 - function call
%
%U0 27 31 zeros
%U0 36 31 cell
%S0 76 24 get.parent
%
%S0 - start of function
%E0 - end of function
%U1 - 
%
%DONE    -calls
%==========================================================================
%   Seems to be the same as callops
%
%
%-com
%==========================================================================
%   Empty ...
%
%-cyc
%==========================================================================
%
% L 80 (C 24-41): The McCabe complexity of 'extracellular_stim' is 2.
% L 104 (C 18-33): The McCabe complexity of 'init__simulation' is 1.
% L 148 (C 18-27): The McCabe complexity of 'set_Tissue' is 1.
% L 151 (C 18-31): The McCabe complexity of 'set_Electrodes' is 1.
% L 154 (C 18-30): The McCabe complexity of 'set_CellModel' is 1.
% L 161 (C 31-45): The McCabe complexity of 'sim__getLogInfo' is 1.
% L 182 (C 31-64): The McCabe complexity of 'sim__getThresholdsMulipleLocations' is 4.
% L 237 (C 18-41): The McCabe complexity of 'init__setupThresholdInfo' is 1.
% L 258 (C 25-40): The McCabe complexity of 'getNEURONobjects' is 1.
%
%-dty
%==========================================================================
%
% *** [1] linttype <0> CLASSDEF   CLASSDEF, ''
% *** [1] linttype <1> <CEXPR>   <CEXPR>, ''
% *** [1] linttype <2> '<'   '<', ''
% *** [1] linttype <3> extracellular_stim     ClassDef (1)   extracellular_stim, ''
% *** [1] linttype <4> NEURON.simulation     ClassRef (2)   NEURON.simulation, ''
% *** [1] linttype <5> PROPERTIES   PROPERTIES, ''
% *** [1] linttype <6> '='   '=', ''
% *** [1] linttype <NULL>  <VOID>, ''
% *** [1] asgntype <7> threshold_options_obj      PropDef (3)   threshold_options_obj, '', 1
% *** [1] linttype <NULL>  <VOID>, ''
% *** [1] asgntype <9> sim_ext_options_obj      PropDef (4)   sim_ext_options_obj, '', 1
% *** [1] linttype <11> ATTRIBUTES   ATTRIBUTES, ''
% *** [1] linttype <12> ATTR   ATTR, ''
% *** [1] linttype <13> Hidden              (0)   Hidden, ''
% *** [1] linttype <14> '='   '=', ''
%
%-edit  
%==========================================================================
%  
%   C1 - seems useless, other than for display and parse checking
%   C2 - name of the thing we are looking at
%   C3 - ???? 
%   C4 - C (class) V (Value) F (Function) E (Error)
%
%   0               <VOID>  -1 E 
%   1                  HDS   0 C  AllProp Handle DyProp Class
%   2         dynamicprops   0 C  Base Class
%   3               objIds   1 V  Property Set/Priv Get/Pub
%   4                zeros   1 F  Amb
%
%   
%-id
%==========================================================================
%
% L 202 (C 72-82): MSNU: A Code Analyzer message was once suppressed here, but the message is no longer generated.
% L 329 (C 62-66): ISMAT: When checking if a variable is a matrix consider using ISMATRIX.
% L 1307 (C 27-28): NASGU: The value assigned to variable 'ME' might be unused.
% L 1334 (C 27-28): NASGU: The value assigned to variable 'ME' might be unused.
% L 1355 (C 27-28): NASGU: The value assigned to variable 'ME' might be unused.
% L 1873 (C 53-63): MSNU: A Code Analyzer message was once suppressed here, but the message is no longer generated.
%
%
%-ja - NOT VALID ON ENGLISH SYSTEM (or at all?)
%==========================================================================
%
%
%-lex
%==========================================================================
%
%   #/#(#) -> line #, start column # (length)
%   C2 - type
%   C3 - message
%   
%
%   1/ 1(8): CLASSDEF:  CLASSDEF
%   1/10(3): <NAME>:  HDS
%   1/14(1): '<':  '<'
%   1/16(12): <NAME>:  dynamicprops
%   1/28(1): <EOL>:  <EOL>
%   2/ 5(48): %:  %HDS  Abstract class definition for HDS ...
%   2/53(1): <EOL>:  <EOL>
%
%-mess
%==========================================================================
%
%   Very verbose dumping of mlint information. Seems to include all mlints
%   including those that have been ignored ...
%   
%	3 sections:
%
%	1) 
%new message NASGU, position 11324, sz -1
    beginmess=  <VOID>, endmess=  <VOID>, prevmess=  <VOID>
    first message
    new message between   <VOID> and   <VOID>
    getting a new slot
    message (11324) **: next=  <VOID>, prev=  <VOID>
    beginmess= (11324) **, endmess= (11324) **, prevmess= (11324) **
new message NASGU, position 11488, sz -1
    beginmess= NASGU (11324) **, endmess= NASGU (11324) **, prevmess= NASGU (11324) **
    start up from previous
    new message between  NASGU (11324) ** and   <VOID>
    getting a new slot
    message (11488) **: next=  <VOID>, prev= NASGU (11324) **
    beginmess= NASGU (11324) **, endmess= (11488) **, prevmess= (11488) **
new message AGROW, position 20758, sz -1
    beginmess= NASGU (11324) **, endmess= NASGU (11488) **, prevmess= NASGU (11488) **
    start up from previous
    new message between  NASGU (11488) ** and   <VOID>
%
%	2) DUMPING MESSAGES
% NASGU (11324) **:  next= NASGU (11344) 3,  prev=  <VOID> (198/1)
%
% NASGU (11344) 3:  next= NASGU (11488) **,  prev= NASGU (11324) ** (198/21)
%
% NASGU (11488) **:  next= ISMAT (17984) 5,  prev= NASGU (11344) 3 (202/1)
%
% ISMAT (17984) 5:  next= AGROW (20758) **,  prev= NASGU (11488) ** (329/62)
%
% AGROW (20758) **:  next= AGROW (20802) 6,  prev= ISMAT (17984) 5 (373/1)
%
%	3) The output from m0
%L 202 (C 72-82): MSNU: A Code Analyzer message was once suppressed here, but the message is no longer generated.
%L 329 (C 62-66): When checking if a variable is a matrix consider using ISMATRIX.
%L 1309 (C 27-28): The value assigned to variable 'ME' might be unused.
%L 1336 (C 27-28): The value assigned to variable 'ME' might be unused.
%L 1357 (C 27-28): The value assigned to variable 'ME' might be unused.
%L 1875 (C 53-63): MSNU: A Code Analyzer message was once suppressed here, but the message is no longer generated.
%
%
%
%
%-pf
%==========================================================================
%empty
%
%-set
%==========================================================================
%
%enter link_names( <3962312> CLASSDEF  <3962312>, 0 )
% enter link_name( <3962315> extracellular_stim              (0)  <3962315>, 0,     ClassDef )
%     created entry 1
% enter link_name( <3962317> NEURON.simulation              (0)  <3962317>, 0,     ClassRef )
%     created entry 2
% enter link_name( <3962321> threshold_options_obj              (0)  <3962321>, 1,      PropDef )
%     created entry 3
% enter link_name( <3962324> sim_ext_options_obj              (0)  <3962324>, 1,      PropDef )
%     created entry 4
% enter link_name( <3962332> data_transfer_obj              (0)  <3962332>, 1,      PropDef )
%
%
%
%-spmd
%==========================================================================
%
%   Empty for class
%
%
%-stmt (Statements
%==========================================================================
%
%
% L 80 (C 24-41): The function 'extracellular_stim' has 8 statements.
% L 104 (C 18-33): The function 'init__simulation' has 4 statements.
% L 148 (C 18-27): The function 'set_Tissue' has 2 statements.
% L 151 (C 18-31): The function 'set_Electrodes' has 2 statements.
%
%
%
%
%-tab
%==========================================================================
% %   0               <VOID> < -1>  NX  -1, P  -1, CH   2  Err 
% %   1                  HDS <8097>  NX  -1, P   0, CH 817  Cd  AllProp Handle DyProp Class 8097 8081 8060 8044 7959 7930 7914 7805 7796 7787 7708 7130 6964 6844 6825 6817 6644 5323 5306 5099 3
% %   2         dynamicprops <  4>  NX   1, P   0, CH  -1  Cu  Base Class 4
% %   3               objIds < 13>  NX  -1, P   1, CH  -1  Vd  IsSet Property Set/Priv Get/Pub 13
% %   4                zeros < 91>  NX   3, P   1, CH  -1  Fu  IsUsed Amb 91 80 61 54 47 40 28 22 15
% %   5           createDate < 20>  NX   4, P   1, CH  -1  Vd  IsSet Property Set/Priv Get/Pub 20
% %   6           objVersion < 26>  NX   5, P   1, CH  -1  Vd  IsSet Property Set/Priv Get/Pub 26
% %   7            linkProps < 32>  NX   6, P   1, CH  -1  Vd  IsSet Property Set/Priv Get/Pub 32
%
%   Followed by:
%
% % L 202 (C 72-82): MSNU: A Code Analyzer message was once suppressed here, but the message is no longer generated.
% % L 329 (C 62-66): When checking if a variable is a matrix consider using ISMATRIX.
% % L 1307 (C 27-28): The value assigned to variable 'ME' might be unused.
% % L 1334 (C 27-28): The value assigned to variable 'ME' might be unused.
% % L 1355 (C 27-28): The value assigned to variable 'ME' might be unused.
% % L 1873 (C 53-63): MSNU: A Code Analyzer message was once suppressed here, but the message is no longer generated.
%
%
%-tmtree  Invalid
%-tmw
%
%
%-toks
%==========================================================================
%??????
%
%-tree
%==========================================================================
%   0:   1/ 1    1|        CLASSDEF |   1 |   5 |  -  |  -  |  -  |  -  |V=10948, H?/0
%                                    | 
%    1:   1/ 1    1|         <CEXPR> |  -  |   2 |  -  |   0 |  -  |  -  |
%                                    | 
%    2:   1/29   29|             '<' |   3 |   4 |  -  |   1 |  -  |  -  |
%                                    | 
%    3:   1/10   10|          <NAME> |  -  |  -  |  -  |   2 |  -  |  -  | extracellular_stim
%                                    | #1 18     ClassDef
%    4:   1/31   31|          <NAME> |  -  |  -  |  -  |   2 |  -  |  -  | NEURON.simulation
%                                    | #2 17     ClassRef
%    5:  32/ 5 1294|      PROPERTIES |  -  |   6 |  10 |   0 |  -  |  -  |V=1505
%                                    | 
%    6:  33/ 9 1313|             '=' |   7 |  -  |   8 |   5 |  -  |  -  |
%                                    | 
%    7:  33/ 9 1313|          <NAME> |  -  |  -  |  -  |   6 |  -  |  -  | threshold_options_obj
%
%
%
%
%-ty
%==========================================================================
% %FUNCTIONS:  extracellular_stim NEURON.simulation extracellular_stim exist NEURON import <VOID> threshold_options sim_extension_options data_transfer threshold_analysis init__simulation create_standard_sim set_Tissue set_Electrodes set_CellModel sim__getLogInfo NEURON sim__getThresholdsMulipleLocations true processVarargin isempty NEURON iscell cellfun reshape permute init__setupThresholdInfo getNEURONobjects NEURON
% % threshold_options_obj:
% %                      ???: 33
% % sim_ext_options_obj:
% %                      ???: 34
% % data_transfer_obj:
% %                      ???: 38
% % threshold_analysis_obj:
% %                      ???: 42
% % tissue_obj:
% %                      ???: 49
% % elec_objs:
% %                      ???: 52
% % cell_obj:
% %                      ???: 53
% % v_all:
% %                      ???: 60
% % t_vec:
% %                      ???: 61
% % tissue_configuration:
% %                      ???: 73
% % electrode_configuration:
% %                      ???: 74
% % cell_configuration:
% %                      ???: 75
% % obj:
% %                      ???: 80 93 95 96 97 97 98 98 99 99 99
%
%
%
%
%-ud
%==========================================================================
%<4046186> IF :  ENTERING : xstim_options(4046184) obj(4046179)
% <4046188> '~' :  ENTERING : xstim_options(4046184) obj(4046179)
% <4046189> <CALL> :  ENTERING : xstim_options(4046184) obj(4046179)
% <4046192> 'xstim_options'              (0) :  ENTERING : xstim_options(4046184) obj(4046179)
% <4046192> 'xstim_options'              (0) :  CONTINUING : xstim_options(4046184) obj(4046179)
% <4046193> 'var'              (0) :  ENTERING : xstim_options(4046184) obj(4046179)
%
%
%-yacc (yet another compiler compiler) parse generator
%==========================================================================


h = which('HDS');

%'-struct' returns options as a struct ...
%-config=C:\Users\RNEL\AppData\Roaming\MathWorks\MATLAB\R2013a\MLintDefaultSettings.txt
%=> I believe this is a way of modifying the user preferences

%-m3 -lex
temp = mlintmex(h,'-m3','-lex');

%What's the difference between m2 and m3?
temp = mlintmex(h,'-m2','-lex');

%Returns character array
%#/#(#): type: more info
%
%
%? - what are the unique types?
%? - What more info has more info?
%
%   Addition of the struct provides a cell array
%   each containing a structure array:
%
%   Example struct:
%
%        loc: [0 0 0]
%          id: ''
%     message: '  1/16(12): <NAME>:  dynamicprops
% '
%         fix: 0
temp = mlintmex(h,'-ja');