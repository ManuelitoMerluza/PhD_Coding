%% This script will be used to plot the mixed layer depth and property distribution
%   In the Subpolar Gyre (SPG) region

%% Loads paths, colormap and defines text properties and 

addpath(genpath('C:/Users/mitg1n25/Desktop/PhD/PhD_coding'))
set(0, 'DefaultAxesFontSize', 12);
set(0, 'DefaultAxesTitleFontSizeMultiplier', 1.15)
set(0, 'DefaultAxesFontName', 'LMRoman17');
set(0, 'DefaultAxesFontWeight', 'bold');

% Load ETOPO SPG bathymetry
load REXXBathymetry.mat

% Defines path for loading ARGO variables
folder='C:/Users/mitg1n25/Desktop/PhD/PhD_Coding/data/ARGO/ARGO_Gridded';
filenames = dir(fullfile(folder,'*.nc')); % Check the variable position

% This is for making the colormap more saturated
colorm_hsv=rgb2hsv(slanCM('blues')); saturation = 1.5;
colorm_hsv(:, 2) = min(colorm_hsv(:, 2) * saturation, 1);
colorm=hsv2rgb(colorm_hsv);

%% Loads gridded product (Temperature and Salinity)

Tg_anomaly=ncread(filenames(4).name,'ARGO_TEMPERATURE_ANOMALY');
Tg_mean=ncread(filenames(4).name,'ARGO_TEMPERATURE_MEAN');
Sg_anomaly=ncread(filenames(3).name,'ARGO_SALINITY_ANOMALY');
Sg_mean=ncread(filenames(3).name,'ARGO_SALINITY_MEAN');

% Calculates the total
Tg=Tg_anomaly + Tg_mean;
Sg=Sg_anomaly + Sg_mean;

latg=ncread(filenames(4).name,'LATITUDE');
long=ncread(filenames(4).name,'LONGITUDE');
timeg=ncread(filenames(4).name,'TIME'); % 'months since 2004-01-01 00:00:00'
t= datetime('2004-01-01') + calmonths(timeg-0.5);
presg=ncread(filenames(4).name,'PRESSURE');
maskg=ncread(filenames(4).name,'MAPPING_MASK');

% Convert from degrees E to E-W
long(long>180)=long(long>180)-360;

% For some reason, the longitude is not centered at zero, which generates
% problems when plotting. This is reordering the data is needed
[long, aux]=sort(long); maskg=maskg(aux,:,:);
Tg=Tg(aux,:,:,:); Sg=Sg(aux,:,:,:);
Tg_anomaly=Tg_anomaly(aux,:,:,:); Sg_anomaly=Sg_anomaly(aux,:,:,:);


%% Loads the position of the stations

folder='C:/Users/mitg1n25/Desktop/PhD/PhD_Coding/data/RREX/Hydrography';
filenames = dir(fullfile(folder,'*CTDO.nc')); % Check the variable position

lat2017=ncread(filenames(2).name,'LATITUDE',2,inf);
lon2017=ncread(filenames(2).name,'LONGITUDE',2,inf);

ride_2017=[56:69 76:125];
lat2017=lat2017(ride_2017); lon2017=lon2017(ride_2017);

%% Selects our region of interest (SPG)

lat_SPG=find(latg>40 & latg<65); lat=latg(lat_SPG);
lon_SPG=find(long>-60 & long<-10); lon=long(lon_SPG);
t_aux=find(t>datetime('2014-01-01')); t=t(t_aux);

Tg = Tg(lon_SPG,lat_SPG,:,t_aux);
Sg = Sg(lon_SPG,lat_SPG,:,t_aux);

%% Calculates Absolute Salinity, Conservative Temperature and N2

SA=NaN(size(Sg)); CT=NaN(size(Sg)); N2=NaN(length(lon),length(lat),length(presg)-1,length(t));
for i=1:length(lon)
    for j=1:length(lat)
        for k=1:length(t)
            SA(i,j,:,k)=gsw_SA_from_SP(squeeze(Sg(i,j,:,k)),presg,lon(i),lat(j));
            CT(i,j,:,k)=gsw_CT_from_t(squeeze(SA(i,j,:,k)),squeeze(Tg(i,j,:,k)),presg);
            [N2(i,j,:,k), pmid]=gsw_Nsquared(squeeze(SA(i,j,:,k)),squeeze(CT(i,j,:,k)),presg,lat(j));
        end
    end
end

%% Calculates MLP (Mixed Layer Pressure)

MLD=NaN(length(lon),length(lat),length(t));
for i=1:length(lon)
    for j=1:length(lat)
        for k=1:length(t)
            SAaux=squeeze(SA(i,j,:,k)); 
            CTaux=squeeze(CT(i,j,:,k));
            MLP(i,j,k) = gsw_mlp(SAaux,CTaux,presg); % Computes MLP
            MLD(i,j,k) = gsw_z_from_p(MLP(i,j,k),lat(j)); % Converts to depth
        end
    end
end

%% Computes Salinity at MLD

Sg_MLD=NaN(length(lon),length(lat),length(t));
for i=1:length(lon)
    for j=1:length(lat)
        for k=1:length(t)
            Sgaux=squeeze(Sg(i,j,:,k)); % Subselects the part of the matrix
            MLPaux=squeeze(MLP(i,j,k));
            paux=find(presg==MLPaux); % Finds the pressure index where pressure equals the MLD
            try
                Sg_MLD(i,j,k) = Sg(i,j,paux,k); % Selects salinity at MLD
            catch
                Sg_MLD(i,j,k) = NaN; % In case there is no MLD defined
            end
        end
    end
end

%% Finds maximum stratification pressure


N2_max=NaN(length(lon),length(lat),length(t));
N2_max_pres=NaN(length(lon),length(lat),length(t));
N2_max_depth=NaN(length(lon),length(lat),length(t));
for i=1:length(lon)
    for j=1:length(lat)
        for k=1:length(t)
            N2aux=squeeze(N2(i,j,:,k)); % Subselects the part of the matrix
            [N2_max(i,j,k), paux]=max(N2aux); % Finds the pressure where N2 is maximum
            try
                N2_max_pres(i,j,k) = pmid(paux); 
                %N2_max(i,j,k) = N2(i,j,paux,k); % Selects salinity at MLD
            catch
                N2_max_pres(i,j,k) = NaN; 
                %N2_max(i,j,k) = NaN; % In case there is no MLD defined
            end
            N2_max_depth(i,j,k) = gsw_z_from_p(N2_max_pres(i,j,k),lat(j)); % Converts to depth
        end
    end
end

%% We make an animation of the MLD

% figure()
% for i=1:length(t_aux)
%     hold on
%     pcolor(lon,lat,MLD(:,:,i)'); shading interp
%     cm=colormap(flipud(colorm)); clim([-1000 0]);
%     brighten(cm, 0.45); colorbar 
%     title(datestr(t(i)));
%     scatter(lon2017, lat2017, 8, 'filled','MarkerFaceColor','black');
%     drawnow
%     hold off
%     pause(0.5);
% end

%% We plot MLD for the periods of RREX cruises (July 2015 and August 2017)

figure(); set(gcf, 'Position',  [100, 100, 1500, 700])
tiledlayout(2,5,"TileSpacing","compact","Padding","compact");

i2015=14:18;
i2016=26:30;
i2017=38:42;

for i=1:5
ax1=nexttile(i);
    hold on
    pcolor(lon,lat,MLD(:,:,i2015(i))'); shading interp
    title(datestr(t(i2015(i))));
    cm=colormap(flipud(colorm)); brighten(cm, 0.45);
    clim([-1000 0]); 

    % set(gca,'colorscale','log'); cm=colormap(colorm);
    % brighten(cm, 0.45); clim([1e0 1e3]);

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
    grid on
    hold off

ax2=nexttile(i+5);
    hold on
    pcolor(lon,lat,MLD(:,:,i2017(i))'); shading interp
    title(datestr(t(i2017(i))));
    cm=colormap(flipud(colorm)); brighten(cm, 0.45); 
    clim([-1000 0])

    % set(gca,'colorscale','log'); cm=colormap(colorm);
    % brighten(cm, 0.45); clim([1e0 1e3]); 

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
    grid on
    hold off

    if i==5
        colorbar(ax1); colorbar(ax2)
    end

end

sgtitle('ARGO Mixed Layer Depth','FontSize',17, 'FontWeight', 'bold','FontName','LMRoman10')

figpath='C:\Users\mitg1n25\Desktop\PhD\PhD_Coding\docs\figures\ARGO_output';
imgname='1.ARGO_Gridded_MLD.png'; % Name of the image being stored
figname=fullfile(figpath, imgname);
% Save the figure
set(gca, 'LooseInset', get(gca, 'TightInset'));
print(gcf,figname, '-dpng', '-r0', '-loose')

%% We plot Depth of max stratification for the periods of RREX cruises (July 2015 and August 2017)

figure(); set(gcf, 'Position',  [100, 100, 1500, 700])
tiledlayout(2,5,"TileSpacing","compact","Padding","compact");

i2015=14:18;
i2017=38:42;

for i=1:5
ax1=nexttile(i);
    hold on
    pcolor(lon,lat,N2_max_depth(:,:,i2015(i))'); shading interp
    cm=colormap(flipud(colorm)); clim([-1000 0]); brighten(cm, 0.45);
    title(datestr(t(i2015(i))));

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
    grid on
    hold off

ax2=nexttile(i+5);
    hold on
    pcolor(lon,lat,N2_max_depth(:,:,i2017(i))'); shading interp
    cm=colormap(flipud(colorm)); clim([-1000 0]); brighten(cm, 0.45); 
    title(datestr(t(i2017(i))));

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
    grid on
    hold off

    if i==5
        colorbar(ax1); colorbar(ax2)
    end

end

sgtitle('Max N2 depth','FontSize',17, 'FontWeight', 'bold','FontName','LMRoman10')

imgname='2.ARGO_Gridded_MaxN2Depth.png'; % Name of the image being stored
figname=fullfile(figpath, imgname);
% Save the figure
set(gca, 'LooseInset', get(gca, 'TightInset'));
print(gcf,figname, '-dpng', '-r0', '-loose')

%% We plot Salinity at MLD for the periods of RREX cruises (July 2015 and August 2017)

figure(); set(gcf, 'Position',  [100, 100, 1500, 700])
tiledlayout(2,5,"TileSpacing","compact","Padding","compact");

i2015=14:18;
i2017=38:42;

for i=1:5
ax1=nexttile(i);
    hold on
    pcolor(lon,lat,Sg_MLD(:,:,i2015(i))'); shading interp
    clim([34.6 35.2]); colormap(ax1,slanCM('haline')); 
    title(datestr(t(i2015(i))));

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
    grid on
    hold off

ax2=nexttile(i+5);
    hold on
    pcolor(lon,lat,Sg_MLD(:,:,i2017(i))'); shading interp
    clim([34.6 35.2]); colormap(ax2,slanCM('haline'));
    title(datestr(t(i2017(i))));

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
    grid on
    hold off

    if i==5
        colorbar(ax1); colorbar(ax2)
    end

end

sgtitle('Salinity at MLD [PSU]','FontSize',17, 'FontWeight', 'bold','FontName','LMRoman10')

imgname='3.ARGO_Gridded_SalinityAtMLD.png'; % Name of the image being stored
figname=fullfile(figpath, imgname);
% Save the figure
set(gca, 'LooseInset', get(gca, 'TightInset'));
print(gcf,figname, '-dpng', '-r0', '-loose')


%% We plot Salinity Anomaly at 500 m periods of RREX cruises (July 2015 and August 2017)

figure(); set(gcf, 'Position',  [100, 100, 1500, 700])
tiledlayout(2,5,"TileSpacing","compact","Padding","compact");

i2015=14:18;
i2016=26:30;
i2017=38:42;

for i=1:5
ax1=nexttile(i);
    hold on
    pcolor(lon,lat,MLD(:,:,i2015(i))'); shading interp
    cm=colormap(flipud(colorm)); clim([-1000 0]); brighten(cm, 0.45);
    title(datestr(t(i2015(i))));

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
    grid on
    hold off

ax2=nexttile(i+5);
    hold on
    pcolor(lon,lat,MLD(:,:,i2017(i))'); shading interp
    cm=colormap(flipud(colorm)); clim([-1000 0]); brighten(cm, 0.45); 
    title(datestr(t(i2017(i))));

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
    grid on
    hold off

    if i==5
        colorbar(ax1); colorbar(ax2)
    end

end

sgtitle('ARGO Mixed Layer Depth (GSW)','FontSize',17, 'FontWeight', 'bold','FontName','LMRoman10')

figpath='C:\Users\mitg1n25\Desktop\PhD\PhD_Coding\docs\figures\ARGO_output';
imgname='1.ARGO_Gridded_MLD.png'; % Name of the image being stored
figname=fullfile(figpath, imgname);
% Save the figure
set(gca, 'LooseInset', get(gca, 'TightInset'));
print(gcf,figname, '-dpng', '-r0', '-loose')


