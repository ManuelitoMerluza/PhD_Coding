%% This script will be used for plotting the water mass concentrations calculated
% using the OMP package in python

% We load paths and colorbars
addpath(genpath('C:/Users/mitg1n25/Desktop/PhD/PhD_coding'))
set(0, 'DefaultAxesFontSize', 12);
set(0, 'DefaultAxesTitleFontSizeMultiplier', 1.15)
set(0, 'DefaultAxesFontName', 'LMRoman17');
set(0, 'DefaultAxesFontWeight', 'bold');
map = load('colormap_RREX.mat'); % colormap(map.cmap);
load REXXBathymetry.mat


%% First, we load the CTD variables 

folder='C:/Users/mitg1n25/Desktop/PhD/PhD_Coding/data/RREX/Hydrography';
filenames = dir(fullfile(folder,'*CTDO.nc')); % Check the variable position

lat2015=ncread(filenames(1).name,'LATITUDE');
lon2015=ncread(filenames(1).name,'LONGITUDE');
bottom2015=ncread(filenames(1).name,'BOTTOM_DEPTH');
pres2015=ncread(filenames(1).name,'PRES'); % Pressure
temp2015=ncread(filenames(1).name,'TEMP'); % In situ temperature
sal2015=ncread(filenames(1).name,'PSAL'); % Practical Salinity
oxy2015=ncread(filenames(1).name,'OXYK'); % Oxygen concentration in umol/kg
dens2015=ncread(filenames(1).name,'SIG0'); % Density anomaly referred to p=0

lat2017=ncread(filenames(2).name,'LATITUDE');
lon2017=ncread(filenames(2).name,'LONGITUDE');
bottom2017=ncread(filenames(2).name,'BOTTOM_DEPTH');
pres2017=ncread(filenames(2).name,'PRES'); % Pressure
temp2017=ncread(filenames(2).name,'TEMP'); % In situ temperature
sal2017=ncread(filenames(2).name,'PSAL'); % Practical Salinity
oxy2017=ncread(filenames(2).name,'OXYK'); % Oxygen concentration in umol/kg
dens2017=ncread(filenames(2).name,'SIG0'); % Density anomaly referred to p=0
n2017=length(lat2017);

%% Separation of transects

ridge_2015=[68:84 89:102 110:133];
north_2015=46:67;
ovide_2015=26:45;
south_2015=[3:10 15 16 21:25];

ridge_2017=[56:69 76:125];
south_2017=[1:8 11:17];
ovide_2017=[18:20 22:24 27:28 43:-1:41 38:-1:31];
north_2017=[44:55 57];

transect={'ridge','south','ovide','north'};
transects2015={ridge_2015, south_2015, ovide_2015, north_2015};
transects2017={ridge_2017, south_2017, ovide_2017, north_2017};
clear ridge_2015 ridge_2017 south_2015 south_2017 ovide_2015 ovide_2017 north_2015 north_2017

q=1;
a=transects2015{q};

%% Separation of transect

lat2015=lat2015(a); n2015=length(lat2015);
lon2015=lon2015(a);
bottom2015=bottom2015(a);
pres2015=pres2015(:,a);
temp2015=temp2015(:,a);
sal2015=sal2015(:,a);
oxy2015=oxy2015(:,a);
dens2015=dens2015(:,a);

%% Then, we load the OMP variables

load RREX2015_OMP_WaterMass_Ridge.mat

%% We convert back to the same lat/lon coordinates as the original data

gamma_OMP=NaN(1420,n2015)
for i=1:length(a)
    aux=find(lat==lat2015(i));
    p_OMP(1:length(aux),i)=pres(aux);
    gamma_OMP(1:length(aux),i)=gamma_n(aux);
    NACW_OMP(1:length(aux),i)=NACW(aux);
    SAW_OMP(1:length(aux),i)=SAW(aux);
    SPMW_OMP(1:length(aux),i)=SPMW(aux);
    IW_OMP(1:length(aux),i)=IW(aux);
    SAIW_OMP(1:length(aux),i)=SAIW(aux);
    ISW_OMP(1:length(aux),i)=ISW(aux);
    LSW_OMP(1:length(aux),i)=LSW(aux);
    LDW_OMP(1:length(aux),i)=LDW(aux);
    ISOW_OMP(1:length(aux),i)=ISOW(aux);
end

% Defines a cell variable that will call each water mass percentage

WM = {'NACW', 'SAW', 'SPMW', 'IW', 'SAIW', 'ISW', 'LSW', 'LDW', 'ISOW'};

%% Plot

if q==1
    X=lat2015;
else
    X=lon2015;
end

figure(); set(gcf, 'Position',  [100, 100, 1400, 800])
for i=1:length(WM)
    WM_percent=dynamicvariable(WM{i},'_OMP');
    subplot(3,3,i)
    pcolor(X,p_OMP,WM_percent); shading interp
    c=colorbar; caxis([0 1]); colormap(slanCM('turbo'));
    set(gca,'YDir','reverse'); ylim([100 4000])
    ylabel('Pressure [dbar]'); title(WM{i});
    hold on;
    h=area(X,bottom2015,5000,'facecolor',[0.6 0.6 0.6], 'edgecolor','k');
    hold off

end

sgtitle('Ridge Water Masses','FontSize',17, 'FontWeight', 'bold','FontName','LMRoman10')

% saveas(gcf,'1.Hydrography_ridge.png')
