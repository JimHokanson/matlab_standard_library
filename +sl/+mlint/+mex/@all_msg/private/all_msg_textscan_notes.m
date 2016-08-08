%   INTER    ========== Internal Message Fragments ==========
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
%    NOMEM  4   Code Analyzer has run out of memory.
%    INERR  4   An internal Code Analyzer consistency check has failed (Code Analyzer bug!).
%    XJOIN  4   Code Analyzer bug: unexpected JOIN.
%    NULLA  4   Code Analyzer bug: Null pointer in ASET.
%    XOTHR  4   Code Analyzer bug: unexpected OTHERWISE.
%    XELSE  4   Code Analyzer bug: unexpected ELSE.
%    XCASE  4   Code Analyzer bug: unexpected CASE.
%    XCTCH  4   Code Analyzer bug: unexpected CATCH.
%    TOPLP  4   Code Analyzer bug: unexpected left parenthesis.
%    TOPCL  4   Code Analyzer bug: call at top level.
%    XSUBF  4   Code Analyzer bug: unexpected subfunction.
%    XFUNC  4   Code Analyzer bug: badly formed function file.
%    TMPAR  4   Code Analyzer bug: multiple parents for node.
%    XSUBS  4   Code Analyzer bug: unexpected partial subscript.
%    XTABL  4   Code Analyzer bug: table format error.
%      XID  4   Code Analyzer bug: invalid ID index.
%     XIDP  4   Code Analyzer bug: ID points to missing entry.
%    XSTID  4   Code Analyzer bug: symbol table link is bad.
%    XSTPT  4   Code Analyzer bug: symbol table list error.
%     XNOU  4   Code Analyzer bug: missing use in table.
%    XQUOT  4   Code Analyzer bug: unexpected quote in table.
%    NOUSE  4   Code Analyzer bug: Cannot find source of use conflict.
%    NOLST  4   Code Analyzer bug: missing list entry.
%    NONUK  4   Code Analyzer bug: unexpected need to remove quote.
%     NODS  4   Code Analyzer bug: data structure corruption.
%    XVAR2  4   Code Analyzer bug: linking var twice.
%    XCALL  4   Code Analyzer bug: unexpected CALL.
%    XDCAL  4   Code Analyzer bug: unexpected DCALL.
%    XSB2E  4   Code Analyzer bug: subscript seen too early.
%    XDOPE  4   Code Analyzer bug: dope field seen for non-ID.
%    XDUAL  4   Code Analyzer bug: Dual data structure error.
%     XFOR  4   Code Analyzer bug: badly constructed FOR.
%    XUPLV  4   Code Analyzer bug: missing list in uplevel.
%    UPFCN  4   Code Analyzer bug: uplevel of function defn.
%    XTREE  4   Code Analyzer bug: bad parse tree.
%    XTRCL  4   Code Analyzer bug: bad tree turning to call.
%    XMISS  4   Code Analyzer bug: no missing entries in scripts.