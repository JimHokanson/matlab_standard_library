## JSON Support ##

Currently I've only focused on reading JSON. There are a decent number of JSON submissions for Matlab. This is one case in which having a nice comparison framework would be quite useful, as I'm not really sure how the submissions perform relative to each other. In addition, because of Matlab's scalar vs vector ambiguity (i.e. a scalar is a vector of size 1x1), writeJSON(readJSON("data")) may not yield "data."

## Improvements ##
1. Create a testing framework for JSON decoding and performance comparison
2. Create a method for injecting values into JSON to maintain structure

## FEX Submissions ##

Not yet completed ...

- http://www.mathworks.com/matlabcentral/fileexchange/33381-jsonlab-a-toolbox-to-encodedecode-json-files-in-matlaboctave
- http://www.mathworks.com/matlabcentral/fileexchange/25713
- http://www.mathworks.com/matlabcentral/fileexchange/23393-another-json-parser
  - (another) JSON Parser
- http://www.mathworks.com/matlabcentral/fileexchange/20565-json-parser
  - JSON Parser
  - obsolete, use "(another) JSON Parser" instead
  - Author: Joel Feenstra
  - Created: 2008-07-03
  - Updated: 2009-06-18
