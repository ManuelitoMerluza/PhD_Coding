%             [NAGWare Gateway Generator]
%
%Copyright (c) 1993-94 by the Numerical Algorithms Group Ltd 2.0 
%
%dqtgs
%
%x (1)                                 real
%y (1)                                 real
%idim                                  integer
%s                                     real
%ier                                   integer
%
%[s,ier] = dqtgs(x,y,idim)
%
%
 function [s,ier] = dqtgs(x,y,idim)
%
%
%
%Call the MEX function
%
 [s,ier] = dqtgsg(x,y,idim);
%
