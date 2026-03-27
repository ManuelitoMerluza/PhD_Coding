function c2=rmcell(c1,gi2rm)
% KEY: remove the specified indices from c1
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
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Jan 98
%
% SIDE EFFECTS :
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER:
% CALLEE:

if ~iscell(c1)
  c1(gi2rm)=[];
  c2=c1;
else
  n=length(c1);
  gi2put=1:n;
  gi2put(gi2rm)=[];
  c2=c1(gi2put);
end