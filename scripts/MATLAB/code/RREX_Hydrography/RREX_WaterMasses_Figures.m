%% This script is used for plotting the water mass percentage calculated using
% Bieito's code in python

% We load paths and colorbars
addpath(genpath('C:/Users/mitg1n25/Desktop/PhD/PhD_coding'))
set(0, 'DefaultAxesFontSize', 12);
set(0, 'DefaultAxesTitleFontSizeMultiplier', 1.15)
set(0, 'DefaultAxesFontName', 'LMRoman17');
set(0, 'DefaultAxesFontWeight', 'bold');

%% First, we load the CTD variables 

folder='C:/Users/mitg1n25/Desktop/PhD/PhD_Coding/data/RREX/Hydrography';
filenames = dir(fullfile(folder,'*CTDO.nc')); % Check the variable position

% lat2015=ncread(filenames(1).name,'LATITUDE');
% lon2015=ncread(filenames(1).name,'LONGITUDE');
% bottom2015=ncread(filenames(1).name,'BOTTOM_DEPTH');
% pres2015=ncread(filenames(1).name,'PRES'); % Pressure
% %temp2015=ncread(filenames(1).name,'TEMP'); % In situ temperature
% temp2015=ncread(filenames(1).name,'TPOT'); % Potential temperature
% sal2015=ncread(filenames(1).name,'PSAL'); % Practical Salinity
% oxy2015=ncread(filenames(1).name,'OXYK'); % Oxygen concentration in umol/kg
% dens2015=ncread(filenames(1).name,'SIG0'); % Density anomaly referred to p=0
% n2015=length(lat2015);
% 
% lat2017=ncread(filenames(2).name,'LATITUDE'); 
% lon2017=ncread(filenames(2).name,'LONGITUDE');
% bottom2017=ncread(filenames(2).name,'BOTTOM_DEPTH');
% pres2017=ncread(filenames(2).name,'PRES'); % Pressure
% %temp2017=ncread(filenames(2).name,'TEMP'); % In situ temperature
% temp2017=ncread(filenames(2).name,'TPOT'); % Potential temperature
% sal2017=ncread(filenames(2).name,'PSAL'); % Practical Salinity
% oxy2017=ncread(filenames(2).name,'OXYK'); % Oxygen concentration in umol/kg
% dens2017=ncread(filenames(2).name,'SIG0'); % Density anomaly referred to p=0
% n2017=length(lat2017);

%% Separation of transects

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

%% Loads the water mass fractions and permutes the order

load RREX2015_Water_Mass_fractions_6poly.mat
X2015=permute(X2015,[2 1 3]);
pres2015=permute(pres2015,[2 1]);
M=size(X2015); M=M(3);

load RREX2017_Water_Mass_fractions_6poly.mat
X2017=permute(X2017,[2 1 3]); 
pres2017=permute(pres2017,[2 1]); 
lon2017 = lon2017(2:end);
X2017 = X2017(:,2:end,:);
pres2017 = pres2017(:,2:end);
%% Plots

q=1;
a=transects2015{q}; b=transects2017{q};
if q==1
    xdim2015=lat2015(a);
    xdim2017=lat2017(b);
else
    xdim2015=lon2015(a);
    xdim2017=lon2017(b);
end

% 2015
figure(); set(gcf, 'Position',  [100, 100, 1600, 800])
for i=1:M
    ax1=subplot(2,4,i);
    pcolor(xdim2015,pres2015(:,a),X2015(:,a,i)); shading interp
    caxis([0 1]); colormap(ax1,slanCM('parula'));
    set(gca,'YDir','reverse'); ylim([100 4500])
    ylabel('Pressure [dbar]'); title(WT2015(i,:));
end
sgtitle(['Water Masses RREX2015 - ' titles{q} ' Transect'])

% 2017
figure(); set(gcf, 'Position',  [100, 100, 1600, 800])
for i=1:M
    ax1=subplot(2,4,i);
    pcolor(xdim2017,pres2017(:,b),X2017(:,b,i)); shading interp
    caxis([0 1]); colormap(ax1,slanCM('parula'));
    set(gca,'YDir','reverse'); ylim([100 4500])
    ylabel('Pressure [dbar]'); title(WT2015(i,:));
end
sgtitle(['Water Masses RREX2017 - ' titles{q} ' Transect'])


% saveas(gcf,'1.Hydrography_ridge.png')

%% Computes Water Mass Transport

transect={'ride','south','ovide','north'};
WaterMasses={'NACW', 'SAW', 'SPMW', 'SAIW', 'ISW', 'LSW', 'ISOW', 'LDW'};
N=length(WaterMasses);
A=length(a); B=length(b);

q=1; % ride

T2015=NaN(N,A); T2017=NaN(N,B);
T_ridge2015=NaN(N,4); T_ridge2017=NaN(N,4);
T_south2015=NaN(N,2); T_south2017=NaN(N,2);
T_ovide2015=NaN(N,2); T_ovide2017=NaN(N,2);
T_north2015=NaN(N,2); T_north2017=NaN(N,1);
for qq=1:N % Counter for layers
        [T2015(qq,:), T2017(qq,:), ~, ~, T_ridge2015(qq,:), T_ridge2017(qq,:)] = RREX_ComputesTransport_WaterMasses(transect{1},WaterMasses{qq},'mean');
        [~, ~, ~, ~, T_south2015(qq,:), T_south2017(qq,:)] = RREX_ComputesTransport_WaterMasses(transect{2},WaterMasses{qq},'mean');
        [~, ~, ~, ~, T_ovide2015(qq,:), T_ovide2017(qq,:)] = RREX_ComputesTransport_WaterMasses(transect{3},WaterMasses{qq},'mean');
        [~, ~, ~, ~, T_north2015(qq,:), T_north2017(qq,:)] = RREX_ComputesTransport_WaterMasses(transect{4},WaterMasses{qq},'mean');
end

%% Debug

mm2015=NaN(N,4); mm2017=NaN(N,4);
for qq=1:N % Counter for layers
    [mm2015(qq,:), mm2017(qq,:)] = RREX_ComputesTransport_WaterMasses_Debug(transect{1},WaterMasses{qq},'meh');
end

%% Convert magnitude matrix to a table in word format

% Selects the year to copy
T_ridgeT=[T_ridge2015; sum(T_ridge2015,1)];
headers = {'2015', '50.1 - 53.3N', '53.3 - 56.7N', '56.7 - 58.9N', '58.9 - 63.4N'}; % 2015
%T_ridgeT=[T_ridge2017; sum(T_ridge2017,1)];
%headers = {'2017', '49.1 - 52.7N', '52.7 - 56.7N', '56.7 - 58.9N', '58.9 - 63.4N'}; % 2017

data_with_headers = [headers;[[WaterMasses,'Total']', num2cell(T_ridgeT)]];

% Creates table from matrix
table = array2table(data_with_headers);

% Exports to excel
writetable(table, 'T_ridge2015.xlsx');


