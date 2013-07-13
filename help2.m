function help2
%
%
%   This function should expose better help methods:
%
%   1) A better help function for functions
%       sl.help.func
%   
%   2) Instance based help
%       helpm <- needs to be renamed




%Class help



%     if nargin && ~iscellstr(varargin)
%         error(message('MATLAB:help:NotAString'));
%     end
% 
%     process = helpUtils.helpProcess(nargout, nargin, varargin);
% 
%     try %#ok<TRYNC>
%         % no need to tell customers about internal errors
% 
%         process.getHelpText;
%         
%         process.prepareHelpForDisplay;
%     end
% 
%     if nargout > 0
%         out = process.helpStr;
%         if nargout > 1
%             docTopic = process.docTopic;
%         end
%     end