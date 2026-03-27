function whydro(prop,fname,precision,maxd,ovw)
% KEY: read the information contained in file fname
% USAGE : whydro(prop,fname,precision,maxd,ovw)
%
% DESCRIPTION : 
%
%   write the property prop
%   in binary file 'fname'
%   at precision 'precision'
%
% INPUT:
%
%  prop: the data (property) to write
%  fname: name of the file to write 
%  precision: 'float32','integer', ... type "help fread"
%  maxd (1:N) optionnal. if given, set prop(i,j) to 0 if i>Maxd(j)
%             for bottom values if the data are hydrographic
%             (the 0 will be easy to compress ...)
%  ovw: overwrite if not zero. 
%       if ovw does not exist, check if the file is there
%       and ask if overwrite or not
%
% OUTPUT: the data file (sequential binary, Fortran convention)
%
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Nov 95
%
% SIDE EFFECTS :
%
% SEE ALSO : rhydro
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER: general purpose 
% CALLEE: ffwrite

sz=size(prop);
M=sz(1);
N=sz(2);

if nargin>=4
  for is=1:N
    iground=(maxd(is)+1:M)';
    prop(iground,is)=0*ones(size(iground));
  end
end


precision=deblank(precision);
fname=deblank(fname);
im='y';

if nargin<5 | (nargin==5 & ovw==0)%ask overwrite/no
  if exist(fname)==2
    im=input(['overwrite ' fname ' (y/n) ? '],'s');
    %menu(['overwrite ' fname ' ? '],'YES','NO');
  else
    im='y';
  end
end

if im(1)=='y'
  ufi=fopen(fname,'w','ieee-be');
  ffwrite(ufi,prop,precision);
  fclose(ufi);
  disp(['wrote ' fname])
else
  disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
  disp([fname ' already exist: not written'])
  disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
end  
