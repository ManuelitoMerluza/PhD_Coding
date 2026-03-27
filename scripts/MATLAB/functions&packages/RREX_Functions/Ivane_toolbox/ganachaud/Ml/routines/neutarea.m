%  neutarea.m
%  Purpose: find the area of neutral surfaces between sections (in m^2)
%  uses Levitus data
%  saves output areas, long. and lat. limits, and gamma surf. inputs into
%    ascii file of the form OPdir/'boxi_'Secnames'.harea'
%  (NOTE: Lats. should be taken from [-89.5:89.5])
%  (NOTE: Lons. should be taken from [0.5:359.5])
%  Chris Holloway, 8/11/99
%  CALLER: General Purpose
%  CALLEE: readlev.m
%% Parameters: p_readlev, Secnames, IPdir (for Levitus data files), OPdir,
% nolat, solat, welon, ealon, gamint (gamma surface values at which to find 
% areas)

%% Read Levitus Data (if not already loaded);
p_readlev=0;

%% Sections on either side of area box
Secnames='P12_P6_A21';
 
%% Input Directory for Levitus Data:
IPdir='/data4/chollow/Area/';

%% Output Directory for ascii files
OPdir='/data4/chollow/Area/';

%% Northern Latitude limit (NOTE: Lats. should be taken from [-89.5:89.5])
nolat=-32.5;

%% Southern Latitude limit
solat=-79.5;

%% Western Longitude limit (NOTE: Lons. should be taken from [0.5:359.5]) 
welon=143.5;

%% Eastern Longitude limit 
ealon=291.5;


%% Neutral Density surface(s) (gamma(s)) desired for area(s)
%% Corresponds to 'boxi.glevels'
%% Input of 0 returns entire ocean surface area enclosed
gamint=[0 26.2 26.8 27.32 27.57 27.72 27.903 ...
      28.03 28.07 28.15 28.20 28.23 28.25 28.27 28.296];

%% Read Levitus annual data
if p_readlev
  readlev
end

if (~any(llat==nolat)) | (~any(llat==solat)) 
  error('Lat. limits must be within [-89.5:89.5]')
elseif (~any(llon==welon)) | (~any(llon==ealon)) 
  error('Long. limits must be within [0.5:359.5]')
end
lat1=find(llat==solat);
lat2=find(llat==nolat);
lon1=find(llon==welon);
lon2=lon1;
lon3=lon1+1;
lon4=find(llon==ealon);
nlat=1+nolat-solat;
nlon=1+ealon-welon;
if ealon<welon
  lon2=360;
  lon3=1;
  nlon=2+lon4-lon3+lon2-lon1;
end
jlon=[lon1:lon2,lon3:lon4];
[scanlon]=scan_longitude(llon(jlon));
for i=1:nlat
  lpres=sw_pres(ldep',solat-1+i);
  ttemp=ones(nlon,length(lpres));
  tsali=ones(nlon,length(lpres));
  gsig=NaN*ones(nlon,length(gamint));
  for j=1:nlon
    ttemp(j,:)=ltemp(jlon(j),lat1-1+i,:);
    tsali(j,:)=lsali(jlon(j),lat1-1+i,:);
  end  %for j=1:nlon
  [gamma,dg_lo,dg_hi]= ...
    gamman(tsali',ttemp',lpres,scanlon, ...
    llat(lat1-1+i)*ones(1,nlon));
  for ig=1:length(gamint)
    [ag,bg]=find(gamma>=gamint(ig));
    bg=sort(bg); bg=bg(find(diff(bg)>=1));
    gsig(bg,ig)=1;
    if gamint(ig)==0
      disp('Finding Surface Area for Gamma==0')
    else
      gsig(find(gamma(1,:)>gamint(ig)),ig)=NaN;  %test for outcropping
    end
  end
  eval([sprintf('gsig%i',i) ' = gsig;']);
  eval([sprintf('gamma%i',i) ' = gamma;']);
end  %for i=1:nlat
areavec=ones(1,length(gamint));
for ig=1:length(gamint)
  maplogic=zeros(nlat,nlon);
  for i=1:nlat
    eval(['maplogic(i,find(~isnan(' sprintf('gsig%i',i) '(:,ig))))=1;']);
  end  
  maplegend=[1 nolat welon]; %1 is for matrix cells per degree lat. & long.  
  areavec(ig)=areamat(maplogic,maplegend,almanac('earth','geoid','m')); 
end  %for ig=1:length(gamint)
  
areavec
disp('Saving Areas in ascii file')
file=sprintf('%sboxi_%s.harea',OPdir,Secnames);
if exist(file)==2
  cont=1;
  while cont==1
    q=input('This harea File Already Exists; Overwrite It? (y/n)','s');
    if (q=='y') | (q=='yes')
      cont=0;
    elseif (q=='n')
      error('DID NOT SAVE AREAS')
    end
  end
end
fid=fopen(file,'w');
fprintf(fid,'boxi.harea = [ ');
  fprintf(fid,'%3.3g ',areavec);
  fprintf(fid,'];\n');
fprintf(fid,'\n');
fprintf(fid,'Latitude Limits = [ ');
  fprintf(fid,'%g %g ];\n',solat,nolat);
fprintf(fid,'Longitude Limits = [ ');
  fprintf(fid,'%g %g ];\n',welon,ealon);
fprintf(fid,'Gamma Surfaces Taken at: [ ');
  fprintf(fid,'%g ',gamint);
  fprintf(fid,'];\n');






