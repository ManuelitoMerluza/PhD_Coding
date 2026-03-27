function ddate = julian2datenum(jdate);
% Converts a Julian-format date number to a DATENUM-format date number.
% 
% Description:
% Converts a Julian-format date number to a DATENUM-format date number.
% 
% Syntax: 
% ddate = julian2datenum(jdate);
%
% jdate : julian date number array
% ddate : datenum date number array
%
% Documentation Date: May.04,2007 14:01:22
% 
% Tags:
% {TAG} {TAG} {TAG}
% 
% 

offset = julian([ 2000 1 1 0 0 0])-datenum([2000 1 1 0 0 0]);

ddate = jdate-offset;