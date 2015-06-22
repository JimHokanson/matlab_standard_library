function output_string = decodeJavaString(input_string)
%
%
%   output_string = sl.str.decodeJavaString(input_string)
%
%   Example:
%
%   input_string  = 'impedance of \u223c200 k\u03a9 in vitro';
%   output_string = 'impedance of ?200 k? in vitro'


%TOD: Ensure no escape characters
%char(org.apache.commons.lang.StringEscapeUtils.unescapeJava(str));

if isempty(input_string)
    output_string = '';
else
   I = strfind(input_string,'\u');
   if isempty(I)
       output_string = input_string;
   else
       output_string = sl.str.javaStringToChar(org.apache.commons.lang.StringEscapeUtils.unescapeJava(input_string)); 
   end
end