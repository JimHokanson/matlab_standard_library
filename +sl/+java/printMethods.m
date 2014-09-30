function printMethods(java_class)
%
%
%   sl.java.printMethods(java_class)
%
%   Yikes!
%   This is really ugly ...
%
%   TODO:
%   1) resolve java doc links
%   2) 

%TODO: Can we link resolve and link to the java doc??

[~,java_info] = methods(java_class,'-full');


%Column 1 - static
%Column 2 - returns
%Column 3 - function name
%Column 4 - full name
%Column 5 - input arguments
%Column 6 - "other" - usually throws information ...

%TODO: Do I want to organize with get and set methods ....

function_names = java_info(:,3);

[~,I] = sort(function_names);

for iFunction = 1:length(I)
    cur_row     = java_info(I(iFunction),:);
    is_static   = strcmp(cur_row{1},'static');
    return_name = cur_row{2};
    if is_static
        function_name = cur_row{4};
    else
        function_name = cur_row{3};
    end
    input_arguments = cur_row{5};
    is_void = strcmp(return_name,'void');
    if is_void
        fprintf('%s%s\n',function_name,input_arguments);
    else
        fprintf('%s = %s%s\n',return_name,function_name,input_arguments);
    end
end

end