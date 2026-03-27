function sig2=mrms(x);
% KEY: returns the rms value of the signal x NaN excluded
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
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Nov 95
%
% SIDE EFFECTS :
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER: general purpose
% CALLEE:
  n=size(x,1);
  if n==1
    n=size(x,2);
  end
  for ic=1:size(x,2)
    gigood=find(~isnan(x(:,ic)));
    sig2(ic)=sqrt(sum(abs(x(gigood,ic)).^2)/n);
  end
