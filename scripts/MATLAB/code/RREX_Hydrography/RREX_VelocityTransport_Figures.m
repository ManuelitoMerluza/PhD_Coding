%% This script will be used to plot the figures of geostrophic velocity
%  and transport computed by Ivane's functions.

addpath(genpath('C:/Users/mitg1n25/Desktop/PhD/PhD_coding'))
set(0, 'DefaultAxesFontSize', 12);
set(0, 'DefaultAxesTitleFontSizeMultiplier', 1.15)
set(0, 'DefaultAxesFontName', 'LMRoman17');
set(0, 'DefaultAxesFontWeight', 'bold');
load vmap % loads colormap
vmap(29,:) = 0.97; % Changes the middle of the cbar so it can be less white
path2015='C:/Users/mitg1n25/Desktop/PhD/PhD_Coding/data/RREX/Ivane_output_RREX15/vitesse_abs/';
path2017='C:/Users/mitg1n25/Desktop/PhD/PhD_Coding/data/RREX/Ivane_output_RREX17/vitesse_abs/';


% It is important to have access to:
% 1) Absolute velocity (Vgeo corrected by SADCP data)
% 2) Bthymetry
% 3) Transport between stations
% 4) Ekman transport
% 5) AVISO altimetry data
% * For the time being I only have acces to the 2017 velocities

%% Adjust colormap
% cmap_original = vmap;
% 
% % Find white region (where R, G, B are all close to 1)
% white_region = find(cmap_original(:,1) > 0.95 & ...
%                     cmap_original(:,2) > 0.95 & ...
%                     cmap_original(:,3) > 0.95);
% 
% white_center_idx = round(mean(white_region));
% 
% % Make symmetric by cropping
% n_total = size(cmap_original, 1);
% n_left = white_center_idx - 1;
% n_right = n_total - white_center_idx;
% n_use = min(n_left, n_right);
% 
% cmap_symmetric = [cmap_original(white_center_idx-n_use:white_center_idx-1, :);
%                   [1, 1, 1];
%                   cmap_original(white_center_idx+1:white_center_idx+n_use, :)];
% 
% % Apply
% vmap=cmap_symmetric;
% save('vmap0.mat','vmap')

%% First lets define the transect and load the variables

transect={'ride','south','ovide','north'};
section=transect{1};

cruise='RREX 2017 ';
load([path2017 'OS38_section_' section '_polyfit.mat'])
[bathy_ship,X_bathy,Y_bathy]=bathy_bateau_17(section);

if strcmp(section,'ride')
    xaxis=lat_abs;
    xlab='Latitude (°N)';
else
    xaxis=lon_abs;
    xlab='Longitude (°E)';
end


figtitle={'Reykjanes Ridge Transect','South Cross-Ridge Transect','OVIDE Transect','North West-Ridge Transect'};

%% Fixes the bathymetry


bathy_ship = bathy_ship.*1e-3;

if strcmp(section,'south')||strcmp(section,'ride')||strcmp(section,'ovide')
    if strcmp(section,'south')||strcmp(section,'ovide')
        ind_bad=find(bathy_ship(2:end-1)<1);
    elseif strcmp(section,'ride')
        ind_bad=find(bathy_ship(2:end-1)<0.1);
    end  
 
    for i=1:length(ind_bad)
        j=length(ind_bad)+1-i;
        bathy_ship(ind_bad(j)+1)=[];
        X_bathy(ind_bad(j)+1)=[];
        Y_bathy(ind_bad(j)+1)=[];
    end    

    if strcmp(section,'south')||strcmp(section,'ovide')
        ind_bad=find(3.2<bathy_ship(2:end-3));
    elseif strcmp(section,'ride')
        ind_bad=find(4.5<bathy_ship(2:end-3));
    end   

    for i=1:length(ind_bad)
        j=length(ind_bad)+1-i;
        bathy_ship(ind_bad(j)+1)=[];
        X_bathy(ind_bad(j)+1)=[];
        Y_bathy(ind_bad(j)+1)=[];
    end
end

%% Geostrophic velocity transect

% Path for saving the figure
figpath='C:\Users\mitg1n25\Desktop\PhD\PhD_Coding\docs\figures\Velocity_RREX';

figure()
set(gcf, 'Position', [185, 0, 1200, 800]);
vcol=-0.2:0.02:0.2;
hold on
pcolor(xaxis,z_abs*1e-3,v_abs); shading interp;
contour(xaxis,z_abs*1e-3,v_abs,[0, 0],'Linecolor',[0.35 0.35 0.35],'LineWidth',1.8);
set(gca,'ydir','reverse')
xlabel(xlab); ylabel('Depth (km)');
colorbar; colormap(vmap);
limcol=[vcol(1) vcol(end)]; clim(limcol); 
fill(X_bathy(:),bathy_ship,[0.5 0.5 0.5]);
ylim([0 4.5])
if strcmp(section,'ride')
    title([cruise figtitle{1} ' Geostrophic Velocity'],'FontSize',15)
    figname=fullfile(figpath, '01Vgeo2017_ridge.png');
elseif strcmp(section,'south')
    title([cruise figtitle{2} ' Geostrophic Velocity'],'FontSize',15)
    figname=fullfile(figpath, '02.Vgeo2017_south.png');
elseif strcmp(section,'ovide')
    title([cruise figtitle{3} ' Geostrophic Velocity'],'FontSize',15)
    figname=fullfile(figpath, '03.Vgeo2017_ovide.png');
elseif strcmp(section,'north')
    title([cruise figtitle{4} ' Geostrophic Velocity'],'FontSize',15)
    figname=fullfile(figpath, '04.Vgeo2017_north.png');
end

set(gca, 'LooseInset', get(gca, 'TightInset'));
print(gcf,figname, '-dpng', '-r0', '-loose')

%% The same but for RREX2015

cruise='RREX 2015 ';
load([path2015 'OS38_section_' section '_polyfit.mat'])

figure()
set(gcf, 'Position', [185, 0, 1200, 800]);
vcol=-0.2:0.02:0.2;
hold on
pcolor(xaxis,z_abs*1e-3,v_abs); shading interp;
contour(xaxis,z_abs*1e-3,v_abs,[0, 0],'Linecolor',[0.35 0.35 0.35],'LineWidth',1.8);
set(gca,'ydir','reverse')
xlabel(xlab); ylabel('Depth (km)');
colorbar; colormap(vmap);
limcol=[vcol(1) vcol(end)]; clim(limcol); 
fill(X_bathy(:),bathy_ship,[0.5 0.5 0.5]);
ylim([0 4.5])
if strcmp(section,'ride')
    title([cruise figtitle{1} ' Geostrophic Velocity'],'FontSize',15)
    figname=fullfile(figpath, '01Vgeo2015_ridge.png');
elseif strcmp(section,'south')
    title([cruise figtitle{2} ' Geostrophic Velocity'],'FontSize',15)
    figname=fullfile(figpath, '02.Vgeo2015_south.png');
elseif strcmp(section,'ovide')
    title([cruise figtitle{3} ' Geostrophic Velocity'],'FontSize',15)
    figname=fullfile(figpath, '03.Vgeo2015_ovide.png');
elseif strcmp(section,'north')
    title([cruise figtitle{4} ' Geostrophic Velocity'],'FontSize',15)
    figname=fullfile(figpath, '04.Vgeo2015_north.png');
end

set(gca, 'LooseInset', get(gca, 'TightInset'));
print(gcf,figname, '-dpng', '-r0', '-loose')