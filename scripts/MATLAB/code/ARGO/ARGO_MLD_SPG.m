%% This script will be used to plot the mixed layer obtained from ARGO floats
%   using the product described by Holte et al. (2017)

%% Loads paths, colormap and defines text properties and 

addpath(genpath('C:/Users/mitg1n25/Desktop/PhD/PhD_coding'))
set(0, 'DefaultAxesFontSize', 12);
set(0, 'DefaultAxesTitleFontSizeMultiplier', 1.15)
set(0, 'DefaultAxesFontName', 'LMRoman17');
set(0, 'DefaultAxesFontWeight', 'bold');
load vmap % loads colormap
vmap(29,:) = 0.97; % Changes the middle of the cbar so it can be less white

% Load ETOPO SPG bathymetry
load REXXBathymetry.mat

% Defines path for loading ARGO variables
folder='C:/Users/mitg1n25/Desktop/PhD/PhD_Coding/data/ARGO/ARGO_Gridded';
filenames = dir(fullfile(folder,'*.nc')); % Check the variable position

% This is for making the colormap more saturated
colorm_hsv=rgb2hsv(slanCM('blues')); saturation = 1.5;
colorm_hsv(:, 2) = min(colorm_hsv(:, 2) * saturation, 1);
colorm=hsv2rgb(colorm_hsv);

%% Loads mld product

lat=ncread(filenames(1).name,'profilelat');
lon=ncread(filenames(1).name,'profilelon');
time=ncread(filenames(1).name,'profiledate');
date=datetime(datevec(time));

mld=ncread(filenames(1).name,'dt_mld'); % Mixed Layer Depth [m]

% Defines values inside SPG region between 2014 and 2018
aux=find(lat>40 & lat<65 & lon>-60 & lon<-10 ...
    & date>datetime('2014-01-01') & date<datetime('2019-01-01'));

lat=lat(aux); lon=lon(aux); date=date(aux); mld=mld(aux);

%% Loads the position of the stations

folder='C:/Users/mitg1n25/Desktop/PhD/PhD_Coding/data/RREX/Hydrography';
filenames = dir(fullfile(folder,'*CTDO.nc')); % Check the variable position

lat2017=ncread(filenames(2).name,'LATITUDE',2,inf);
lon2017=ncread(filenames(2).name,'LONGITUDE',2,inf);

ride_2017=[56:69 76:125];
lat2017=lat2017(ride_2017); lon2017=lon2017(ride_2017);

%% Separates the winter period values for 2015 and 2017

% From december to march
winter2015=find(date>datetime('2014-11-30') & date<datetime('2015-04-01'));
winter2017=find(date>datetime('2016-11-30') & date<datetime('2017-04-01'));

lat_mld2015=lat(winter2015); lon_mld2015=lon(winter2015); mld2015=mld(winter2015);
lat_mld2017=lat(winter2017); lon_mld2017=lon(winter2017); mld2017=mld(winter2017);

%% Makes a scatter plot of the MLD for both periods

figure(); set(gcf, 'Position',  [100, 100, 800, 400])
tiledlayout(1,2,"TileSpacing","compact","Padding","compact");

nexttile
    hold on
    scatter(lon_mld2015, lat_mld2015, 40, -mld2015, 'filled')
    cm=colormap(flipud(colorm)); clim([-1000 0]); brighten(cm, 0.45);
    grid on

    % Marks the regions where there is land
    [C, h] = contour(lonsub, latsub, zsub, [0 0], 'k-', 'LineWidth', 2);
    % Fill land areas with grey
    % Extract contour data for land (z = 0 contour)
    contour_data = C;
    idx = 1;
    while idx < size(contour_data, 2)
        level = contour_data(1, idx);
        npoints = contour_data(2, idx);
    
        if level == 0
            x_land = contour_data(1, idx+1:idx+npoints);
            y_land = contour_data(2, idx+1:idx+npoints);
            fill(x_land, y_land, [0.7 0.7 0.7], 'EdgeColor', 'none');
        end
        idx = idx + npoints + 1;
    end
    scatter(lon2017, lat2017, 10, 'filled','MarkerFaceColor','black');
    xlim([-60 -10]); ylim([40 65])
    title('Winter 2015')
    hold off

nexttile
    hold on
    scatter(lon_mld2017, lat_mld2017, 40, -mld2017, 'filled')
    cm=colormap(flipud(colorm)); clim([-1000 0]); brighten(cm, 0.45);
    grid on

     % Marks the regions where there is land
    [C, h] = contour(lonsub, latsub, zsub, [0 0], 'k-', 'LineWidth', 2);
    % Fill land areas with grey
    % Extract contour data for land (z = 0 contour)
    contour_data = C;
    idx = 1;
    while idx < size(contour_data, 2)
        level = contour_data(1, idx);
        npoints = contour_data(2, idx);
    
        if level == 0
            x_land = contour_data(1, idx+1:idx+npoints);
            y_land = contour_data(2, idx+1:idx+npoints);
            fill(x_land, y_land, [0.7 0.7 0.7], 'EdgeColor', 'none');
        end
        idx = idx + npoints + 1;
    end
    scatter(lon2017, lat2017, 10, 'filled','MarkerFaceColor','black');
    xlim([-60 -10]); ylim([40 65])
    colorbar
    title('Winter 2017')
    hold off

    sgtitle('ARGO Mixed Layer Depth Product','FontSize',13, 'FontWeight', 'bold','FontName','LMRoman10')

figpath='C:\Users\mitg1n25\Desktop\PhD\PhD_Coding\docs\figures\ARGO_output';
imgname='4.ARGO_MLD.png'; % Name of the image being stored
figname=fullfile(figpath, imgname);
% Save the figure
set(gca, 'LooseInset', get(gca, 'TightInset'));
print(gcf,figname, '-dpng', '-r0', '-loose')

%% This part of code creates a binned average for the mld (Claude)

% === Define 1-degree grid ===
lat_edges = 40:1:65;
lon_edges = -60:1:-10;
lat_centers = lat_edges(1:end-1) + 0.5;
lon_centers = lon_edges(1:end-1) + 0.5;

nLat = numel(lat_centers);  % 50
nLon = numel(lon_centers);  % 100
nMon = 12; % number of months

% === Bin each observation into a lat/lon/month index ===
month_vec = month(date);  % extract month number (1–12)

lat_idx = discretize(lat, lat_edges);
lon_idx = discretize(lon, lon_edges);

% === Remove any out-of-range points (NaN indices) ===
valid = ~isnan(lat_idx) & ~isnan(lon_idx) & ~isnan(mld);
lat_idx  = lat_idx(valid);
lon_idx  = lon_idx(valid);
month_idx = month_vec(valid);
mld_val  = mld(valid);

% === Build 3D gridded product: (lat x lon x month) ===
mld_grid  = NaN(nLat, nLon, nMon);
mld_count = zeros(nLat, nLon, nMon);

% Convert (lat, lon, month) subscripts to linear indices
lin_idx = sub2ind([nLat, nLon, nMon], lat_idx, lon_idx, month_idx);

% Sum and count using accumarray
mld_sum = accumarray(lin_idx, mld_val,  [nLat*nLon*nMon, 1], @sum, NaN);
mld_cnt = accumarray(lin_idx, ones(size(mld_val)), [nLat*nLon*nMon, 1], @sum, 0);

% Mean = sum / count (avoid division by zero)
mld_mean = mld_sum ./ mld_cnt;
mld_mean(mld_cnt == 0) = NaN;

% Reshape back to 3D
mld_grid = reshape(mld_mean, nLat, nLon, nMon);

%% Loads the position of the stations

folder2='C:/Users/mitg1n25/Desktop/PhD/PhD_Coding/data/RREX/Hydrography';
filenames = dir(fullfile(folder2,'*CTDO.nc')); % Check the variable position

lat2017=ncread(filenames(2).name,'LATITUDE',2,inf);
lon2017=ncread(filenames(2).name,'LONGITUDE',2,inf);

ride_2017=[56:69 76:125];
lat2017=lat2017(ride_2017); lon2017=lon2017(ride_2017);

%% Plots the monthly cycle

% figure()
% for i=1:12
%     hold on
%     pcolor(lon_centers,lat_centers,-mld_grid(:,:,i)); shading interp
%     cm=colormap(flipud(colorm)); clim([-500 0]);
%     brighten(cm, 0.45); colorbar
%     title(num2str(i));
%     scatter(lon2017, lat2017, 8, 'filled','MarkerFaceColor','black');
%     drawnow
%     hold off
%     pause(0.5);
% end

% %% Obtains gridded winter/summer time series (Claude)
% 
% % === Define season month groupings ===
% % Adjust these to suit your hemisphere / science question
% summer_months = [6 7 8];   % JJA
% winter_months = [12 1 2];  % DJF
% 
% % === Extract time components ===
% month_vec = month(date);
% year_vec  = year(date);
% 
% % === Assign each observation a season label ===
% % 1 = winter, 2 = summer, 0 = neither (excluded)
% season_idx = zeros(size(month_vec));
% season_idx(ismember(month_vec, summer_months)) = 2;
% season_idx(ismember(month_vec, winter_months)) = 1;
% 
% % For DJF: assign December to the FOLLOWING year so that
% % Dec-2020, Jan-2021, Feb-2021 all belong to winter-2021
% year_adj = year_vec;
% year_adj(month_vec == 12) = year_adj(month_vec == 12) + 1;
% 
% % === Build a list of unique (year, season) pairs ===
% valid = ~isnan(lat_idx) & ~isnan(lon_idx) & ~isnan(mld) & season_idx > 0;
% 
% % Re-run discretize if not already done
% lat_idx = discretize(lat, lat_edges);
% lon_idx = discretize(lon, lon_edges);
% 
% lat_idx_v  = lat_idx(valid);
% lon_idx_v  = lon_idx(valid);
% mld_val    = mld(valid);
% yr_v       = year_adj(valid);
% seas_v     = season_idx(valid);
% 
% % Create a unique ID per (year, season) and sort chronologically
% [ys_pairs, ~, ys_idx] = unique([yr_v, seas_v], 'rows', 'stable');
% % ys_pairs is [T x 2]: col1 = year, col2 = season (1=win, 2=sum)
% T = size(ys_pairs, 1);
% 
% % === Grid dimensions (from your previous step) ===
% nLat = numel(lat_centers);
% nLon = numel(lon_centers);
% 
% % === Fill 3D array [nLat x nLon x T] ===
% mld_grid_ts = NaN(nLat, nLon, T);
% 
% for t = 1:T
%     mask = (ys_idx == t);
%     lin_idx = sub2ind([nLat nLon], lat_idx_v(mask), lon_idx_v(mask));
% 
%     mld_sum = accumarray(lin_idx, mld_val(mask),  [nLat*nLon, 1], @sum,  NaN);
%     mld_cnt = accumarray(lin_idx, ones(nnz(mask),1), [nLat*nLon, 1], @sum,  0);
% 
%     mld_mean = mld_sum ./ mld_cnt;
%     mld_mean(mld_cnt == 0) = NaN;
% 
%     mld_grid_ts(:,:,t) = reshape(mld_mean, nLat, nLon);
% end
% 
% % === Time axis for reference ===
% % Each row: [year, season] where 1=winter(DJF), 2=summer(JJA)
% time_axis = ys_pairs;  % [T x 2]

%% 