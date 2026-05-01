%% This script will be used to plot the velocity derived from satellite altimetry
% Manuel Torres :3

%% Loads paths, colormap and defines text properties and 

addpath(genpath('C:/Users/mitg1n25/Desktop/PhD/PhD_coding'))
set(0, 'DefaultAxesFontSize', 12);
set(0, 'DefaultAxesTitleFontSizeMultiplier', 1.15)
set(0, 'DefaultAxesFontName', 'LMRoman17');
set(0, 'DefaultAxesFontWeight', 'bold');
load vmap % loads colormap
vmap(29,:) = 0.97; % Changes the middle of the cbar so it can be less white

% Paths where Abosolute Velocity Data is stored
path='C:/Users/mitg1n25/Desktop/PhD/PhD_Coding/data/AVISO_ALTIMETRY/';
path2015='C:/Users/mitg1n25/Desktop/PhD/PhD_Coding/data/AVISO_ALTIMETRY/2015/mensuel/';
path2015='C:/Users/mitg1n25/Desktop/PhD/PhD_Coding/data/AVISO_ALTIMETRY/2017/mensuel/';

%% First, we take the extract the variables from the historic altimetry data (in the North Atlantic)

filenames={'Copernicus_VelocitiesGeoid_NA.nc','Copernicus_VelocitiesSSH_NA.nc','Copernicus_SSHGeoid_NA.nc'};
% If q = 1 I use the variables calculated with respect to geoid
% If q = 2 I use the regular Sea level anomalies
q=2; filename=filenames{q};


time=ncread([path filename],'time');
t= datetime(time, 'ConvertFrom', 'epochtime', 'Epoch', '1970-01-01');
lat=ncread([path filename],'latitude');
lon=ncread([path filename],'longitude');
if q==1
    DT=ncread([path filenames{3}],'adt'); % Absolute Dynamic Topography (SSH above geoid)
    u=ncread([path filename],'ugosa'); % zonal geostrophic velocity anomalies
    v=ncread([path filename],'vgosa'); % meridional geostrophic velocity anomalies
else 
    DT=ncread([path filenames{3}],'sla'); % Sea level anomaly
    u=ncread([path filename],'ugos'); % zonal geostrophic velocity anomalies
    v=ncread([path filename],'vgos'); % meridional geostrophic velocity anomalies
end

%% Calculate monthly averages

% Step 1: Reshape to 2D (space × time)
[nlon, nlat, nt] = size(u);
u_2D = reshape(u, nlon * nlat, nt);
v_2D = reshape(v, nlon * nlat, nt);
DT_2d = reshape(v, nlon * nlat, nt);

% Step 2: Create timetable
tt = timetable(t, u_2D',v_2D',DT_2d', 'VariableNames', {'u','v','DT'});

% Step 3: Calculate monthly mean
tt_monthly = retime(tt, 'monthly', 'mean');

% Step 4: Extract data and reshape back
u_m = tt_monthly.u';
u_m = reshape(u_m, nlon, nlat, height(tt_monthly));

v_m = tt_monthly.DT';
v_m = reshape(v_m, nlon, nlat, height(tt_monthly));

DT_m = tt_monthly.DT';
DT_m = reshape(DT_m, nlon, nlat, height(tt_monthly));

t_m=tt_monthly.t;


%% Calculates the variables along the ridge
% 2015 ridge took place in june (24jun - 5 jul) while 2017 took place in august (1 - 12)

% Loads the data and select the station over the ridge
fctd = 'C:/Users/mitg1n25/Desktop/PhD/PhD_Coding/data/RREX/Ivane_Hydro2017/ctd/nc/rr17_PRES.nc';
STA = [56:69 76:125]; STA=STA(:); nsta=size(STA,1); npair=nsta-1;

lat_ridge = ncread(fctd,'LATITUDE'); lat_ridge = lat_ridge(2:end); lat_ridge = lat_ridge(STA);
lon_ridge = ncread(fctd,'LONGITUDE'); lon_ridge = lon_ridge(2:end); lon_ridge = lon_ridge(STA);

[lat_ridge aux]=sort(lat_ridge); lon_ridge=lon_ridge(aux);

% Interpolates for the exact position

nstations = length(lat_ridge);
station_time_series = zeros(nstations, size(u_m,3));

for T = 1:size(u_m,3)
    % 2D interpolation at each time step
    slice_u = u_m(:,:,T);
    slice_v = v_m(:,:,T);
    for i = 1:nstations
        u_ridge(i, T) = interp2(lon, lat, slice_u', ...
                                      lon_ridge(i), lat_ridge(i), 'linear');
        v_ridge(i, T) = interp2(lon, lat, slice_v', ...
                                      lon_ridge(i), lat_ridge(i), 'linear');
    end
end

%% calculates the velocity perpendicular to the section


% Calculate the along-section and cross-section unit vectors
nstations = length(lat_ridge);
v_perp = zeros(size(u_ridge));

% For each station pair (midpoint)
for i = 1:nstations-1
    % Displacement vector from station i to i+1
    % Convert longitude to distance (km) - account for latitude!
    dx_km = (lon_ridge(i+1) - lon_ridge(i)) * 111.32 * cosd(mean(lat_ridge([i, i+1])));
    dy_km = (lat_ridge(i+1) - lat_ridge(i)) * 111.32;
    
    % Along-section unit vector
    dist = sqrt(dx_km^2 + dy_km^2);
    along_x = dx_km / dist;   % Along-section component in x-direction
    along_y = dy_km / dist;   % Along-section component in y-direction
    
    % Perpendicular unit vector (rotate 90° clockwise)
    perp_x = along_y;      % For clockwise rotation (right of section)
    perp_y = -along_x;     % Standard rotation: (x, y) → (y, -x)
    
    % For counter-clockwise (left of section), use:
    % perp_x = -along_y;
    % perp_y = along_x;
    
    % Compute perpendicular velocity for this segment
    % u is east-west, v is north-south
    v_perp_segment = u_ridge(i:i+1, :) .* perp_x + v_ridge(i:i+1, :) .* perp_y;
    
    % Assign to midpoint of segment (or endpoints)
    v_perp(i, :) = mean(v_perp_segment, 1);  % Midpoint value
end

% Handle the last point if needed
v_perp(end, :) = v_perp(end-1, :);

%% Separate the period of RREX cruises (2015 - 2017)

RREX=find(t_m >= '2015-01-01' & t_m <= '2018-01-01');

t_RREX=t_m(RREX); DT_RREX=DT_m(:,:,RREX);
u_RREX=u_m(:,:,RREX); v_RREX=v_m(:,:,RREX);

u_ridge_RREX=u_ridge(:,RREX); v_ridge_RREX=v_ridge(:,RREX);
v_perp_RREX=v_perp(:,RREX);


%% Calculates variables during the period the cruises took place

RREX2015 = find(t >= '2015-06-24' & t <= '2015-07-05');
RREX2017 = find(t >= '2017-08-01' & t <= '2017-08-12');

u_RREX2015=squeeze(mean(u(:,:,RREX2015),3)); v_RREX2015=squeeze(mean(v(:,:,RREX2015),3));
u_RREX2017=squeeze(mean(u(:,:,RREX2017),3)); v_RREX2017=squeeze(mean(v(:,:,RREX2017),3));
mag_RREX2015=sqrt(u_RREX2015.^2 + v_RREX2015.^2);
mag_RREX2017=sqrt(u_RREX2017.^2 + v_RREX2017.^2);

DT_RREX2015=squeeze(mean(DT(:,:,RREX2015),3)); DT_RREX2017=squeeze(mean(DT(:,:,RREX2017),3));


%% Extracts all locations for the station (so i can plot it)

fctd = 'C:/Users/mitg1n25/Desktop/PhD/PhD_Coding/data/RREX/Hydrography/RREX2015_CTDO.nc';
lat_sta2015 = ncread(fctd,'LATITUDE'); lon_sta2015 = ncread(fctd,'LONGITUDE'); 

fctd = 'C:/Users/mitg1n25/Desktop/PhD/PhD_Coding/data/RREX/Ivane_Hydro2017/ctd/nc/rr17_PRES.nc';
lat_sta2017 = ncread(fctd,'LATITUDE'); lon_sta2017 = ncread(fctd,'LONGITUDE'); 


%% Plots a Hovmoller diagram of velocity perpendicular to ridge

figpath='C:\Users\mitg1n25\Desktop\PhD\PhD_Coding\docs\figures\Velocity_RREX';
imgname='09.AVISO_RREX.png';
figname=fullfile(figpath, imgname);

figure()
ax1=subplot(5,2,[1 3 5]);
pcolor(lon,lat, mag_RREX2015'); shading interp
title('RREX2015')
clim([0 0.25]); colormap(ax1,slanCM('parula'));
hold on
scatter(ax1,lon_sta2015,lat_sta2015,10,"red","filled"); 
h=quiver(ax1,lon(1:2:end),lat(1:2:end),u_RREX2015(1:2:end,1:2:end)',v_RREX2015(1:2:end,1:2:end)');
set(h,'AutoScale','on', 'AutoScaleFactor', 2.5); h.Color='black';
xlim([-40 -20]); ylim([48 64]); hold off

% scatter(lon_sta2015,lat_sta2015,10,"red","filled");

ax2=subplot(5,2,[2 4 6]);
pcolor(lon,lat, mag_RREX2017'); shading interp
title('RREX2017')
clim([0 0.25]); colormap(ax2,slanCM('parula')); cb1 = colorbar('Position', [0.87, 0.45, 0.02, 0.48]);
hold on
scatter(ax2,lon_sta2017,lat_sta2017,10,"red","filled"); 
yticklabels({''})
h=quiver(lon(1:2:end),lat(1:2:end),u_RREX2017(1:2:end,1:2:end)',v_RREX2017(1:2:end,1:2:end)');
set(h,'AutoScale','on', 'AutoScaleFactor', 2.5); h.Color='black';
xlim([-40 -20]); ylim([48 64]); hold off

ax3=subplot(5,2,[7:10]);
hold on
pcolor(t_RREX,lat_ridge, v_perp_RREX); shading interp
clim([-0.25 0.25]); colormap(ax3,vmap); cb2 = colorbar(ax3,'Position', [0.87, 0.1, 0.02, 0.28]);
title('Perpendicular to Ridge')
xline(t_RREX(6),'--'); xline(t_RREX(32),'--'); 
plot(t_RREX(6),53.15,'xk','MarkerSize',10,'Linewidth',1);
plot(t_RREX(32),52.7,'xk','MarkerSize',10,'Linewidth',1)
set(ax3, 'Position', [0.13, 0.09, 0.72, 0.3]);
hold off

sgtitle('Surface Velocities')

% Shifting the plots
% This is for shifting the 2nd subplot left
shiftleft=0.06;
pos = get(ax2, 'Position');
pos(1) = pos(1) - shiftleft; 
set(ax2, 'Position', pos);

% For some reason the previous step also stretches the plot to the side
% I just set the position of the lower subplot so the same happens
pos = get(ax1, 'Position');
set(ax1, 'Position', pos)

set(gca, 'LooseInset', get(gca, 'TightInset'));
print(gcf,figname, '-dpng', '-r0', '-loose')