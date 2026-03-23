% We load paths and colorbars
addpath(genpath('C:/Users/mitg1n25/Desktop/PhD/Year 1 - 2026'))
%addpath(genpath('D:/Respaldo PC/iop/materia/Magister/Semestre 2/PRODIGY/m_map/'))
set(0, 'DefaultAxesFontSize', 12);
set(0, 'DefaultAxesTitleFontSizeMultiplier', 1.15)

map = load('colormap_RREX.mat'); % colormap(map.cmap);
load REXXBathymetry.mat


% This is the script I'll use to recover the variables that will be used in
% Bieito's python script for water mass transformations
% For that I'll need to take epsilon, chi and usefull ctd data from the
% different transects

%% First, we load the variables calculated previously
load("RREX2015_processed_VMP6000_ManuTest.mat")

% And take a look at the folder that has the .nc processed
% data so we can extract the lat and lon

folder='C:/Users/mitg1n25/Desktop/PhD/Year 1 - 2026/Microstructure Data/RREX/113063';
filenames = dir(fullfile(folder,'*.nc'));

n=length(filenames);
lat=NaN(1,n); lon=NaN(1,n);
for i=1:length(filenames)
    lat(1,i)=ncread(filenames(i).name,'Latitude_VMP',1,1);
    lon(1,i)=ncread(filenames(i).name,'Longitude_VMP',1,1);
end

RREX2015_pos_VMP=[lon',lat'];
writematrix(RREX2015_pos_VMP,'RREX2015_pos_VMP.txt','Delimiter','\t')

oxygen=ncread("RREX2015_CTDO.nc",'OXYK'); % Loads Oxygen values in umol/kg
lat_orig=ncread("RREX2015_CTDO.nc",'LATITUDE'); 
lon_orig=ncread("RREX2015_CTDO.nc",'LONGITUDE'); 
pres_orig=ncread("RREX2015_CTDO.nc",'PRES'); 
pres_orig=pres_orig(:,1);

%% Calculate neutral density (gamma_n)

pres_n=repmat(pres',1,58); % Make the arrays have the same size
lon_n=repmat(lon,1000,1);
lat_n=repmat(lat,1000,1);

gamma_n = eos80_legacy_gamma_n(S,T,pres_n,lon_n,lat_n);


%% Interpolate Oxygen so it can have the same coordinates as temp

% Step 1: For each pressure level, interpolate horizontally to target points
O2_horizontal = zeros(length(pres_orig), length(lat));

for p = 1:length(pres_orig)
    % Create 2D interpolant for this pressure level
    F2D = scatteredInterpolant(lat_orig(:), lon_orig(:), ...
                               oxygen(p, :)', 'linear', 'none');
    
    % Interpolate to all target points
    O2_horizontal(p, :) = F2D(lat, lon);
end

% Step 2: For each target location, interpolate vertically
O2_interp = zeros(length(pres), length(lat));

for h = 1:length(lat)
    % Extract vertical profile at this target location
    profile = O2_horizontal(:, h);
    
    % Interpolate to target pressure levels
    O2_interp(:, h) = interp1(pres_orig, profile, pres, ...
                              'linear', 'extrap');
end

%% Plot to see how it ended

% figure()
% subplot(1,2,1)
% pcolor(lat,pres,O2_interp)
% shading interp
% colorbar
% subplot(1,2,2)
% pcolor(lat,pres,T)
% shading interp
% colorbar

%% Save the VMP CTD data for the postprocessing

OUTPUT.S=S;
OUTPUT.T=S;
OUTPUT.theta=theta;
OUTPUT.gamman=gamma_n;
OUTPUT.oxygen=O2_interp;

save('RREX2015_VMP_CTD.mat', '-struct' , 'OUTPUT')

%% Calculate the vertical gradients of T and S

[~,grT]=gradient(T,-4);
[~,grS]=gradient(S,-4);

%% Transect plots

% First we separate the different transects
ridge=[38:47 49:56]; trans1=27:37; trans2=17:26;

% We delete the overestimated values

%% Save Ridge Values

RIDGE.epsilon=epsSH2(:,ridge);
RIDGE.chi=Xif2(:,ridge);
RIDGE.longitude=lon(ridge);
RIDGE.latitude=lat(ridge);
RIDGE.pres=pres;
RIDGE.T=T(:,ridge);
RIDGE.S=S(:,ridge);
RIDGE.theta=theta(:,ridge);
RIDGE.gamman=gamma_n(:,ridge);
RIDGE.oxygen=O2_interp(:,ridge);
RIDGE.grT=grT(:,ridge);
RIDGE.grS=grS(:,ridge);

% save('RREX2015_VMP_Ridge.mat', '-struct' , 'RIDGE')


%% Save West Ridge Values

WRIDGE.epsilon=epsSH2(:,trans1);
WRIDGE.chi=Xif1(:,trans1);
WRIDGE.longitude=lon(trans1);
WRIDGE.latitude=lat(trans1);
WRIDGE.pres=pres;
WRIDGE.T=T(:,trans1);
WRIDGE.S=S(:,trans1);
WRIDGE.theta=theta(:,trans1);
WRIDGE.gamman=gamma_n(:,trans1);
WRIDGE.oxygen=O2_interp(:,trans1);
WRIDGE.grT=grT(:,trans1);
WRIDGE.grS=grS(:,trans1);

save('RREX2015_VMP_WestRidge.mat', '-struct' , 'WRIDGE')

%% Save East Ridge Values

ERIDGE.epsilon=epsSH2(:,trans2);
ERIDGE.chi=Xif1(:,trans2);
ERIDGE.longitude=lon(trans2);
ERIDGE.latitude=lat(trans2);
ERIDGE.pres=pres;
ERIDGE.T=T(:,trans2);
ERIDGE.S=S(:,trans2);
ERIDGE.theta=theta(:,trans2);
ERIDGE.gamman=gamma_n(:,trans2);
ERIDGE.oxygen=O2_interp(:,trans2);
ERIDGE.grT=grT(:,trans2);
ERIDGE.grS=grS(:,trans2);

save('RREX2015_VMP_EastRidge.mat', '-struct' , 'ERIDGE')