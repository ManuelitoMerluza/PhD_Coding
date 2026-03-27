function [ccfp]=coherephaseconf(dfreed,coh)
% KEY: gives the 95% confidence for phase in spectral analysis
% USAGE : [ccf]=coherephaseconf(dfreed,coh)
%
% DESCRIPTION : 
%
%
% INPUT: dfreed: degrees of freedom (number of points)
%
% OUTPUT:
%
% AUTHOR : A.Ganachaud (ganacho@notos.cst.cnes.fr) , 2002
%
% SIDE EFFECTS :
%
% SEE ALSO : Bloomfield, 1976, p.225
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER:
% CALLEE:
g=1/sqrt(dfreed);

ccfp=1.96*g*sqrt(0.5*(1./abs(coh(:)).^2-1));
%in radian

%? close at xp=.95; give imaginary results dfreed<3
%x2=asin(tinv(xp,2./g.^2-2)*...
%  sqrt(g.^2./(2*(1-g.^2))*(1./coh(:).^2-1)));
%x2=asin(tinv(0.5*(1+xp),2./g.^2-2)*...
%  sqrt(g.^2./(2*(1-g.^2))*(1./coh(:).^2-1)));
