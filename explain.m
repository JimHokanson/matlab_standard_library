function explain
%
%
%   See "explain_error.md" in larger projects. 

error('Not yet implemented')

%See: http://en.wikibooks.org/wiki/MATLAB_Programming/Error_Messages

%s = lasterror;
%        message: ''
%     identifier: ''
%          stack: [0x1 struct]
%ME = MException.last;

%dbstack



%1) Examine stack and unsaved files ...

%2) Examine error lines and show exact fault ...
%
%   IN OTHER WORDS, EXPALIN THE ERROR

%ERRORS: %This will eventually be organized into code 
%a bit better ...
%========================================================
%
%   IDENTIFIER:
%
%Attempt to reference field of non-structure array.
%
%Example: 
%obj.applied_stimulus_matcher.getStimulusMatches();
%
%Problem:
%obj.applied_stimulus_matcher should have been
%a class, but was not initialized
%
%Better explanation:
%
%obj.applied_stimulus_matcher has a value of
%[], and as such does not support dot referencing
%
%It is expected that this value should be a structure
%or a class
%
%Bonus points:
%- link to class(obj) definition ...
%
%
%IDENTIFIER: 'MATLAB:minrhs'
%MESSAGE:   Not enough input arguments.
%
%   This error comes when a variable that is defined by name
%   as an input to a function is not actually passed in. Generally
%   it indicates a problem with the calling function.
%
%   Improvements:
%   1) Show function definition
%   2) Show offending calling line - provide link to editor
%   3) Show offending referencing line - provide link ...
%   4) BONUS: When names match, suggest solution ...
%
%IDENTIFIER: 'MATLAB:UndefinedFunction'
%MESSAGE: Undefined function 'iterative_max_distance' for input arguments of type 'double'.
%
%   This one is fairly straightforward but might help from some suggested
%   solutions:
%
%   - name spelled wrong
%   - function not on path (wrong directory or not added)
%   - prototype is wrong? check if function exists ...
%
%IDENTIFIER: 'MATLAB:noSuchMethodOrField'
%MESSAGE: No appropriate method, property, or field old_data for class sci.cluster.iterative_max_distance.
%
%   Provide link to class definition ...
%
%IDENTIFIER: 'MATLAB:dimagree'
%MESSAGE: Error using  - 
% Matrix dimensions must agree.
%
%   Try and explain this better. This one is tricky as it involves pulling
%   apart the pieces part by part ...
%
%   [0 cum_sum_counts(end_of_group_mask(2:end))]
%
%   counts_out = cum_sum_counts(end_of_group_mask) - [0 cum_sum_counts(end_of_group_mask(2:end))];
%
%   In this case I am indexing into a mask, which means I won't remove 
%   a value like I thought ..., only a false value, and Matlab pads with
%   false values to make the lengths match ... :/
%
%IDENTIFIER: 'MATLAB:noSuchMethodOrField'
%MESSAGE: No appropriate method, property, or field p for class NEURON.xstim.single_AP_sim.applied_stimulus_matcher.
%
%   Show the properties and methods that are available for the class ...
%
%IDENTIFIER: MATLAB:class:InvalidSuperClass
%MESSAGE: The specified superclass 'NEURON.xstim.single_AP_sim.predictor' contains a parse error or cannot be found on MATLAB's search
%path, possibly shadowed by another file with the same name.
%
%   I renamed a superclass, might provide option to open offending
%   subclass so that the superclass can be reedited
%   
%   
%IDENTIFIER: ????
%MESSAGE: Error using griddedInterpolant The grid vectors are not strictly monotonic increasing.

%Forgot to put varargin in function prototype
%        message: 'Attempt to execute SCRIPT varargin as a function:
% C:\Program Files\MATLAB\R2013a\toolbox\matlab\lang\varargin.m'
%     identifier: 'MATLAB:scriptNotAFunction'
%          stack: [1x1 struct]

