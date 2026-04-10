%
% Script permettant de comparer les données ERAINTERIM avec les données
% NCEP.
%
addpath(genpath('C:/Users/mitg1n25/Desktop/PhD/PhD_Coding'))

lon = ncread('../DATA/1980/data1980_skt.nc','longitude');
lat = ncread('../DATA/1980/data1980_skt.nc','latitude');
skt = ncread('../DATA/1980/data1980_skt.nc','skt'); 
lon_ncep = ncread('/home5/pharos/REFERENCE_DATA/NCEP/DATA/NCEP1/6h/land.sfc.gauss.nc','lon');
lat_ncep = ncread('/home5/pharos/REFERENCE_DATA/NCEP/DATA/NCEP1/6h/land.sfc.gauss.nc','lat');
skt_ncep1 = ncread('/home5/pharos/REFERENCE_DATA/NCEP/DATA/NCEP1/6h/skt.sfc.gauss.1980.nc','skt'); 

skt = mean(skt,3); % moyenne annuelle
skt_ncep1 = mean(skt_ncep1,3); % moyenne annuelle

figure
pcolor(lon,lat,skt');
shading flat;
colorbar;
v=caxis;

figure;
pcolor(lon_ncep,lat_ncep,skt_ncep1');
shading flat;
colorbar;
caxis(v);


lon = ncread('../DATA/1980/data1980_sshf.nc','longitude');
lat = ncread('../DATA/1980/data1980_sshf.nc','latitude');
sshf = ncread('../DATA/1980/data1980_sshf.nc','sshf'); % en J/m²
lon_ncep = ncread('/home5/pharos/REFERENCE_DATA/NCEP/DATA/NCEP1/6h/land.sfc.gauss.nc','lon');
lat_ncep = ncread('/home5/pharos/REFERENCE_DATA/NCEP/DATA/NCEP1/6h/land.sfc.gauss.nc','lat');
sshf_ncep1 = ncread('/home5/pharos/REFERENCE_DATA/NCEP/DATA/NCEP1/6h/shtfl.sfc.gauss.1980.nc','shtfl'); % en W/m²

sshf = mean(sshf,3); % moyenne annuelle
sshf_ncep1 = mean(sshf_ncep1,3); % moyenne annuelle

sshf = -sshf/(86400/2); % Les champs ERA rapatries ont un step (pas) de 12h.
                        % Pour des champs avec un step/pas de 6h, il faut
                        % diviser par (86400/4) = 6h.

figure
pcolor(lon,lat,sshf');
shading flat;
colorbar;
v=caxis;

figure;
pcolor(lon_ncep,lat_ncep,sshf_ncep1');
shading flat;
colorbar;
caxis(v);

clear all;

lon = ncread('../DATA/1980/data1980_slhf.nc','longitude');
lat = ncread('../DATA/1980/data1980_slhf.nc','latitude');
slhf = ncread('../DATA/1980/data1980_slhf.nc','slhf'); % en J/m²
lon_ncep = ncread('/home5/pharos/REFERENCE_DATA/NCEP/DATA/NCEP1/6h/land.sfc.gauss.nc','lon');
lat_ncep = ncread('/home5/pharos/REFERENCE_DATA/NCEP/DATA/NCEP1/6h/land.sfc.gauss.nc','lat');
slhf_ncep1 = ncread('/home5/pharos/REFERENCE_DATA/NCEP/DATA/NCEP1/6h/lhtfl.sfc.gauss.1980.nc','lhtfl'); % en W/m²

slhf = mean(slhf,3); % moyenne annuelle
slhf_ncep1 = mean(slhf_ncep1,3); % moyenne annuelle

slhf = -slhf/(86400/2); % Les champs ERA rapatries ont un step (pas) de 12h.

figure
pcolor(lon,lat,slhf');
shading flat;
colorbar;
v=caxis;
figure;
pcolor(lon_ncep,lat_ncep,slhf_ncep1');
shading flat;
colorbar;
caxis(v);

clear all;
%close all;
lon = ncread('../DATA/1980/data1980_ssr.nc','longitude');
lat = ncread('../DATA/1980/data1980_ssr.nc','latitude');
slhf = ncread('../DATA/1980/data1980_ssr.nc','ssr');%-ncread('data1980_downward.nc','ssrd'); % en J/m²
lon_ncep = ncread('/home5/pharos/REFERENCE_DATA/NCEP/DATA/NCEP1/6h/land.sfc.gauss.nc','lon');
lat_ncep = ncread('/home5/pharos/REFERENCE_DATA/NCEP/DATA/NCEP1/6h/land.sfc.gauss.nc','lat');
slhf_ncep1 = ncread('/home5/pharos/REFERENCE_DATA/NCEP/DATA/NCEP1/6h/uswrf.sfc.gauss.1980.nc','uswrf')-ncread('/home5/pharos/REFERENCE_DATA/NCEP/DATA/NCEP1/6h/dswrf.sfc.gauss.1980.nc','dswrf'); 
slhf = mean(slhf,3); % moyenne annuelle
slhf_ncep1 = mean(slhf_ncep1,3); % moyenne annuelle

slhf = -slhf/(86400/2); % /2 ?

figure
pcolor(lon,lat,slhf');
shading flat;
colorbar;
v=caxis;

figure;
pcolor(lon_ncep,lat_ncep,slhf_ncep1');
shading flat;
colorbar;
caxis(v);


%clear all;
%%close all;
lon = ncread('../DATA/1980/data1980_str.nc','longitude');
lat = ncread('../DATA/1980/data1980_str.nc','latitude');
slhf = ncread('../DATA/1980/data1980_str.nc','str');%-ncread('data1980_downward.nc','strd'); % en J/m²
lon_ncep = ncread('/home5/pharos/REFERENCE_DATA/NCEP/DATA/NCEP1/6h/land.sfc.gauss.nc','lon');
lat_ncep = ncread('/home5/pharos/REFERENCE_DATA/NCEP/DATA/NCEP1/6h/land.sfc.gauss.nc','lat');
slhf_ncep1 = ncread('/home5/pharos/REFERENCE_DATA/NCEP/DATA/NCEP1/6h/ulwrf.sfc.gauss.1980.nc','ulwrf')-ncread('/home5/pharos/REFERENCE_DATA/NCEP/DATA/NCEP1/6h/dlwrf.sfc.gauss.1980.nc','dlwrf'); 
slhf = mean(slhf,3); % moyenne annuelle
slhf_ncep1 = mean(slhf_ncep1,3); % moyenne annuelle

slhf = -slhf/(86400/2); 

figure
pcolor(lon,lat,slhf');
shading flat;
colorbar;
v=caxis;

figure;
pcolor(lon_ncep,lat_ncep,slhf_ncep1');
shading flat;
colorbar;
caxis(v);

clear all;
%close all;
lon = ncread('../DATA/1980/data1980_ewss.nc','longitude');
lat = ncread('../DATA/1980/data1980_ewss.nc','latitude');
slhf = ncread('../DATA/1980/data1980_ewss.nc','ewss'); 
lon_ncep = ncread('/home5/pharos/REFERENCE_DATA/NCEP/DATA/NCEP1/6h/land.sfc.gauss.nc','lon');
lat_ncep = ncread('/home5/pharos/REFERENCE_DATA/NCEP/DATA/NCEP1/6h/land.sfc.gauss.nc','lat');
slhf_ncep1 = ncread('/home5/pharos/REFERENCE_DATA/NCEP/DATA/NCEP1/6h/uflx.sfc.gauss.1980.nc','uflx');%-ncread('/home4/maisl/ARGO/NCEP/NCEP1/6h/dswrf.sfc.gauss.1980.nc','dswrf'); 
slhf = mean(slhf,3); % moyenne annuelle
slhf_ncep1 = mean(slhf_ncep1,3); % moyenne annuelle

slhf = -slhf/(86400/2);

figure
pcolor(lon,lat,slhf');
shading flat;
colorbar;
v=caxis;

figure;
pcolor(lon_ncep,lat_ncep,slhf_ncep1');
shading flat;
colorbar;
caxis(v);

clear all;
%close all;
lon = ncread('../DATA/1980/data1980_nsss.nc','longitude');
lat = ncread('../DATA/1980/data1980_nsss.nc','latitude');
slhf = ncread('../DATA/1980/data1980_nsss.nc','nsss'); 
lon_ncep = ncread('/home5/pharos/REFERENCE_DATA/NCEP/DATA/NCEP1/6h/land.sfc.gauss.nc','lon');
lat_ncep = ncread('/home5/pharos/REFERENCE_DATA/NCEP/DATA/NCEP1/6h/land.sfc.gauss.nc','lat');
slhf_ncep1 = ncread('/home5/pharos/REFERENCE_DATA/NCEP/DATA/NCEP1/6h/vflx.sfc.gauss.1980.nc','vflx');%-ncread('/home4/maisl/ARGO/NCEP/NCEP1/6h/dswrf.sfc.gauss.1980.nc','dswrf'); 
slhf = mean(slhf,3); % moyenne annuelle
slhf_ncep1 = mean(slhf_ncep1,3); % moyenne annuelle

slhf = -slhf/(86400/2);

figure
pcolor(lon,lat,slhf');
shading flat;
colorbar;
v=caxis;

figure;
pcolor(lon_ncep,lat_ncep,slhf_ncep1');
shading flat;
colorbar;
caxis(v);


clear all;
%close all;
lon = ncread('../DATA/1980/data1980_tp.nc','longitude');
lat = ncread('../DATA/1980/data1980_tp.nc','latitude');
slhf = ncread('../DATA/1980/data1980_tp.nc','tp'); 
lon_ncep = ncread('/home5/pharos/REFERENCE_DATA/NCEP/DATA/NCEP1/6h/land.sfc.gauss.nc','lon');
lat_ncep = ncread('/home5/pharos/REFERENCE_DATA/NCEP/DATA/NCEP1/6h/land.sfc.gauss.nc','lat');
slhf_ncep1 = ncread('/home5/pharos/REFERENCE_DATA/NCEP/DATA/NCEP1/6h/prate.sfc.gauss.1980.nc','prate');%-ncread('/home5/pharos/REFERENCE_DATA/NCEP/DATA/NCEP1/6h/dswrf.sfc.gauss.1980.nc','dswrf'); 
slhf = mean(slhf,3); % moyenne annuelle
slhf_ncep1 = mean(slhf_ncep1,3); % moyenne annuelle

slhf = slhf/(86400/2)*1000; % 1000 : densite de l'eau

figure
pcolor(lon,lat,slhf');
shading flat;
colorbar;
v=caxis;

figure;
pcolor(lon_ncep,lat_ncep,slhf_ncep1');
shading flat;
colorbar;
caxis(v);


clear all;
%close all;
lon = ncread('../DATA/1980/data1980_e.nc','longitude');
lat = ncread('../DATA/1980/data1980_e.nc','latitude');
slhf = ncread('../DATA/1980/data1980_e.nc','e'); 
lon_ncep = ncread('/home5/pharos/REFERENCE_DATA/NCEP/DATA/NCEP1/6h/land.sfc.gauss.nc','lon');
lat_ncep = ncread('/home5/pharos/REFERENCE_DATA/NCEP/DATA/NCEP1/6h/land.sfc.gauss.nc','lat');
slhf_ncep1 = ncread('/home5/pharos/REFERENCE_DATA/NCEP/DATA/NCEP1/6h/lhtfl.sfc.gauss.1980.nc','lhtfl')/2.5*1e-6;%-ncread('/home5/pharos/REFERENCE_DATA/NCEP/DATA/NCEP1/6h/dswrf.sfc.gauss.1980.nc','dswrf'); 
slhf = mean(slhf,3); % moyenne annuelle
slhf_ncep1 = mean(slhf_ncep1,3); % moyenne annuelle

slhf = -slhf/(86400/2)*1000;

figure
pcolor(lon,lat,slhf');
shading flat;
colorbar;
v=caxis;

figure;
pcolor(lon_ncep,lat_ncep,slhf_ncep1');
shading flat;
colorbar;
caxis(v);
