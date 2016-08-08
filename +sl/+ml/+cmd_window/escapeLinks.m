function str_out = escapeLinks(str)
%
%
%

error('Not yet finished')

str_out = str;

%str = '<a href="http://blogs.mathworks.com/community/2007/07/09/printing-hyperlinks-to-the-command-window/">Test </a> asdfasdf adsf asdf asdf asdf asdf adsf asdf asdf asdf'

%http://blogs.mathworks.com/community/2007/07/09/printing-hyperlinks-to-the-command-window/

%'<(\w+).*>.*</\1>'



%NO - capital HREF   
%   str = '<a HREF =   "http://www.google.com">This is a test</a>'
%
%NO - a offset - using an XML parser????
%   str = '< a href="http://www.google.com">This is a test</a>'
%
%NO - extra attribute (rel)
%   str = '<a rel="next"   href =   "http://www.google.com">This is a test</a>'
%
%Bad tag? - 

%Look away, using regular expressions to parse html :/