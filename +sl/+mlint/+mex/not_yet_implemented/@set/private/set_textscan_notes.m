%textscan_notes





%Sample outputs
%--------------------------------------------------------------
% enter link_names( <199101> FUNCTION  <199101>, 0 )
% enter link_name( <199104> test_file_001              (0)  <199104>, 0,    SubfunDef )
%     created entry 1
% enter link_names( <199106> <Expression>  <199106>, 1 )
% enter link_expr_lhs( <199108> '['  <199108>, 1, )
% enter link_expr_lhs( <199109> '~'  <199109>, 1, )
% enter link_name( <199111> c              (0)  <199111>, 1,       VarAsg )
%     created entry 2
% enter link_expr1( <199113> '('  <199113>, 1 )
% enter link_name( <199114> unique              (0)  <199114>, 1,     VarUseIx )
%     created entry 3
% enter link_expr1( <199116> '('  <199116>, 1 )
% enter link_name( <199117> rand              (0)  <199117>, 1,     VarUseIx )
%     created entry 4
% enter link_expr1( <199119> 1              (0)  <199119>, 1 )
% enter link_expr1( <199120> 1000              (0)  <199120>, 1 )
% enter link_names( <199121> <Expression>  <199121>, 1 )
% enter link_expr_lhs( <199123> a              (0)  <199123>, 1, )
% enter link_name( <199123> a              (0)  <199123>, 1,       VarAsg )
%     created entry 5
% enter link_expr1( <199125> '~'  <199125>, 1 )
% enter link_expr1( <199126> false              (0)  <199126>, 1 )
% enter link_name( <199126> false              (0)  <199126>, 1,       VarUse )
%     created entry 6


% enter link_names( <200032> CLASSDEF  <200032>, 0 )
% enter link_name( <200035> ImageViewer              (0)  <200035>, 0,     ClassDef )
%     created entry 1
% enter link_name( <200037> handle              (0)  <200037>, 0,     ClassRef )
%     created entry 2
% enter link_name( <200050> handles              (0)  <200050>, 1,      PropDef )
%     created entry 3
% enter link_name( <200066> closedHandPointer              (0)  <200066>, 1,      PropDef )
%     created entry 4
% enter link_expr1( <200068> '['  <200068>, 1 )
% enter link_expr1( <200069> <ROW>  <200069>, 1 )
% enter link_expr1( <200070> NaN              (0)  <200070>, 1 )
% enter link_name( <200070> NaN              (0)  <200070>, 1,       VarUse )
%     created entry 5
% enter link_expr1( <200072> NaN              (0)  <200072>, 1 )
% enter link_name( <200072> NaN              (0)  <200072>, 1,       VarUse )
%     found entry 5
% enter link_expr1( <200074> NaN              (0)  <200074>, 1 )
% enter link_name( <200074> NaN              (0)  <200074>, 1,       VarUse )


% enter link_expr1( <207172> '''100%'' displays the image at the true...              (0)  <207172>, 406 )
% enter link_expr1( <207173> '''File Info'' displays the current imag...              (0)  <207173>, 406 )
% enter link_expr1( <207174> 'Help'              (0)  <207174>, 406 )
% uplevel_child( <203897> previewImageClickFcn     FunUseAt (175)  (175) )
%     establish uplevel 190 to 349 (startTimer)
%     establish uplevel 189 to 160 (val)
%     establish uplevel 188 to 162 (str)
%     establish uplevel 187 to 171 (fullfile)
%     establish uplevel 186 to 233 (loadImage)
%     establish uplevel 185 to 362 (stopTimer)
%     establish uplevel 184 to 155 (obj)
%     establish uplevel 183 to 161 (get)
% uplevel_child( <205259> winBtnMotionFcn     FunUseAt (270)  (270) )
%     establish uplevel 298 to 269 (xy)
%     establish uplevel 297 to 266 (set)
%     establish uplevel 296 to 262 (obj)
%     establish uplevel 295 to 268 (get)
%     establish uplevel 294 to 285 (pt)
% uplevel_child( <205471> zoomMotionFcn     FunUseAt (282)  (282) )
%     establish uplevel 313 to 266 (set)
%     establish uplevel 312 to 279 (curPt)
%     establish uplevel 310 to 275 (diff)
%     establish uplevel 308 to 280 (curPt2)
%     establish uplevel 306 to 262 (obj)
%     establish uplevel 305 to 281 (initPt)
%     establish uplevel 303 to 268 (get)
%     establish uplevel 302 to 285 (pt)
%     establish uplevel 30 to 406 (helpBtnCallback)
%     establish uplevel 96 to 390 (fixLongDirName)








%From ImageViewer.m            
%   0               <VOID> < -1>  NX  -1, P  -1, CH 406  Err 
%   1          ImageViewer <4575>  NX  -1, P   0, CH 369  Cd  AllProp AllMeth Handle Class 4575 4415 3
%   2               handle <  4>  NX   1, P   0, CH  -1  Cu  Base Class 4
%   3              handles < 13>  NX  -1, P   1, CH  -1  Vd  IsSet Property Set/Prot Get/Prot 13
%   4    closedHandPointer < 24>  NX   3, P   1, CH  -1  Vd  IsSet Constant Property Set/Prot Get/Prot 24
%   5                  NaN <777>  NX   4, P   1, CH  -1  Fu  IsUsed Amb 777 775 773 771 769 767 765 763 761 759 757 753 751 749 746 744 742 740 738 736 734 732 730 728 722 720 717 709 707 699 662 654 652 644 641 639 637 635 633 631 629 627 625 623 617 615 612 610 608 606 604 602 600 598 596 594 592 588 586 584 581 579 577 573 571 569 567 565 563 559 557 555 552 550 544 542 540 538 532 530 527 519 517 509 472 464 462 454 451 449 443 441 439 437 431 429 426 424 422 418 416 414 412 410 408 404 402 400 394 392 380 378 376 374 371 369 357 355 353 351 348 346 333 331 329 326 311 309 306 290 272 254 237 235 219 217 215 198 196 193 178 176 173 171 158 156 154 151 149 147 145 141 137 133 131 129 127 124 122 120 118 116 114 112 110 108 106 104 102 100 98 96 94 91 89 87 85 83 81 79 77 75 73 71 69 67 65 63 61 58 56 54 52 50 48 46 44 42 40 38 36 34 32 30 28
%   6     zoomInOutPointer <396>  NX   5, P   1, CH  -1  Vd  IsSet Constant Property Set/Prot Get/Prot 396
%   7          ImageViewer <783>  NX   6, P   1, CH  44  Fd  IsSet Ctor Method 783
%   8                  obj <781>  NX  -1, P   7, CH  -1  Vd  IsUsed IsSet OUT OBJ CtorOut 781 860 889 930 1076 1100 1142 1194 1515 1531 1704 1713 1722 1731 1739 1748 1769 1774 1778
%   9              dirname <784>  NX   8, P   7, CH  -1  Vd  IsUsed IsSet IN 784 797 807 811 1734
%  10            verNumber <787>  NX   9, P   7, CH  -1  Va  IsUsed IsSet 787 967
%  11               nargin <793>  NX  10, P   7, CH  -1  Fu  IsUsed Amb 793
%  12                  pwd <799>  NX  11, P   7, CH  -1  Fu  IsUsed Amb 799
%  13               ischar <806>  NX  12, P   7, CH  -1  Fu  IsUsed Amb 806
%  14                isdir <810>  NX  13, P   7, CH  -1  Fu  IsUsed Amb 810
%  15                error <814>  NX  14, P   7, CH  -1  Fu  IsUsed Amb 814
%  16                upper <817>  NX  15, P   7, CH  -1  Fu  IsUsed Amb 817 872
%  17            mfilename <819>  NX  16, P   7, CH  -1  Fu  IsUsed Amb 819 874
%  18               delete <822>  NX  17, P   7, CH  -1  Fu  IsUsed Amb 822
%  19              findall <824>  NX  18, P   7, CH  -1  Fu  IsUsed Amb 824
%  20             bgcolor1 <832>  NX  19, P   7, CH  -1  Va  IsUsed IsSet 832 856 943 958 984 999 1032 1051 1160 1173 1190 1209 1511 1551
%  21             txtcolor <840>  NX  20, P   7, CH  -1  Va  IsUsed IsSet 840 956 997
%  22                 figH <848>  NX  21, P   7, CH  -1  Va  IsUsed IsSet 848 926 945 986 1034 1127 1147 1162 1197 1518 1536 1563 1593 1635 1698 1708 1782
%  23               figure <850>  NX  22, P   7, CH  -1  Fu  IsUsed Amb 850
%  24          verLessThan <920>  NX  23, P   7, CH  -1  Fu  IsUsed Amb 920
%  25                  set <925>  NX  24, P   7, CH  -1  Fu  IsUsed Amb 925 1781
%  26                  uph <936>  NX  25, P   7, CH  -1  Va  IsUsed IsSet 936 970 977 1008 1015 1060 1084 1108 1153 1178 1542 1573
%  27              uipanel <939>  NX  26, P   7, CH  -1  Fu  IsUsed Amb 939 980 1018 1156 1545
%  28            uicontrol <952>  NX  27, P   7, CH  -1  Fu  IsUsed Amb 952 993 1039 1066 1090 1114 1132 1169 1184 1505 1523 1674
%  29              sprintf <965>  NX  28, P   7, CH  -1  Fu  IsUsed Amb 965
%  30               <VOID> < -1>  NX  29, P   7, CH  -1  Fu  IsUsed IsSet
%  31                  map <1202>  NX  29, P   7, CH  -1  Va  IsUsed IsSet 1202 1502
