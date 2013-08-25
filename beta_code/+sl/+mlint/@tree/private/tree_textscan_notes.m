%{



NOTE: Every entry is two lines, I've added some additional lines to 
help in my understanding of the output

RAW:
function test_file_001
%
%   Tilde test ...

[~,~,c] = unique(rand(1,1000));

a = ~false;

counter line #/col#            1       2     3    4     5     6     7     8

        absolute index - after removal of char(13)
                |
               \ /
   0:   1/ 1    1|        FUNCTION |   1 |   4 |  -  |  -  |  -  |  -  |V=89
                                   |  TOPF
   1:   1/10   10|           <ETC> |  -  |   2 |  -  |   0 |  -  |  -  |
                                   |  FHD
   2:   1/10   10|           <ETC> |   3 |  -  |  -  |   1 |  -  |  -  |
                                   |  FHD
   3:   1/10   10|          <NAME> |  -  |  -  |  -  |   2 |  -  |  -  | test_file_001
                                   | #1 13       FunDef FHD FUN

V= -> symbol table index
   4:   5/ 9   54|    <Expression> |   5 |  -  |  16 |   0 |  -  |  -  |V=76
                                   |  FUN EFF TOPF
   5:   5/ 9   54|             '=' |   6 |  10 |  -  |   4 |  -  |  -  |
                                   |  FUN EFF

%NOTE: The equals comes before the things on the LHS

                                    Child?             Lsib/Parent?
                                                         |
                                                        \ /
                                      Lchi Rchi  Rsib
   6:   5/ 1   46|             '[' |   7 |  -  |  -  |   5 |  -  |  -  |V=52
                                   |  FUN
   7:   5/ 2   47|             '~' |  -  |  -  |   8 |   6 |  -  |  -  |
                                   |  FUN
   8:   5/ 4   49|             '~' |  -  |  -  |   9 |   7 |  -  |  -  |
                                   |  FUN
   9:   5/ 6   51|          <NAME> |  -  |  -  |  -  |   8 |  -  |  -  | c
                                   | #2 1       VarAsg FUN DEAD FULL

                                      L
  10:   5/17   62|          <CALL> |  11 |  12 |  -  |   5 |  -  |  -  |V=75
                                   |  FUN
  11:   5/11   56|          <NAME> |  -  |  -  |  -  |  10 |  -  |  -  | unique
                                   | #3 6     VarUseIx FUN FUN


  12:   5/22   67|          <CALL> |  13 |  14 |  -  |  10 |  -  |  -  |V=74
                                   |  TYPE double FUN
  13:   5/18   63|          <NAME> |  -  |  -  |  -  |  12 |  -  |  -  | rand
                                   | #4 4     VarUseIx DOPE rand  FUN FUN
  14:   5/23   68|           <INT> |  -  |  -  |  15 |  12 |  -  |  -  | 1
                                   |  TYPE flint  FUN
  15:   5/25   70|           <INT> |  -  |  -  |  -  |  14 |  -  |  -  | 1000
                                   |  TYPE flint  FUN


  16:   7/ 3   81|    <Expression> |  17 |  -  |  -  |   4 |  -  |  -  |V=89
                                   |  FUN EFF TOPF
  17:   7/ 3   81|             '=' |  18 |  19 |  -  |  16 |  -  |  -  |
                                   |  FUN EFF
  18:   7/ 1   79|          <NAME> |  -  |  -  |  -  |  17 |  -  |  -  | a
                                   | #5 1       VarAsg FUN DEAD KILL FULL
  19:   7/ 5   83|             '~' |  20 |  -  |  -  |  17 |  -  |  -  |
                                   |  FUN
  20:   7/ 6   84|          <CALL> |  21 |  -  |  -  |  19 |  -  |  -  |
                                   |  FUN
  21:   7/ 6   84|          <NAME> |  -  |  -  |  -  |  20 |  -  |  -  | false
                                   | #6 5       VarUse DOPE false  FUN FUN





%}