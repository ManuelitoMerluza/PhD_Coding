function t2=extrapole_ls(p1,t1,p2);
% KEY: extrapolates t2 at points p2 from slope given by (p1,t1)
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
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Nov 97
%
% SIDE EFFECTS :
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER:
% CALLEE:
p1=p1(:);
t1=t1(:);
p2=p2(:);

np1=length(p1);
np2=length(p2);
if np1<1
  error('must have more than two data points to extrapolate !')
end

%find coefficients a,b so that  t1 = a*p1 + b
ab=[p1 ones(np1,1)]\t1;
t2=[p2 ones(np2,1)]*ab;
