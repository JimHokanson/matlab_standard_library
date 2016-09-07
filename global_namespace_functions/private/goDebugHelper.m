function goDebugHelper(stack_printout)
%
%  goDebugHelper(stack_printout)
%
%   This is used by goDebug.mex in order to
%   open the editor to the current edit point in the stack.
%

lines = sl.str.getLines(stack_printout);

[~,is_matched] = sl.cellstr.regexpSingleMatchTokens(...
    lines,'^>','output_type','match');

I = find(is_matched,1);

if isempty(I)
    %TODO: Throw warning (what should it say...)
    warning()
    idx_use = 2;
else
    idx_use = I + 1;
end

s = dbstack('-completenames');
sl.ml.editor.openAndGoToLine(s(idx_use).file,s(idx_use).line);
end