function C=integz(A,dz)
% KEY: integrate the A(m,n) matrix columns using vertical interval dz(m)
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
% OUTPUT: C=vector of integrated columns
%
% AUTHOR : A.Ganachaud (ganacho@ifremer.fr) , Sept 00
%
% SIDE EFFECTS :
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER:
% CALLEE:
C=sum(A.*(dz(:)*ones(1,size(A,2))));