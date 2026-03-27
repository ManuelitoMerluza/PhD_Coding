function prop=rhydro(fname,precision,M,N,maxd,iprop)
% KEY: read the information contained in file fname
% USAGE : prop=rhydro(fname,precision,M,N,maxd,iprop)
%
% DESCRIPTION : 
%
%   parameter 'iprop' is obsolete. Do not use anymore
%   read the property ( any data )
%   in binary file 'fname'
%   with format:  M x N
%   at precision 'precision'
%
% INPUT:
%
%  fname: name of the file to read (sequential binary, Fortran convention)
%  precision: 'float32','integer', ... type "help fread"
%  M: number of rows
%  N: number of columns
%  maxd (1:N) optionnal. if given, set prop(i,j) to NaN if i>Maxd(j)
%             for bottom values if the data are hydrographic
%
%  iprop: no longer used (only for compatibility, will be removed)
%
% OUTPUT: the data, prop(MxN)
%    set to NaN the values under indice maxd (Max depth)
%
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Oct 95
%
% SIDE EFFECTS :
%
% SEE ALSO : whydro
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER: general purpose 
% CALLEE: ffread

if nargin==6
  fname=fname(iprop,:);
  precision=precision(iprop,:);
end
precision=deblank(precision);
fname=deblank(fname);
if isempty(fname)
  prop=NaN*ones(M,N);
  disp(sprintf('Returning no data for property %i',iprop))
else
  ufi=fopen(fname,'r','ieee-be');
  prop=ffread(ufi,[M,N],precision);
  fclose(ufi);
  
  if nargin==5
    for is=1:N
      iground=(maxd(is)+1:M)';
      prop(iground,is)=NaN*ones(size(iground));
    end
  end
  
  gibad=find(prop==-999|prop==-9999);
  prop(gibad)=NaN;
end