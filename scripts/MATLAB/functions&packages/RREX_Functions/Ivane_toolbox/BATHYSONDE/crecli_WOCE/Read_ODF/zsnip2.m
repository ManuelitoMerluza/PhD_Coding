function r = zsnip2(s)
% Quote-Delimited Value Retriever
%
%Description: zsnip2(s) takes a string which includes an equals sign and floating point
%                  value, and returns only the value. The difference is that zsnip2 does
%                  not assume a closing comma.
%
% Syntax:
%Usage: r = zsnip2(s)
%
%Input:
%s: the string containing the value.
%
%Output:
%r: the floating point output value.
%
%       Example:
%
% r = zsnip2('this_value=       46.86')
%
% r =
%
%    46.86
%
%
% Documentation Date: Oct.17,2006 15:45:11
%
% Tags:
% {ODSTOOLS} {TAG}
%
%
%
% Other Notes: This is a low level function used internally in other scripts.
%

e = findstr('=',s);

r = str2num(s((e+1):end));



