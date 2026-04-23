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

% It is important to have access to:
% 1) Transport between stations
% 2) Ekman Transport (WHICH I STILL HAVEN'T CONSIDERED)

%% First lets define the transect and load the variables

transect={'ride','south','ovide','north'};
type=1; % Could be 1 (total transport) or 2 (over the triangles);

%% Ridge

ride2015 = load([path2015 'transport_RREX15_' transect{1} '_use.mat']);

if type == 2
    T=ride2015.T_up_bott_tr;
elseif type == 1
    T=ride2015.T_tot;
end

% south2015 = load([path2015 'transport_RREX15_' transect{2} '_polyfit.mat'],'T_tot','lat_ctd','X','lon_ctd');
% ovide2015 = load([path2015 'transport_RREX15_' transect{3} '_polyfit.mat'],'T_tot','lat_ctd','X','lon_ctd');
% north2015 = load([path2015 'transport_RREX15_' transect{4} '_polyfit.mat'],'T_tot','lat_ctd','X','lon_ctd');

ride_ovide=1:16 ; % Ridge transect from north to ovide at 59 N
ride_ovide_south=17:30 ; % Ridge transect from ovide to south at 56.4 N
ride_south_nac=31:40; % Ridge transect from south to North Atlanctic Current at 53.3 N
ride_nac_end=41:length(ride2015.X); % North Atlanctic Current to Faraday Fracture Zone

T_ride_ovide=sum(T(ride_ovide));
T_ride_south=sum(T(ride_ovide_south));
T_ride_nac=sum(T(ride_south_nac));
T_ride_end=sum(T(ride_nac_end));

T_ride2015=round([T_ride_ovide T_ride_south T_ride_nac T_ride_end],1);

ride2017 = load([path2017 'transport_RREX17_' transect{1} '_use.mat']);
%ride2017 = load([path2017 'transport_RREX17_' transect{1} '_use_without_manual.mat']);
Ekride2017 = load([Ekpath2017 'trsp_ek_' transect{1} '_era_moyenne.mat']);

if type == 2
    T=ride2017.T_up_bott_tr + (Ekride2017.tr_ek)';
elseif type == 1
    T=ride2017.T_tot + (Ekride2017.tr_ek)';
end

ride_ovide=1:13;
ride_ovide_south=14:29;
ride_south_nac=30:48;
ride_nac_end=49:61;

T_ride_ovide=sum(T(ride_ovide));
T_ride_south=sum(T(ride_ovide_south));
T_ride_nac=sum(T(ride_south_nac));
T_ride_end=sum(T(ride_nac_end));

T_ride2017=round([T_ride_ovide T_ride_south T_ride_nac T_ride_end],1);
display(fliplr(T_ride2017))


% if type == 2
%     save('C:/Users/mitg1n25/Desktop/PhD/PhD_Coding/data/RREX/Ivane_output_RREX15/transport_geo/RREX_T_tri_ridge.mat',"T_ride2017","T_ride2015");
% elseif type == 1
%     save('C:/Users/mitg1n25/Desktop/PhD/PhD_Coding/data/RREX/Ivane_output_RREX15/transport_geo/RREX_T_tot_ridge.mat',"T_ride2017","T_ride2015");
% end


