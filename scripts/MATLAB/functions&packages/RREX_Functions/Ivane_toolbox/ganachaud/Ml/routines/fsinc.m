function y=fsinc(x,lx)
% KEY: tapered cardinal sinc filter with hamming window
% USAGE : y=fsinc(x,lx)
% 
% DESCRIPTION : 
%   ysin(x)/x *(0.54+0.46 cos x/max(x))
%
% INPUT: 
%
%
% OUTPUT:
%
% AUTHOR : A.Ganachaud (ganacho@ifremer.fr) Oct 2001
%
% SIDE EFFECTS :
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER:
% CALLEE:
y= 2*sinc(2*x).*(0.54+0.46*cos(pi*x/max(x)));
