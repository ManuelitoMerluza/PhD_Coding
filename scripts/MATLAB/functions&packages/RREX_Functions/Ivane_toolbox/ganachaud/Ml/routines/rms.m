function sig2=rms(x,rowcol);
% KEY: returns the rms value of the signal x
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
%disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
%disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
%disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
%disp('!!!! RMS CHANGED TO RETURN THE SQUARE ROOT !!!!')
%disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
%disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
%disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
if ~exist('rowcol')
  n=size(x,1);
  if n==1
    n=size(x,2);
  end
  sig2=sqrt(sum(abs(x).^2)/n);
else
  n=size(x,rowcol);
  sig2=sqrt(sum(abs(x).^2,rowcol)/n);
end
  