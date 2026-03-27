function cval=getcint(z,int_type,nvcint)
% KEY: returns a contour interval, given the number of contours
% USAGE : cval=getcint(z,int_type,nvcint)
% 
% INPUT: z: property
%        int_type: 'nint' : number of contours is specified
%                  'intv' : value of contour interval "
%
% OUTPUT:
%
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Nov 96
%
% SIDE EFFECTS :
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER:
% CALLEE:
zmx=mmax(mmax(z)');
zmn=mmin(mmin(z)');
span=(zmx-zmn);

if strcmp(int_type,'nint')
  expon=fix(log10(span/nvcint));
  cint=round(span/nvcint*10^(-expon))*10^expon;

elseif strcmp(int_type,'intv')
  cint=nvcint;
end

if zmx>0 & zmn<0
  %THEN CONTOURS ARE CENTERED ON ZERO
  %number of positive contours
  %npc=round(zmx/span*nvcint);
  
  %number of negative contours
  %nnc=round(-zmn/span*nvcint);
  
  cvalp=0:cint:zmx;
  cvaln=reverse(-cint:-cint:zmn);
  cval=[cvaln,cvalp];
  
else
  %FIND A ROUND NUMBER TO START
  expon=fix(log10(zmn));
  cstart=floor(zmn*10^(1-expon))*10^(expon-1);
  
  cval=cstart:cint:zmx;
end
  
  
  