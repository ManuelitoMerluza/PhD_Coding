%% This script will be used for plotting the transport in the upper, intermediate 
% And deep layers of the region for both cruises

%% Loads paths, colormap and defines text properties and 

addpath(genpath('C:/Users/mitg1n25/Desktop/PhD/PhD_coding'))
set(0, 'DefaultAxesFontSize', 12);
set(0, 'DefaultAxesTitleFontSizeMultiplier', 1.15)
set(0, 'DefaultAxesFontName', 'LMRoman17');
set(0, 'DefaultAxesFontWeight', 'bold');
load REXXBathymetry.mat

% Paths where Abosolute Velocity Data is stored
path2015='C:/Users/mitg1n25/Desktop/PhD/PhD_Coding/data/RREX/Ivane_output_RREX15/transport_geo/';
path2017='C:/Users/mitg1n25/Desktop/PhD/PhD_Coding/data/RREX/Ivane_output_RREX17/transport_geo/';

% It is important to have access to:
% 1) Transport between stations
% 2) Ekman Transport
% 3) Original CTD data (for determining density layers)

%% Loads position variables

folder='C:/Users/mitg1n25/Desktop/PhD/PhD_Coding/data/RREX/Hydrography';
filenames = dir(fullfile(folder,'*CTDO.nc')); % Check the variable position

lat2015=ncread(filenames(1).name,'LATITUDE');
lon2015=ncread(filenames(1).name,'LONGITUDE');

lat2017=ncread(filenames(2).name,'LATITUDE'); lat2017=lat2017(2:end);
lon2017=ncread(filenames(2).name,'LONGITUDE'); lon2017=lon2017(2:end);

%% Subsamples only locations used for calculating velocity

ride_2015=[68:84 89:102 110:133];
north_2015=46:67;
ovide_2015=26:45;
south_2015=[3:10 15 16 21:25];

ride_2017=[56:69 76:125];
south_2017=[1:8 11:17];
ovide_2017=[18:20 22:24 27:28 43:-1:41 38:-1:31];
north_2017=[44:55 57];

titles = {'Ridge', 'South', 'OVIDE', 'North'};
transects2015={ride_2015, south_2015, ovide_2015, north_2015};
transects2017={ride_2017, south_2017, ovide_2017, north_2017};

all2015=[ride_2015, south_2015, ovide_2015, north_2015];
lat2015=lat2015(all2015); lon2015=lon2015(all2015);

all2017=[ride_2017, south_2017, ovide_2017, north_2017];
lat2017=lat2017(all2017); lon2017=lon2017(all2017);

%% Calculate the transports by layers

transect={'ride','south','ovide','north'};
layers={'tot','layer1', 'layer2', 'layer3', 'layer4'};
N=length(layers);

q=1; % ride

T_ridge2015=NaN(N,4); T_ridge2017=NaN(N,4);
T_south2015=NaN(N,2); T_south2017=NaN(N,2);
T_ovide2015=NaN(N,2); T_ovide2017=NaN(N,2);
T_north2015=NaN(N,2); T_north2017=NaN(N,1);
for qq=1:N % Counter for layers
        [~, ~, ~, ~, T_ridge2015(qq,:), T_ridge2017(qq,:)] = RREX_ComputesTransport(transect{1},layers{qq});
        [~, ~, ~, ~, T_south2015(qq,:), T_south2017(qq,:)] = RREX_ComputesTransport(transect{2},layers{qq});
        [~, ~, ~, ~, T_ovide2015(qq,:), T_ovide2017(qq,:)] = RREX_ComputesTransport(transect{3},layers{qq});
        [~, ~, ~, ~, T_north2015(qq,:), T_north2017(qq,:)] = RREX_ComputesTransport(transect{4},layers{qq});
end

% We take the intermediate layer as the sum of layer 1 and 2

T_ridge2015(3,:)=T_ridge2015(2,:)+T_ridge2015(3,:); T_ridge2015(2,:)=[];
T_ridge2017(3,:)=T_ridge2017(2,:)+T_ridge2017(3,:); T_ridge2017(2,:)=[];

T_south2015(3,:)=T_south2015(2,:)+T_south2015(3,:); T_south2015(2,:)=[];
T_south2017(3,:)=T_south2017(2,:)+T_south2017(3,:); T_south2017(2,:)=[];

T_ovide2015(3,:)=T_ovide2015(2,:)+T_ovide2015(3,:); T_ovide2015(2,:)=[];
T_ovide2017(3,:)=T_ovide2017(2,:)+T_ovide2017(3,:); T_ovide2017(2,:)=[];

T_north2015(3,:)=T_north2015(2,:)+T_north2015(3,:); T_north2015(2,:)=[];
T_north2017(3)=T_north2017(2)+T_north2017(3); T_north2017(2)=[];

%% Plot of map and stations for 2015

% This is for making the colormap more saturated
colorm_hsv=rgb2hsv(slanCM('blues')); saturation = 1.5;
colorm_hsv(:, 2) = min(colorm_hsv(:, 2) * saturation, 1);
colorm=hsv2rgb(colorm_hsv);

ax_subplot=cell(4,1);
figure(); set(gcf, 'Position',  [100, 100, 1900, 500])

for i = 1:4
ax=subplot(1,4,i);
pcolor(lonsub,latsub,zsub); shading flat
cm=colormap(flipud(colorm)); caxis([-4500 0]);
brighten(cm, 0.45); % This function brightens the colormap :o

xlim([-45 -20]); ylim([48 64]);
%colorbar;

hold('on')

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

% Now lets add the scatter plot

% Plot scatter on ax2
s1 = scatter(lon2015, lat2015, 8, 'filled','MarkerFaceColor','black');
xlabel('Longitude'); 
if i==1
    ylabel('Latitude');
end

ax_subplot{i}=ax;
end

hold('off')

% Adds text boxes

sc={'r','b','b','b','r','b','r','b','r','b'}; %string colors

% Adds the textboxes with the transport
% Ridge
for i = 1:4
    t1 = text(ax_subplot{i}, 0.40, 0.22, num2str(T_ridge2015(i,1)), ...
              'Units', 'normalized', ...
              'Color', sc{1}, ...
              'FontSize', 10, ...
              'FontWeight', 'bold','BackgroundColor', 'w', ...
              'HorizontalAlignment', 'center', ...
              'VerticalAlignment', 'middle');t1.Rotation=90;
    
    t2 = text(ax_subplot{i}, 0.40, 0.44, num2str(T_ridge2015(i,2)), ...
              'Units', 'normalized', ...
              'Color', sc{2}, ...
              'FontSize', 10, ...
              'FontWeight', 'bold','BackgroundColor', 'w', ...
              'HorizontalAlignment', 'center', ...
              'VerticalAlignment', 'middle');t2.Rotation=80;
    
    t3 = text(ax_subplot{i}, 0.495, 0.59, num2str(T_ridge2015(i,3)), ...
              'Units', 'normalized', ...
              'Color', sc{3}, ...
              'FontSize', 10, ...
              'FontWeight', 'bold','BackgroundColor', 'w', ...
              'HorizontalAlignment', 'center', ...
              'VerticalAlignment', 'middle');t3.Rotation=60;
    
    t4 = text(ax_subplot{i}, 0.66, 0.80, num2str(T_ridge2015(i,4)), ...
              'Units', 'normalized', ...
              'Color', sc{4}, ...
              'FontSize', 10, ...
              'FontWeight', 'bold','BackgroundColor', 'w', ...
              'HorizontalAlignment', 'center', ...
              'VerticalAlignment', 'middle');t4.Rotation=50;
    
    
    % South
    t5 = text(ax_subplot{i}, 0.33, 0.54, num2str(T_south2015(i,1)), ...
              'Units', 'normalized', ...
              'Color', sc{5}, ...
              'FontSize', 10, ...
              'FontWeight', 'bold','BackgroundColor', 'w', ...
              'HorizontalAlignment', 'center', ...
              'VerticalAlignment', 'middle');t5.Rotation=-5;
    
    t6 = text(ax_subplot{i}, 0.53, 0.47, num2str(T_south2015(i,2)), ...
              'Units', 'normalized', ...
              'Color', sc{6}, ...
              'FontSize', 10, ...
              'FontWeight', 'bold','BackgroundColor', 'w', ...
              'HorizontalAlignment', 'center', ...
              'VerticalAlignment', 'middle');t6.Rotation=-35;
    
    
    % OVIDE
    t7 = text(ax_subplot{i}, 0.42, 0.70, num2str(T_ovide2015(i,1)), ...
              'Units', 'normalized', ...
              'Color', sc{7}, ...
              'FontSize', 10, ...
              'FontWeight', 'bold','BackgroundColor', 'w', ...
              'HorizontalAlignment', 'center', ...
              'VerticalAlignment', 'middle');t7.Rotation=-10;
    
    t8 = text(ax_subplot{i}, 0.67, 0.59, num2str(T_ovide2015(i,2)), ...
              'Units', 'normalized', ...
              'Color', sc{8}, ...
              'FontSize', 10, ...
              'FontWeight', 'bold','BackgroundColor', 'w', ...
              'HorizontalAlignment', 'center', ...
              'VerticalAlignment', 'middle');t8.Rotation=-45;
    
    
    % North
    t9 = text(ax_subplot{i}, 0.58, 0.935, num2str(T_north2015(i,1)), ...
              'Units', 'normalized', ...
              'Color', sc{9}, ...
              'FontSize', 10, ...
              'FontWeight', 'bold','BackgroundColor', 'w', ...
              'HorizontalAlignment', 'center', ...
              'VerticalAlignment', 'middle');t9.Rotation=0;
    t10 = text(ax_subplot{i}, 0.88, 0.85, num2str(T_north2015(i,2)), ...
              'Units', 'normalized', ...
              'Color', sc{10}, ...
              'FontSize', 10, ...
              'FontWeight', 'bold','BackgroundColor', 'w', ...
              'HorizontalAlignment', 'center', ...
              'VerticalAlignment', 'middle');t10.Rotation=-55;
    
    
end


figpath='C:\Users\mitg1n25\Desktop\PhD\PhD_Coding\docs\figures\Velocity_RREX';
imgname={'14a.T_layer_map_2015.png','14b.T_layer_map_2015.png'};
figname=fullfile(figpath, imgname{1});

%set(gca, 'LooseInset', get(gca, 'TightInset'));
print(gcf,figname, '-dpng', '-r0', '-loose')


%% Plot of map and stations for 2017

% This is for making the colormap more saturated
colorm_hsv=rgb2hsv(slanCM('blues')); saturation = 1.5;
colorm_hsv(:, 2) = min(colorm_hsv(:, 2) * saturation, 1);
colorm=hsv2rgb(colorm_hsv);

ax_subplot=cell(4,1);
figure(); set(gcf, 'Position',  [100, 100, 1900, 500])

for i = 1:4
ax=subplot(1,4,i);
pcolor(lonsub,latsub,zsub); shading flat
cm=colormap(flipud(colorm)); caxis([-4500 0]);
brighten(cm, 0.45); % This function brightens the colormap :o

xlim([-45 -20]); ylim([48 64]);
%colorbar;

hold('on')

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

% Now lets add the scatter plot

% Plot scatter on ax2
s1 = scatter(lon2017, lat2017, 8, 'filled','MarkerFaceColor','black');
xlabel('Longitude'); 
if i==1
    ylabel('Latitude');
end

ax_subplot{i}=ax;
end

hold('off')

% Adds text boxes

sc={'r','b','b','b','r','b','r','b','r'; ...
    'r','b','b','b','r','b','r','b','r'; ...
    'r','b','b','b','r','b','r','b','b'; ...
    'b','b','b','b','r','b','r','b','r'}; %string colors

% Adds the textboxes with the transport
% Ridge
for i = 1:4
    t1 = text(ax_subplot{i}, 0.40, 0.22, num2str(T_ridge2017(i,1)), ...
              'Units', 'normalized', ...
              'Color', sc{i,1}, ...
              'FontSize', 10, ...
              'FontWeight', 'bold','BackgroundColor', 'w', ...
              'HorizontalAlignment', 'center', ...
              'VerticalAlignment', 'middle');t1.Rotation=90;
    
    t2 = text(ax_subplot{i}, 0.40, 0.44, num2str(T_ridge2017(i,2)), ...
              'Units', 'normalized', ...
              'Color', sc{i,2}, ...
              'FontSize', 10, ...
              'FontWeight', 'bold','BackgroundColor', 'w', ...
              'HorizontalAlignment', 'center', ...
              'VerticalAlignment', 'middle');t2.Rotation=80;
    
    t3 = text(ax_subplot{i}, 0.495, 0.59, num2str(T_ridge2017(i,3)), ...
              'Units', 'normalized', ...
              'Color', sc{i,3}, ...
              'FontSize', 10, ...
              'FontWeight', 'bold','BackgroundColor', 'w', ...
              'HorizontalAlignment', 'center', ...
              'VerticalAlignment', 'middle');t3.Rotation=60;
    
    t4 = text(ax_subplot{i}, 0.66, 0.80, num2str(T_ridge2017(i,4)), ...
              'Units', 'normalized', ...
              'Color', sc{i,4}, ...
              'FontSize', 10, ...
              'FontWeight', 'bold','BackgroundColor', 'w', ...
              'HorizontalAlignment', 'center', ...
              'VerticalAlignment', 'middle');t4.Rotation=50;
    
    
    % South
    t5 = text(ax_subplot{i}, 0.33, 0.54, num2str(T_south2017(i,1)), ...
              'Units', 'normalized', ...
              'Color', sc{i,5}, ...
              'FontSize', 10, ...
              'FontWeight', 'bold','BackgroundColor', 'w', ...
              'HorizontalAlignment', 'center', ...
              'VerticalAlignment', 'middle');t5.Rotation=-5;
    
    t6 = text(ax_subplot{i}, 0.53, 0.47, num2str(T_south2017(i,2)), ...
              'Units', 'normalized', ...
              'Color', sc{i,6}, ...
              'FontSize', 10, ...
              'FontWeight', 'bold','BackgroundColor', 'w', ...
              'HorizontalAlignment', 'center', ...
              'VerticalAlignment', 'middle');t6.Rotation=-35;
    
    
    % OVIDE
    t7 = text(ax_subplot{i}, 0.42, 0.70, num2str(T_ovide2017(i,1)), ...
              'Units', 'normalized', ...
              'Color', sc{i,7}, ...
              'FontSize', 10, ...
              'FontWeight', 'bold','BackgroundColor', 'w', ...
              'HorizontalAlignment', 'center', ...
              'VerticalAlignment', 'middle');t7.Rotation=-10;
    
    t8 = text(ax_subplot{i}, 0.67, 0.59, num2str(T_ovide2017(i,2)), ...
              'Units', 'normalized', ...
              'Color', sc{i,8}, ...
              'FontSize', 10, ...
              'FontWeight', 'bold','BackgroundColor', 'w', ...
              'HorizontalAlignment', 'center', ...
              'VerticalAlignment', 'middle');t8.Rotation=-45;
    
    
    % North
    t9 = text(ax_subplot{i}, 0.58, 0.935, num2str(T_north2017(i)), ...
              'Units', 'normalized', ...
              'Color', sc{i,9}, ...
              'FontSize', 10, ...
              'FontWeight', 'bold','BackgroundColor', 'w', ...
              'HorizontalAlignment', 'center', ...
              'VerticalAlignment', 'middle');t9.Rotation=0;
    
    
end

figname=fullfile(figpath, imgname{2});

%set(gca, 'LooseInset', get(gca, 'TightInset'));
print(gcf,figname, '-dpng', '-r0', '-loose')