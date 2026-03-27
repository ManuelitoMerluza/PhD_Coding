% We load paths and colorbars
addpath(genpath('C:/Users/mitg1n25/Desktop/PhD/PhD_Coding'))
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
load("RREX2017_processed_VMP6000_ManuTest.mat")

% And take a look at the folder that has the .nc processed
% data so we can extract the lat and lon

folder='C:\Users\mitg1n25\Desktop\PhD\PhD_Coding\data\RREX/113067';
filenames = dir(fullfile(folder,'*.nc'));

n=length(filenames);
lat=NaN(1,n); lon=NaN(1,n);
for i=1:length(filenames)
    lat(1,i)=ncread(filenames(i).name,'Latitude_VMP',1,1);
    lon(1,i)=ncread(filenames(i).name,'Longitude_VMP',1,1);
end

RREX2017_pos_VMP=[lon',lat'];
writematrix(RREX2017_pos_VMP,'RREX2017_pos_VMP.txt','Delimiter','\t')

oxygen=ncread("RREX2017_CTDO.nc",'OXYK'); % Loads Oxygen values in umol/kg
lat_orig=ncread("RREX2017_CTDO.nc",'LATITUDE'); 
lon_orig=ncread("RREX2017_CTDO.nc",'LONGITUDE'); 
pres_orig=ncread("RREX2017_CTDO.nc",'PRES'); 
pres_orig=pres_orig(:,119);

%% Delete epsT2 because it didn't worked correctly

clear epsT2 Xif2

%% Calculate neutral density (gamma_n)

pres_n=repmat(pres',1,78); % Make the arrays have the same size
lon_n=repmat(lon,1000,1);
lat_n=repmat(lat,1000,1);

gamma_n = eos80_legacy_gamma_n(S,T,pres_n,lon_n,lat_n);

%% Interpolate Oxygen so it can have the same coordinates as temp

% Step 1: For each pressure level, interpolate horizontally to target points
O2_horizontal = zeros(length(pres_orig), length(lat));

for p = 1:length(pres_orig)
    % Create 2D interpolant for this pressure level
    F2D = scatteredInterpolant(lat_orig(:), lon_orig(:), ...
                               oxygen(p, :)', 'nearest', 'none');
    
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
                              'nearest', 'extrap');
end

% Create bathymetry mask
mask = isnan(theta); % True where above seafloor

% Apply mask
O2_interp(mask) = NaN; 


%% Plot to see how it ended
% 
figure()
subplot(1,2,1)
pcolor(lat,pres,O2_interp); clim([240 300])
shading interp
colorbar
subplot(1,2,2)
pcolor(lat,pres,T); clim([2 10])
shading interp
colorbar

%% Save the VMP CTD data for the postprocessing

OUTPUT.S=S;
OUTPUT.T=S;
OUTPUT.theta=theta;
OUTPUT.gamman=gamma_n;
OUTPUT.oxygen=O2_interp;

matname=fullfile('C:\Users\mitg1n25\Desktop\PhD\PhD_Coding\data\RREX\2017_ProcessedVMP','RREX2017_VMP_CTD.mat');

save(matname, '-struct' , 'OUTPUT')

%% Calculate the vertical gradients of T and S

[~,grT]=gradient(T,-4);
[~,grS]=gradient(S,-4);

%% Transect plots

% First we separate the different transects
ridge=[38:41 48:78]; trans1=9:24; trans2=26:37;

% We delete the overestimated values
trans1(12:13)=[] ;

%% Save Ridge Values

% RIDGE.epsilon=epsSH1(:,ridge);
% RIDGE.chi=Xif1(:,ridge);
% RIDGE.longitude=lon(ridge);
% RIDGE.latitude=lat(ridge);
% RIDGE.pres=pres;
% RIDGE.T=T(:,ridge);
% RIDGE.S=S(:,ridge);
% RIDGE.theta=theta(:,ridge);
% RIDGE.gamman=gamma_n(:,ridge);
% RIDGE.oxygen=O2_interp(:,ridge);
% RIDGE.grT=grT(:,ridge);
% RIDGE.grS=grS(:,ridge);
% 
% % save('RREX2017_VMP_Ridge.mat', '-struct' , 'RIDGE')
% 
% %% Save Cross Ridge Values
% 
% XRIDGE.epsilon=epsSH2(:,trans1);
% XRIDGE.chi=Xif1(:,trans1);
% XRIDGE.longitude=lon(trans1);
% XRIDGE.latitude=lat(trans1);
% XRIDGE.pres=pres;
% XRIDGE.T=T(:,trans1);
% XRIDGE.S=S(:,trans1);
% XRIDGE.theta=theta(:,trans1);
% XRIDGE.gamman=gamma_n(:,trans1);
% XRIDGE.oxygen=O2_interp(:,trans1);
% XRIDGE.grT=grT(:,trans1);
% XRIDGE.grS=grS(:,trans1);
% 
% save('RREX2017_VMP_CrossRidge.mat', '-struct' , 'XRIDGE')
% 
% %% Save West Ridge Values
% 
% WRIDGE.epsilon=epsSH1(:,trans2);
% WRIDGE.chi=Xif1(:,trans2);
% WRIDGE.longitude=lon(trans2);
% WRIDGE.latitude=lat(trans2);
% WRIDGE.pres=pres;
% WRIDGE.T=T(:,trans2);
% WRIDGE.S=S(:,trans2);
% WRIDGE.theta=theta(:,trans2);
% WRIDGE.gamman=gamma_n(:,trans2);
% WRIDGE.oxygen=O2_interp(:,trans2);
% WRIDGE.grT=grT(:,trans2);
% WRIDGE.grS=grS(:,trans2);
% 
% save('RREX2017_VMP_WestRidge.mat', '-struct' , 'WRIDGE')

