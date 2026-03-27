function [ccf]=cohereconf(dfreed)
% KEY: gives the 95% confidence test for coherence calculation (NOT SQUARED COHERENCE)
% USAGE : [ccf]=cohereconf(dfreed)
% 
%
%
%
% DESCRIPTION : 
%
%
% INPUT: dfreed: degrees of freedom
%
% OUTPUT:
%
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Nov 97
%
% SIDE EFFECTS :
%
% SEE ALSO : NAG G13CEF doc
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER:
% CALLEE:
%F-distribution
F=finv(.95,2,dfreed-2);
ccf=sqrt(2*F./(dfreed-2+2*F));