function r = zclip2(s)
% Non-quote Delimited Field Retriever
%
%
%Description: Quote-Delimited Field Retriever. This is a utility function that would not normally
%            be called directly by a user.
%
% Syntax:
%Usage: r = zclip2(s)
%
%Input:
%s : string which contains fieldname, an equals sign and one or more values.
%
%Output:
%r : a string that represents the value portion of the input string.
%
%Example:
%» r=zclip2('the_answer= 2.3322 -223.3 -5556664.2,')
%
%r =
%
% 2.3322 -223.3 -5556664.2
%
%
% Documentation Date: Oct.17,2006 15:43:24
%
% Tags:
% {ODSTOOLS} {TAG}
%
%


e = findstr('=',s);
r = s((e+1):end);
r= strtok(r,',');
%empty string fix March 16, 2001 DFSK
if isempty(r)
   r = [' '];
end


