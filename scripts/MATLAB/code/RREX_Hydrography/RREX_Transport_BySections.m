%% This script will be used for calculating specific transport in parts of the transect
%  transport was computed using Ivane's functions (Modified by Manuel Torres :3)

%% Loads paths, colormap and defines text properties and 

addpath(genpath('C:/Users/mitg1n25/Desktop/PhD/PhD_coding'))
set(0, 'DefaultAxesFontSize', 12);
set(0, 'DefaultAxesTitleFontSizeMultiplier', 1.15)
set(0, 'DefaultAxesFontName', 'LMRoman17');
set(0, 'DefaultAxesFontWeight', 'bold');

% Paths where Abosolute Velocity Data is stored
path2015='C:/Users/mitg1n25/Desktop/PhD/PhD_Coding/data/RREX/Ivane_output_RREX15/transport_geo/';
path2017='C:/Users/mitg1n25/Desktop/PhD/PhD_Coding/data/RREX/Ivane_output_RREX17/transport_geo/';
Ekpath2017='C:/Users/mitg1n25/Desktop/PhD/PhD_Coding/data/RREX/Ivane_output_RREX17/transport_Ekman/';
Ekpath2015='C:/Users/mitg1n25/Desktop/PhD/PhD_Coding/data/RREX/Ivane_output_RREX15/transport_Ekman/';

% It is important to have access to:
% 1) Transport between stations
% 2) Ekman Transport
% 3) Original CTD data (for determining density layers)

%% First lets define the transect and load the variables

transect={'ride','south','ovide','north'};

% This is a modified version of the stations where I exclude the last one
% in order to compare to the transports locations (N = number of stations-1)
ridge_2015=[68:84 89:102 110:132];
north_2015=46:66;
ovide_2015=26:44;
south_2015=[3:10 15 16 21:24];

ridge_2017=[56:69 76:124];
south_2017=[1:8 11:16];
ovide_2017=[18:20 22:24 27:28 43:-1:41 38:-1:32];
north_2017=[44:55 56];

%% Loads and Defines density ranges

folder='C:/Users/mitg1n25/Desktop/PhD/PhD_Coding/data/RREX/Hydrography';
filenames = dir(fullfile(folder,'*CTDO.nc')); % Check the variable position

dens2015_CTD=ncread(filenames(1).name,'SIG0'); % Density anomaly referred to p=0
% Calculates density in the middle points in order to compare to transport
dens2015_CTD= (dens2015_CTD(:,1:end-1)+dens2015_CTD(:,2:end))*0.5;

dens2017_CTD=ncread(filenames(2).name,'SIG0'); dens2017_CTD=dens2017_CTD(:,2:end);
dens2017_CTD= (dens2017_CTD(:,1:end-1)+dens2017_CTD(:,2:end))*0.5;

layer1_2015=dens2015_CTD < 27.52; 
layer1_2017=dens2017_CTD < 27.52;

layer2_2015=dens2015_CTD >= 27.52 & dens2015_CTD<27.71;
layer2_2017=dens2017_CTD >= 27.52 & dens2017_CTD<27.71; 

layer3_2015=dens2015_CTD >= 27.71 & dens2015_CTD<27.8;
layer3_2017=dens2017_CTD >= 27.71 & dens2017_CTD<27.8;

layer4_2015=dens2015_CTD >= 27.8;
layer4_2017=dens2017_CTD >= 27.8;

transects2015={ridge_2015, south_2015, ovide_2015, north_2015};
transects2017={ridge_2017, south_2017, ovide_2017, north_2017};
clear ridge_2015 ridge_2017 south_2015 south_2017 ovide_2015 ovide_2017 north_2015 north_2017

% %% The same process but for the different layers
% 
% % Selects the stations from the layers
% layer1 = layer1_2015(:,transects2015{1}); layer2 = layer2_2015(:,transects2015{1}); 
% layer3 = layer3_2015(:,transects2015{1}); layer4 = layer4_2015(:,transects2015{1}); 
% 
% % Calculates the transport between layers
% for i=1:length(transects2015{1})
%     tr1=tr_z(layer1(:,i),i); tr2=tr_z(layer2(:,i),i);
%     tr3=tr_z(layer3(:,i),i); tr4=tr_z(layer4(:,i),i);
%     T_layer1(i) = sum(tr1); T_layer2(i) = sum(tr2);
%     T_layer3(i) = sum(tr3); T_layer4(i) = sum(tr4); 
% end

%% Ridge

% 2015
load([path2015 'transport_RREX15_' transect{1} '_use.mat']);
Ekride2015 = load([Ekpath2015 'trsp_ek_' transect{1} '_era_moyenne.mat']);
T_tot=T_tot+(Ekride2015.tr_ek)'; % Total transport

% 'linear' (default) | 'nearest' | 'next' | 'previous' | 'pchip' | 'cubic' | 'makima' | 'spline'
X_sum=[X_ctd(1); X];
T=zeros(1,length(T_tot)+1); T(2:end)=T_tot;
% This is for centering the start of the transport at zero
T=interp1(X_sum,T,X_ctd,'pchip','extrap'); %pchip
T_sum=cumsum(T);

X_sum2015=X_sum; T_sum2015=T_sum;

T_ride_ovide=T_sum(17);
T_ride_south=sum(T(18:31));
T_ride_nac=sum(T(32:40));
T_ride_end=sum(T(41:end));

T_ride2015=round([T_ride_end T_ride_nac T_ride_south T_ride_ovide],1)
% display(T_ride2015)

% 2017
load([path2017 'transport_RREX17_' transect{1} '_pfit.mat']);

Ekride2017 = load([Ekpath2017 'trsp_ek_' transect{1} '_era_moyenne.mat']);
T_tot=T_tot + (Ekride2017.tr_ek)';

T=zeros(1,length(T_tot)+1); T(2:end)=T_tot;
T_sum2017=cumsum(T'); X_sum2017=X;

T_ride_ovide=T_sum2017(14);
T_ride_south=sum(T(15:30));
T_ride_nac=sum(T(31:49));
T_ride_end=sum(T(50:62));

T_ride2017=round([T_ride_end T_ride_nac T_ride_south T_ride_ovide],1);

% We repeat the same process but separating by layers

% We save the variables
% save('C:/Users/mitg1n25/Desktop/PhD/PhD_Coding/data/RREX/Ivane_output_RREX15/transport_geo/RREX_T_tot_ridge.mat',"T_ride2017","T_ride2015", ...
%     "T_sum2015","X_sum2015","T_sum2017","X_sum2017");


%% South

load([path2015 'transport_RREX15_' transect{2} '_pfit.mat']);
Eksouth2015 = load([Ekpath2015 'trsp_ek_' transect{2} '_era_moyenne.mat']);
T_tot=T_tot+(Eksouth2015.tr_ek)'; % Total transport

X_sum1=[X_ctd(9); X(9:14)];
T_sum1=zeros(1,7); T_sum1(2:end)=T_tot(9:14);
% Interpolates to CTD coordinates to have the same size as 2017
T_sum1=interp1(X_sum1,T_sum1,X_ctd(9:end),'linear','extrap');
T_sum1=cumsum(T_sum1);

X_sum2=[X(1:8); X_ctd(9)]; T_sum2=zeros(1,9);
T_sum2(1:8)=T_tot(1:8); T_sum2=interp1(X_sum2,T_sum2,X_ctd(1:9),'nearest','extrap');
T_sum2=cumsum(T_sum2,'reverse');
X_sum2015=X_ctd; T_sum2015=[T_sum2(1:8); T_sum1];

T_south_west=T_sum1(6) ; % South transect west of ridge
T_south_east=T_sum2(1) ; % South transect east of ridge

T_south2015=round([T_south_west T_south_east],1);

load([path2017 'transport_RREX17_' transect{2} '_pfit.mat']);
Eksouth2017 = load([Ekpath2017 'trsp_ek_' transect{2} '_era_moyenne.mat']);
T_tot=T_tot+(Eksouth2017.tr_ek)'; % Total transport

X_sum1=[X(8:15)]; T_sum1=zeros(1,8); T_sum1(2:end)=cumsum(T_tot(8:14));
X_sum2=[X(1:7)]; T_sum2=cumsum(T_tot(1:7),'reverse');
X_sum2017=[X_sum2 ; X_sum1]; T_sum2017=[T_sum2 T_sum1];

T_south_west=T_sum2(2) ; % South transect west of ridge
T_south_east=T_sum1(7) ; % South transect east of ridge

T_south2017=round([T_south_west T_south_east],1);

%save('C:/Users/mitg1n25/Desktop/PhD/PhD_Coding/data/RREX/Ivane_output_RREX15/transport_geo/RREX_T_tot_south.mat',"T_south2017","T_south2015","T_sum2015","X_sum2015","T_sum2017","X_sum2017");

%% OVIDE

% 2015
load([path2015 'transport_RREX15_' transect{3} '_pfit.mat']);
Ekovide2015 = load([Ekpath2015 'trsp_ek_' transect{3} '_era_moyenne.mat']);
T_tot=T_tot+(Ekovide2015.tr_ek)'; % Total transport

X_sum1=[X(1:9); X_ctd(10)];
T_sum1=zeros(1,10); T_sum1(1:end-1)=T_tot(1:9);
T_sum1=interp1(X_sum1,T_sum1,X_ctd(1:10),'next','extrap');
T_sum1=cumsum(T_sum1,'reverse');

X_sum2=[X_ctd(10); X(10:end)];
T_sum2=zeros(1,11); T_sum2(2:end)=T_tot(10:end);
T_sum2=interp1(X_sum2,T_sum2,X_ctd(10:end),'previous','extrap');
T_sum2=cumsum(T_sum2);

X_sum2015=X_ctd; T_sum2015=[T_sum1; T_sum2(2:end)];

T_ovide_west=T_sum1(4) ; % OVIDE transect west of ridge
T_ovide_east=T_sum2(6) ; % OVIDE transect east of ridge

T_ovide2015=round([T_ovide_west T_ovide_east],1);

% 2017

load([path2017 'transport_RREX17_' transect{3} '_pfit.mat']);
%load([path2017 'tr_z_RREX17_' transect{3} '_pfit.mat'],'tr_z'); T_tot=sum(tr_z,1);
Ekovide2017 = load([Ekpath2017 'trsp_ek_' transect{3} '_era_moyenne.mat']);
T_tot=T_tot+(Ekovide2017.tr_ek)'; % Total transport

T=zeros(1,19); T(1:9)=T_tot(1:9); T(11:end)=T_tot(10:end);
[X, s]=sort(X); T=T(s); X_ctd=X_ctd(s);

T_sum1=T(1:10);
T_sum1=cumsum(T_sum1,'reverse');

T_sum2=T(10:end); T_sum2=cumsum(T_sum2);
X_sum2017=X; T_sum2017=[T_sum1 T_sum2(2:end)];

T_ovide_west=T_sum2017(6) ; % OVIDE transect west of ridge
T_ovide_east=T_sum2017(16) ; % OVIDE transect east of ridge

T_ovide2017=round([T_ovide_west T_ovide_east],1)

% save('C:/Users/mitg1n25/Desktop/PhD/PhD_Coding/data/RREX/Ivane_output_RREX15/transport_geo/RREX_T_tot_ovide.mat',"T_ovide2017","T_ovide2015","T_sum2015","X_sum2015","T_sum2017","X_sum2017");

%% North

% 2015
load([path2015 'transport_RREX15_' transect{4} '_pfit.mat']);
Eknorth2015 = load([Ekpath2015 'trsp_ek_' transect{4} '_era_moyenne.mat']);
T_tot=T_tot+(Eknorth2015.tr_ek)'; % Total transport

[X, s]=sort(X); T_tot=T_tot(s); X_ctd=sort(X_ctd);

X_sum1=[X(1:11); X_ctd(12)];
T_sum1=zeros(1,12); T_sum1(1:end-1)=T_tot(1:11);
T_sum1=interp1(X_sum1,T_sum1,X_ctd(1:12),'next','extrap');
T_sum1=cumsum(T_sum1,'reverse');

X_sum2=[X_ctd(12); X(12:end)];
T_sum2=zeros(1,11); T_sum2(2:11)=T_tot(12:end);
T_sum2=interp1(X_sum2,T_sum2,X_ctd(12:end),'linear','extrap');
T_sum2=cumsum(T_sum2);

T_north_west=T_sum1(5) ; % north transect west of ridge
T_north_east=T_sum2(7) ; % north transect east of ridge

X_sum2015=X_ctd; T_sum2015=[T_sum1; T_sum2(2:end)];
T_north2015=round([T_north_west T_north_east],1)

% 2017

load([path2017 'transport_RREX17_' transect{4} '_cstslope.mat'])
Eknorth2017 = load([Ekpath2017 'trsp_ek_' transect{4} '_era_moyenne.mat']);
T_tot=T_tot+(Eknorth2017.tr_ek)'; % Total transport

T_sum1=zeros(1,13); T_sum1(1:end-1)=T_tot;
T_sum1=cumsum(T_sum1,'reverse');

T_north_west=T_sum1(8) ; % north transect west of ridge

X_sum2017=X; T_sum2017=T_sum1;
T_north2017=round(T_north_west,1);

% save('C:/Users/mitg1n25/Desktop/PhD/PhD_Coding/data/RREX/Ivane_output_RREX15/transport_geo/RREX_T_tot_north.mat',"T_north2017","T_north2015","T_sum2015","X_sum2015","T_sum2017","X_sum2017");