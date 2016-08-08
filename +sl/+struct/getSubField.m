function value = getSubField(s,subfield_name)
%
%   This function was meant to return a field that was deeply nested.
%
%   value = sl.struct.getSubField(s,subfield_name)
%
%

%This crashes Matlab when wrong :/
%value = subsref(s,struct('type','.','subs',regexp(subfield_name,'\.','split')));

value = eval(['s.' subfield_name]);

% % % %B = subsref(A,S)
% % % 
% % % a.best.cheese.ever = 1;
% % % 
% % % subfield_name = 'best.cheese.ever';
% % % 
% % % tic
% % % for i = 1:100000
% % % test1 = subsref(a,struct('type','.','subs',regexp(subfield_name,'\.','split')));
% % % end
% % % toc
% % % 
% % % tic
% % % for i = 1:100000
% % % test2 = eval(['a.' subfield_name]);
% % % end
% % % toc
% % % 
% % % 
% % % tic
% % % for i = 1:100000
% % % test3 = subsref(a,struct('type','.','subs',deref(textscan(subfield_name,'%s','Delimiter','.'))));
% % % end
% % % toc
% % % 
% % % test1
% % % test2
% % % test3
% % % 
% % % end
% % % 
% % % function out = deref(in)
% % %    out = in{1};
% % % end

