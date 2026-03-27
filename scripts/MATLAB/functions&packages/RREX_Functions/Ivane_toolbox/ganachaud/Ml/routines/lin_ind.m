function ii=lin_ind(M,N,i,j);
% KEY: returns the vector indice of an element (i,j) 
%       in a matrix: ii = M*(j-1)+i;
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
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Jan 96
%
% SIDE EFFECTS :
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER:
% CALLEE:

if any(i>M)
  error('i>M')
end
if any(j>N)
  error('j>N')
end
ii=[];

for jj=j
  ii=[ii, M*(-1+jj) + i];
end

