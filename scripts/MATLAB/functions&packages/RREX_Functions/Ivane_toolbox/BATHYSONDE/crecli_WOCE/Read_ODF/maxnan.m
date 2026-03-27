function a = maxnan(f)
% Calculates the maximum of the valid elements of a vector.
%
% Description:Calculates the maximum of the valid elements of a vector.
%
% Syntax: A = maxnan(F)
%
%Input: F, the vector containing the values of which the maximum is desired, and possibly NaN values.
%Output: A , the maximum of the valid values.
%
%Example:
%» f
%
%f =
%
%    23
%    23
%   NaN
%   NaN
%    24
%    22
%
%» a = maxnan(f)
%
%a =
%
%    24
%
% Documentation Date: Oct.17,2006 10:43:02
%
% Tags:
% {ODSTOOLS} {TAG}
try
    a = max(f(find(~isnan(f))))';
catch
    a = NaN;
end
