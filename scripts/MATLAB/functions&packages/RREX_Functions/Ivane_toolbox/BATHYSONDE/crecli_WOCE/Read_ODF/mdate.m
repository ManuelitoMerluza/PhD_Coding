function V = mdate(R)
% Converts a six-column date/time vector into an ODF SYTM date/time string.
%
% Description:
% Converts a six-column date/time vector into an ODF SYTM date/time string.
%
% Syntax:
% Usage: V = mdate(R)
% Input:
% R : six-column date vector [yyyy mm dd hh mm ss]
% Output:
% V : character array containing SYTM/ODF date string.
% Example:
%
% » mdate([1994 3 23 11 42 23.2])
%
%  ans =
%
%  23-MAR-1994 11:42:23.20
%
% Documentation Date: Oct.17,2006 10:45:42
%
% Tags:
% {ODSTOOLS} {TAG}
%
%
%


R = gregorian(julian(R));
[r,c] = size(R);
V = zeros(r,23);
V = char(V);

mon = (['JAN';'FEB';'MAR';'APR';'MAY';'JUN';'JUL';'AUG';'SEP';'OCT';'NOV';'DEC']);
for i = (1:r)
   V(i,:) = sprintf('%02d-%s-%04d %02d:%02d:%05.2f',R(i,3),mon((R(i,2)),:),R(i,1),R(i,4),R(i,5),R(i,6));
end


