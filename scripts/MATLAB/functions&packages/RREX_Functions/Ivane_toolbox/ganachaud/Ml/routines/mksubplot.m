function [hdl]=mksubplot(m,n,i)
% KEY: find correct plot i in the m,n subplot configuration
% USAGE :
% 
%
%
%
% DESCRIPTION : 
%
%
% INPUT: 
%
%
% OUTPUT:
%
% AUTHOR : A.Ganachaud (ganacho@noumea.ird.nc) Feb. 2003
%
% SIDE EFFECTS :
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER:
% CALLEE:
if mod(i,m*n)==1
  i=1;
  figure;gcf
else
  i=1+mod(i-1,m*n);
end
hdl=subplot(m,n,i);