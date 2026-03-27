function a = minnan(f)
% Calculates the minimum of the valid elements of a vector.
%
% Description:Calculates the minimum of the valid elements of a vector.
%
%Syntax: A = minnan(F)
%
%Input: F, the vector containing the values of which the minimum is desired, and possibly NaN values.
%Output: A , the minimum of the valid values.
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
%    23
%    22
%
%» a = minnan(f)
%
%a =
%
%    22
%
% Documentation Date: Oct.17,2006 10:48:52
%
% Tags:
% {ODSTOOLS} {TAG}
%
%


try
    a = min(f(find(~isnan(f))))';
catch
    a = NaN;
end
