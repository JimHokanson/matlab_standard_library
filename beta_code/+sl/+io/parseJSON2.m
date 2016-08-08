function parseJSON2(str)
%
%
%   Other Matlab JSON parsers appear to be really slow. I have some ideas
%   on how to make this much faster.
%
%   Documentation: http://www.json.org/
%   
%   {} - object
%       unordered set of name/value pairs -> like a struct
%   
%   {"forename":"R.","surname":"Hamming"}
%
%   -> 
%       ans = 
%           forename: 'R.'
%       surname: 'Hamming'
%
%   [] - ordered collection of values    
%   

%Special_characters:
%----------------------------------------------------
%{ } - object start/end
%:  -> string : value
%,  -> 

%Objects identified by:
%----------------------------------------

cur_parent_index = 0;
depth = 1;

%Types:
%----------------------
%1) Object
%2) Array
%3) Number
%4) String