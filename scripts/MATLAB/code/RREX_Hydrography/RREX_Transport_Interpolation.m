% This script is for interpolating and seeing the difference between the
% transects

% We load paths and colorbars
addpath(genpath('C:/Users/mitg1n25/Desktop/PhD/PhD_Coding'))
%addpath(genpath('D:/Respaldo PC/iop/materia/Magister/Semestre 2/PRODIGY/m_map/'))
set(0, 'DefaultAxesFontSize', 12);
set(0, 'DefaultAxesTitleFontSizeMultiplier', 1.15)
set(0, 'DefaultAxesFontName', 'LMRoman17');
set(0, 'DefaultAxesFontWeight', 'bold');
path2015='C:/Users/mitg1n25/Desktop/PhD/PhD_Coding/data/RREX/Ivane_output_RREX15/';
path2017='C:/Users/mitg1n25/Desktop/PhD/PhD_Coding/data/RREX/Ivane_output_RREX17/';
load vmap % loads colormap
vmap(29,:) = 0.97; % Changes the middle of the cbar so it can be less white

for i=1:4
%% First, we load the variables from the CTD

folder='C:/Users/mitg1n25/Desktop/PhD/PhD_Coding/data/RREX/Hydrography';
filenames = dir(fullfile(folder,'*CTDO.nc')); % Check the variable position

lat2015_CTD=ncread(filenames(1).name,'LATITUDE');
lon2015_CTD=ncread(filenames(1).name,'LONGITUDE');
pres2015_CTD=ncread(filenames(1).name,'PRES'); 
temp2015_CTD=ncread(filenames(1).name,'TEMP'); % In situ temperature
sal2015_CTD=ncread(filenames(1).name,'PSAL'); % Practical Salinity
dens2015_CTD=ncread(filenames(1).name,'SIG0'); % Density anomaly referred to p=0

lat2017_CTD=ncread(filenames(2).name,'LATITUDE'); lat2017_CTD=lat2017_CTD(2:end);
lon2017_CTD=ncread(filenames(2).name,'LONGITUDE'); lon2017_CTD=lon2017_CTD(2:end);
pres2017_CTD=ncread(filenames(2).name,'PRES'); pres2017_CTD=pres2017_CTD(:,2:end);
temp2017_CTD=ncread(filenames(2).name,'TEMP'); temp2017_CTD=temp2017_CTD(:,2:end);
sal2017_CTD=ncread(filenames(2).name,'PSAL'); sal2017_CTD=sal2017_CTD(:,2:end);
dens2017_CTD=ncread(filenames(2).name,'SIG0'); dens2017_CTD=dens2017_CTD(:,2:end);

ridge_2015=[68:84 89:102 110:133];
north_2015=46:67;
ovide_2015=26:45;
south_2015=[3:10 15 16 21:25];
transects2015={ridge_2015, south_2015, ovide_2015, north_2015};

ridge_2017=[56:69 76:125];
south_2017=[1:8 11:17];
ovide_2017=[18:20 22:24 27:28 43:-1:41 38:-1:31];
north_2017=[44:55 57];
transects2017={ridge_2017, south_2017, ovide_2017, north_2017};

%% Then, the velocity variables

transect={'ride','south','ovide','north'};
section=transect{i};
section2015=transects2015{i}; section2017=transects2017{i};

if strcmp(section,'ride') % Defines x axis depending on the transect
    load([path2015 'transport_geo/transport_RREX15_' section '_use.mat'],'X');
    load([path2015 'vitesse_abs/OS38_section_' section '_use.mat'],'v_abs','z_abs','dpair_abs'); 
    v2015=v_abs; X2015=X; z2015=z_abs; dpair2015=dpair_abs; dpair2015(end+1)=dpair2015(end);

    load([path2017 'transport_geo/transport_RREX17_' section '_use.mat'],'X');
    load([path2017 'vitesse_abs/OS38_section_' section '_use.mat'],'v_abs','z_abs','dpair_abs');
    v2017=v_abs; X2017=X; z2017=z_abs; dpair2017=dpair_abs; dpair2017(end+1)=dpair2017(end);

    latlon2015=lat2015_CTD(section2015); latlon2017=lat2017_CTD(section2017);
else
    load([path2015 'transport_geo/transport_RREX15_' section '_pfit.mat'],'X');
    load([path2015 'vitesse_abs/OS38_section_' section '_pfit.mat'],'v_abs','z_abs','dpair_abs');
    v2015=v_abs; X2015=X; T2015=tr_z; z2015=z_abs; dpair2015=dpair_abs; dpair2015(end+1)=dpair2015(end);

    load([path2017 'transport_geo/transport_RREX17_' section '_pfit.mat'],'X');
    load([path2017 'vitesse_abs/OS38_section_' section '_pfit.mat'],'v_abs','z_abs','dpair_abs');
    v2017=v_abs; X2017=X; T2017=tr_z; z2017=z_abs; dpair2017=dpair_abs; dpair2017(end+1)=dpair2017(end);

    latlon2015=lon2015_CTD(section2015); latlon2017=lon2017_CTD(section2017);
end

pres2015=pres2015_CTD(:,section2015); pres2017=pres2017_CTD(:,section2017);
temp2015=temp2015_CTD(:,section2015); temp2017=temp2017_CTD(:,section2017);
sal2015=sal2015_CTD(:,section2015); sal2017=sal2017_CTD(:,section2017);
dens2015=dens2015_CTD(:,section2015); dens2017=dens2017_CTD(:,section2017);

%% Applies interpolation

v2015i = RREXInterpolation_Mid2CTD(v2015,X2015,z2015,latlon2015,pres2015,section);

figure()
subplot(2,1,1)
pcolor(X2015,z2015,v2015); shading interp
set(gca,'ydir','reverse'); clim([-0.25 0.25])
ylim([0 4000]); colorbar; colormap(vmap);

subplot(2,1,2)
pcolor(latlon2015,pres2015,v2015i); shading interp
set(gca,'ydir','reverse'); clim([-0.25 0.25])
ylim([0 4000]); colorbar; colormap(vmap);


%% Calculation of heat and salt transport

cp=4000; rho2015=dens2015+1000;
heat2015=v2015i.*cp.*rho2015.*temp2015;
salt2015=sal2015.*v2015i;
zl=nanmean(pres2015,2);

[tr_heat aux]=trsp_geo_tp(heat2015,zl,dpair2015);
[tr_salt aux]=trsp_geo_tp(salt2015,zl,dpair2015');

figure()
subplot(2,1,1)
pcolor(latlon2015,pres2015,tr_heat); shading interp
set(gca,'ydir','reverse');
ylim([0 4000]); colorbar; colormap(vmap);
title('heat')

subplot(2,1,2)
pcolor(latlon2015,pres2015,tr_salt); shading interp
set(gca,'ydir','reverse');
ylim([0 4000]); colorbar; colormap(vmap);
title('salt')

end

