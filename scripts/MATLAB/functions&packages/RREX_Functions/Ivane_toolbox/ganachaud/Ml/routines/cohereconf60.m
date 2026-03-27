function [ccf]=cohereconf60(dfreed)
% KEY: gives the 60% confidence test for coherence calculation (NOT SQUARED COHERENCE)
% USAGE : [ccf]=cohereconf60(dfreed)
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
F=finv(.60,2,dfreed-2);
ccf=sqrt(2*F./(dfreed-2+2*F));