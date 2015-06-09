classdef current_line_info < sl.obj.display_class
    %
    %   Class:
    %   sl.help.current_line_info
    %
    %   
    %
    
    %{
    
    %Testing code:
    raw_text = 'sl.path.addPackages(''hdf5_matlab'
    %sl.path.addPackages
    
    raw_text = 'mean(x(1'               %What do we want to do here?
    %mean
    
    raw_text = 'load filename'          %Call via string inputs
    %load
    
    raw_text = 'mean(''testing('
    
    fp = 'C:\D\repos\matlab_git\mat_std_lib\+sl\+help\@current_line_info\test_dir\example_line.m'
    %obj = sl.mlint.mex.calls(fp) %doesn't work ...
    obj = sl.mlint.mex.ty(fp)
    obj = sl.mlint.mex.lex(fp)
    
    
    ???What about multiline entries ...
    raw_text = sprintf('sl.path.addPackages(...\n')
    %}
    
    properties
       raw_text
       is_call_resolved
       resolved_name
    end
    
    methods
        function obj = current_line_info(raw_text,context)
            %
            %   Inputs:
            %   -------
            %   raw_text : 
            %       The text should only go to the cursor location.
            %   context : 
            %       I'm not sure what I want here ...
            %       command window or filename
            %
            
            obj.raw_text = raw_text;
        
            
            %Can we find an unterminated quoted string and use that to our 
            %advantage to find the text ????
            %
            %Algorithm:
            %----------
            %1) ??????
            
            
            
            
        end
    end
    
end

