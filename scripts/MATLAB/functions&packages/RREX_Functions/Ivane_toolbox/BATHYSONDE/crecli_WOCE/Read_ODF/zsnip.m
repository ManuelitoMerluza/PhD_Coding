function r = zsnip(s)
% Quote-Delimited Value Retriever
%
%Description: zsnip(s) takes a string which includes an equals sign and floating point
%                        value, and returns only the value.  This function assumes
%                        a closing comma in the string.
%
% Syntax:
%Usage: r = zsnip(s)
%Input:
%s: the string containing the value.
%
%Output:
%r: the floating point output value.
%
%Example:
%
% r = zsnip('this_value=       23.5,')
%
% r =
%
%    23.5
%
%
% Documentation Date: Oct.17,2006 15:44:45
%
% Tags:
% {ODSTOOLS} {TAG}
%
%
%
% Other Notes: This is a low level function used internally in other scripts.
%

e = findstr('=',s);
f = strtok(s((e+1):end), ',');
if ~isempty(f)
   r = str2num(f);
else
   r = [];
end




