function [dynh,temp,sali,oxyg,phos,sili,nita]=read_statdata(...
  nstat,datafile,ndep,reclen,p_dynh,nvar)
% KEY: read some stat data from the fortran binary files
% USAGE : [dynh,temp,sali,oxyg,phos,sili,nita]=read_statdata(...
%  nstat,datafile,ndep,reclen,p_dynh,nvar)
% 
% DESCRIPTION : read the stat data from the direct access
%  files created by mergech. It wants to read all data in
%  the stat data file and will make an error if there is 
%  some more unread data. This is a test to make sure
%  we have the right format. 
%  
% INPUT:
%   hdrfile: header file name
%   nstat  : total number of stats
%   datafile:data file name
%   ndep   : number of standart depths
%   reclen : length of the data records
%   p_dynh : CDT data (dynamic height present)
%   nvar   : number of variables without dynamic height
%
% OUTPUT:
%   [ip is the stat indice]
%   stat1(ip),stat2(ip): indice of stations used
% 
%   dynh(idep,ip): dynamic height, depth indice idep
%   temp,sali,oxyg,phos,sili(idep,ip),nita: property values
%
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Jan 97
%
% SIDE EFFECTS :
%
% SEE ALSO : read_stathdr
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER: general purpose
% CALLEE:

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%READING DATA FILE 
disp(['READING ' datafile '...'])
temp=NaN*ones(ndep,nstat);
sali=NaN*ones(ndep,nstat);
oxyg=NaN*ones(ndep,nstat);
phos=NaN*ones(ndep,nstat);
sili=NaN*ones(ndep,nstat);
if nvar==6 %include nitaate
  nita=NaN*ones(ndep,nstat);
end
dynh=NaN*ones(ndep,nstat);
reclen=reclen/4; %AS WE READ 4bytes at a time

[fid,message]=fopen(datafile,'r');
if fid==-1
  error(message)
end
if reclen ~= (ndep*(nvar+p_dynh))
  error('WRONG VARIABLE ASSIGNMENT: CHECK !!')
end

for is=1:nstat
  record=fread(fid,[reclen],'float32');
  temp(:,is)=record(1:ndep);
  sali(:,is)=record(ndep+1:2*ndep);
  oxyg(:,is)=record(2*ndep+1:3*ndep);
  phos(:,is)=record(3*ndep+1:4*ndep);
  sili(:,is)=record(4*ndep+1:5*ndep);
  if nvar==6 %include nitrate
    nita(:,is)=record(5*ndep+1:6*ndep);
  end
  if p_dynh
    dynh(:,is)=record(nvar*ndep+1:(nvar+1)*ndep);
  end
end
%CHECK FOR END OF FILE
status=fseek(fid,1,'cof');
if status~=-1
  error('SOME MORE DATA ARE TO BE READ')
end
disp('CHECK DATA ASSIGNMENT !')  
fclose(fid);

%FILL BOTTOM VALUES WITH NaN's:
ibot=find(sali==0); %salt is null -> ground
temp(ibot)=NaN*ones(size(ibot));
sali(ibot)=NaN*ones(size(ibot));
oxyg(ibot)=NaN*ones(size(ibot));
phos(ibot)=NaN*ones(size(ibot));
sili(ibot)=NaN*ones(size(ibot));
nita(ibot)=NaN*ones(size(ibot));
dynh(ibot) =NaN*ones(size(ibot));

disp('DONE')