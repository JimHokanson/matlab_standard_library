function str = join(cellstr_input,delimiter,treat_delimiter_as_literal)
%toString
%
%   str = sl.cellstr.join(cellstr_input,*delimiter,*treat_delimiter_as_literal)
%
%   INPUTS
%   =======================================================================
%   cellstr   : A cell array of strings to combine
%   delimiter : (default ','), string to use in combining
%   treat_delimiter_as_literal : (default false), e.g. normally \t is
%           treated as a tab, but if prop is true, then it is literally '\t'
%
%   EXAMPLES
%   =======================================================================
%
%   TODO: Finish Documentation

if nargin < 2 || isempty(delimiter)
    delimiter = ',';
end

if nargin < 3
    treat_delimiter_as_literal = false;
end

if isempty(cellstr_input)
    str = '';
elseif ~iscell(cellstr_input)
    error('Input to %s must be a cell array',mfilename)
else
    P = cellstr_input(:)' ;
    if treat_delimiter_as_literal
        P(2,:) = {delimiter};
    else
        P(2,:) = {sprintf([delimiter '%s'],'')} ;  %Added on printing to handle things like \t and \n
    end
    P{2,end} = [] ;
    str = sprintf('%s',P{:});
end