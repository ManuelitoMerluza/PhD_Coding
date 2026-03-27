function [iyr,mon,iday,ihr,ylat,xlon1,xlon2,taux,tauy]=...
            readekfile(rec2get,reclen,fid)
% KEY: read Ekman files
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
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , May 97
%
% SIDE EFFECTS :
%
% SEE ALSO :
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER:
% CALLEE:

%allocates memory for records
 %gets number of longitude points:
 status=fseek(fid,28,'bof');
 nx=fread(fid,1,'int');
 nr=length(rec2get);
 taux=NaN*ones(nx,nr);
 tauy=NaN*ones(nx,nr);
 iyr=NaN*ones(nr,1);
 mon=NaN*ones(nr,1);
 iday=NaN*ones(nr,1);
 ihr=NaN*ones(nr,1);
 ylat=NaN*ones(nr,1);
 xlon1=NaN*ones(nr,1);
 xlon2=NaN*ones(nr,1);
 
 
for irec=1:length(rec2get)
  status=fseek(fid,reclen*(rec2get(irec)-1),'bof');
  
  [git,nit]=fread(fid,4,'int');
  iyr(irec)=git(1);
  if round(iyr)~=iyr
    error('Wrong record position (check reclen)')
  end
  mon(irec)=git(2);
  iday(irec)=git(3);
  ihr(irec)=git(4);
  
  [xl,nxl]=fread(fid,3,'float');
  ylat(irec) =xl(1);
  xlon1(irec)=xl(2);
  xlon2(irec)=xl(3);
  
  nx=fread(fid,1,'int');

  taux(:,irec)=fread(fid,nx,'float');
  [tauy(:,irec),ct]=fread(fid,nx,'float');
  if ~ct
    error('Unexpected end of file')
  end

end %for irec
