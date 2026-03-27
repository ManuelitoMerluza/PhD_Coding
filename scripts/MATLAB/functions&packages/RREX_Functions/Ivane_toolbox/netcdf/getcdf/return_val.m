function y = return_val(s, x)

%--------------------------------------------------------------------
%     Copyright (C) J. V. Mansbridge, CSIRO, 
%     Revision $Revision: 1.2 $
% CHANGE   1.1 92/01/30
%
% function y = return_val(s, x)
%
% DESCRIPTION:
%
% return_val prints out the string s to prompt the user to make a
% keyboard input.  The type of x determines whether the input will be
% interpreted as a string or a matrix of numbers.  This input is
% returned by return_val unless the user hits the carriage return in
% which case the default (x) is returned.
% 
% INPUT:
% s is a string that is written to the user's terminal as a prompt.
% x is the default string or matrix of numbers that is returned if the
% user simply hits the carriage return.
%
% OUTPUT:
% y is the returned value.  It is either the input value or the
% default (x).
%
% EXAMPLE:
% y = return_val('Type in the ocean depth in metres [6000] ...', 6000);
%
% CALLER:   getcdf.m
% CALLEE:   none
%
% AUTHOR:   J. V. Mansbridge, CSIRO
%---------------------------------------------------------------------

%     Copyright (C), J.V. Mansbridge, 
%     Commonwealth Scientific and Industrial Research Organisation
%     Revision $Revision: 1.2 $
%     Author   $Author: mansbrid $
%     Date     $Date: 1993/08/17 11:14:52 $
%     RCSfile  $RCSfile: return_val.m,v $
% @(#)return_val.m   1.1   92/01/30
% 
%--------------------------------------------------------------------

if isstr(x)
  xtemp = input(s, 's');
else
  xtemp = input(s);
end
if isempty(xtemp)
   y = x;
else
   y = xtemp;
end
