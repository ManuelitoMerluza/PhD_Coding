function [stat1,stat2,kgv,maxgv,distg,gbot1,gbot2,vel,...
  temp,sali,oxyg,phos,sili]=read_pairdata(...
  hdrfile,npairstd,datafile,ndep,reclen,npair)
% KEY: read some pair data from the fortran binary files
% USAGE : [stat1,stat2,kgv,maxgv,distg,gbot1,gbot2,vel,...
%  temp,sali,oxyg,phos,sili]=read_pairdata(...
%  hdrfile,npairstd,datafile,ndep,reclen,npair)
%
% DESCRIPTION : read the pair data from the direct access
%  files created by geovel. It wants to read all data in
%  the pair data file and will make an error if there is 
%  some more unread data. This is a test to make sure
%  we have the right format. Removes the "bottom" value
%  as it is an extrapolation, not informative
%  and can screw the plots as bottom depths are not standard
%
% INPUT:
%   hdrfile: header file name
%   npairstd  : total number of pairs
%   npair  : total number of pairs (optional,if different for std file)
%   datafile:data file name
%   ndep   : number of standart depths + 1 for the bottom
%   reclen : length of the data records
%
% OUTPUT:
%   [ip is the pair indice]
%   stat1(ip),stat2(ip): indice of stations used
%   kgv(ip) : record number (?)
%   maxgv(ip): indice of the bottom vel/pair data (last std depth)
%   distg(ip): distance between the stations
%   gbot1(ip): depth at the bottom, station1
%   gbot2(ip): depth at the bottom, station2
% 
%   vel(idep,ip): geostrophic velocity, depth indice idep
%   temp,sali,oxyg,phos,sili(idep,ip): property values
%
% AUTHOR : A.Ganachaud (ganacho@gulf.mit.edu) , Jul 96
%
% SIDE EFFECTS :
%
% SEE ALSO : read_stathdr
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLER: general purpose
% CALLEE:

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%READING HEADER FILE
if nargin==5
  npair=npairstd;
elseif nargin~=6
  error('wrong number of argumemts')
end
  
disp(['READING ' hdrfile '...'])
stat1=NaN*ones(npairstd,1);
stat2=NaN*ones(npairstd,1);
kgv=NaN*ones(npairstd,1);
maxgv=NaN*ones(npairstd,1);
distg=NaN*ones(npairstd,1);
gbot1=NaN*ones(npairstd,1);
gbot2=NaN*ones(npairstd,1);

[fid,message]=fopen(hdrfile,'r');
if fid==-1
  error(message)
end
for ip=1:npairstd
  stat1(ip)=fread(fid,1,'long');
  stat2(ip)=fread(fid,1,'long');
  kgv(ip)  =fread(fid,1,'long');
  maxgv(ip)=fread(fid,1,'long');
  distg(ip)=fread(fid,1,'real*4');
  gbot1(ip)=fread(fid,1,'real*4');
  gbot2(ip)=fread(fid,1,'real*4');
end
status=fseek(fid,1,'cof');
if status~=-1
  error('SOME MORE DATA ARE TO BE READ')
end
fclose(fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%READING DATA FILE 
disp(['READING ' datafile '...'])
temp1=NaN*ones(ndep,npair);
sali1=NaN*ones(ndep,npair);
oxyg1=NaN*ones(ndep,npair);
phos1=NaN*ones(ndep,npair);
sili1=NaN*ones(ndep,npair);
vel1 =NaN*ones(ndep,npair);
reclen=reclen/4; %AS WE READ 4bytes at a time

[fid,message]=fopen(datafile,'r');
if fid==-1
  error(message)
end
if reclen ~= (ndep*6)
  error('WRONG VARIABLE ASSIGNMENT: CHECK !!')
end

for ip=1:npair
  record=fread(fid,[reclen],'float32');
  temp(:,ip)=record(1:ndep);
  sali(:,ip)=record(ndep+1:2*ndep);
  oxyg(:,ip)=record(2*ndep+1:3*ndep);
  phos(:,ip)=record(3*ndep+1:4*ndep);
  sili(:,ip)=record(4*ndep+1:5*ndep);
  vel (:,ip)=record(5*ndep+1:6*ndep);
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
vel(ibot) =NaN*ones(size(ibot));

%REMOVES THE VALUES AT THE BOTTOM
%(not on standard depths)
disp('REMOVING BOTTOM VALUES ...');
for ipair=1:npair
  ibotp=maxgv(ipair);
  temp(ibotp,ipair)=NaN;
  sali(ibotp,ipair)=NaN;
  oxyg(ibotp,ipair)=NaN;
  phos(ibotp,ipair)=NaN;
  sili(ibotp,ipair)=NaN;
  vel(ibotp,ipair) =NaN;
end
maxgv=-1+maxgv;
%removes the last row
Md=[1:(size(temp,1)-1)];
  temp=temp(Md,:);
  sali=sali(Md,:);
  oxyg=oxyg(Md,:);
  phos=phos(Md,:);
  sili=sili(Md,:);
  vel=vel(Md,:);
disp('DONE')