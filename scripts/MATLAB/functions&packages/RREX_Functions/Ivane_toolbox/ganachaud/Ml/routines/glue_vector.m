function c=glue_vector(a,b);
% KEY: gule the vector to the matrix a
% USAGE : c=glue_vector(a,b)
% 
%
%
%
% DESCRIPTION : the size of the matrix a is changed if necessary
%
%
% INPUT:
%
% OUTPUT:
%
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Jul 96
%
% SIDE EFFECTS :
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER: general purpose
% CALLEE:

szb=size(b);

if szb(2)==1 %append a row at the bottom of the matrix
  lenb=szb(1);
  a=a';
  b=b';
  switchon=1;
elseif szb(1)~=1
  error('Argument 2 must be a vector')
else
  disp('k')
  lenb=szb(2);
  switchon=0;
end
sza=size(a);
  
  ncols2add=lenb-sza(2);
  if ncols2add > 0 % add zero columns to the matrix
    zerocols=zeros(sza(1),ncols2add);
    a=[a,zerocols];
    
  elseif ncols2add < 0 %add zeros at the end of the vector
    b=[b,zeros(1,-ncols2add)];
  end
  c=[a;b];
  
if switchon
  c=c';
end