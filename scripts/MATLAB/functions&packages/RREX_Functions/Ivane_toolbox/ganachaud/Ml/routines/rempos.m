function ip=rempos(ii,M)
% KEY: computes the POSITIVE reminder (see rem)
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
% OUTPUT:
%
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , May 96
%
% SIDE EFFECTS :
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER: general purpose
% CALLEE: rem

ip=rem(ii,M);
ineg=find(ip<0);
ip(ineg)=M+ip(ineg);
