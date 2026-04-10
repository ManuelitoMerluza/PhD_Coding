%% Trace les cartes de fonds et localisation des stations hydro
clear all
close all

addpath(genpath('C:/Users/mitg1n25/Desktop/PhD/PhD_Coding'))

%%
fsadcp = 'C:/Users/mitg1n25/Desktop/PhD/PhD_Coding/data/RREX/Ivane_Hydro2017/sadcp/OS38/nce/';
file_sadcp = 'AT_RREX17_OS38_osite_m09_004_12_fhv21_sec_02mx21.nc';

[UVEL_ADCP, VVEL_ADCP, SecLat, SecLon, DEPH, JULD, U_TIDE, V_TIDE, INDICE, BATHY] = rsadcp_rrex([fsadcp file_sadcp]);

%% Localisation des stations hydro de RREX17 
zone_visu=[50 65 -45 -15];
proj='mercator';

file_bathy = 'C:/Users/mitg1n25/Desktop/PhD/PhD_Coding/data/data_for_Ivane_toolbox/ETOPO1_Bed_g_gmt4.nc';
lat_bathy = ncread(file_bathy,'y'); % a adapter par l'utilisateur
lon_bathy = ncread(file_bathy,'x'); % a adapter par l'utilisateur
min_lat = zone_visu(1);                        % a adapter par l'utilisateur
max_lat = zone_visu(2);                       % a adapter par l'utilisateur
min_lon = zone_visu(3);                     % a adapter par l'utilisateur
max_lon = zone_visu(4);                        % a adapter par l'utilisateur
lat1 = find(lat_bathy>min_lat);
lat1 = max(lat1(1)-1,1);
lat2 = find(lat_bathy<max_lat);
lat2 = min(lat2(end)+1,length(lat_bathy));
lon1 = find(lon_bathy>min_lon);
lon1 = max(lon1(1)-1,1);
lon2 = find(lon_bathy<max_lon);
lon2 = min(lon2(end)+1,length(lon_bathy));
bathy=ncread(file_bathy,'z',[lon1 lat1],[(lon2-lon1+1) (lat2-lat1+1)])'; % a adapter par l'utilisateur
lat_bathy = lat_bathy(lat1:lat2);
lon_bathy = lon_bathy(lon1:lon2);

xTlabel = [-45;-40;-35;-30;-25;-20;-15]; yTlabel = [50;55;60;65];

%%% Figure localisation des stations (propriete de m_grid via m_grid('get'))
figure(1);
set(gca,'fontsize',12)
m_proj(proj,'long',[zone_visu(3) zone_visu(4)],...
                 'lat',[zone_visu(1) zone_visu(2)]); 
m_grid('xtick',[zone_visu(3):5:zone_visu(4)],...
       'ytick',[zone_visu(1):5:zone_visu(2)],'xticklabels',xTlabel,'yticklabels',yTlabel,...
       'box','on','color',[0 0 0],'linewidth',2.5,'linestyle',':','tickdir','out')
a1 = gca;
a1.FontSize = 12;
a1.FontWeight = 'bold';

hold on; m_contourf(lon_bathy,lat_bathy,bathy,[-5000:1000:-1000 -500 0],'Linestyle','none')
load blues_tp_v2.mat; colormap(blues_tp_v2(end:-1:1,:)); 
hold on; m_contour(lon_bathy,lat_bathy,bathy,[0 0],'k','linewidth',1);
xlabel('Longitude (°W)'); ylabel('Latitude (°N)');

% On trace la position des stations CTD
fctd = 'C:/Users/mitg1n25/Desktop/PhD/PhD_Coding/data/RREX/Ivane_Hydro2017/ctd/nc/rr17_PRES.nc';
lat = ncread(fctd,'LATITUDE'); lg = ncread(fctd,'LONGITUDE'); lat = lat(2:end); lg = lg(2:end);
latitude = [lat(2:17)' lat(18:24)' lat(27:29)' lat(31:43)' lat(44:55)' lat(56:69)' lat(76:125)'];
longitude = [lg(2:17)' lg(18:24)' lg(27:29)' lg(31:43)' lg(44:55)' lg(56:69)' lg(76:125)'];

hold on; m_plot(longitude,latitude,'k.','MarkerSize',5)
%hold on; m_plot(SecLon,SecLat,'k')

%print -dpng /home4/homedir4/perso/isalaun/Matlab/figures/map_RREX17.png
%saveas(gcf,'/home4/homedir4/perso/isalaun/Matlab/figures/Sections_Zonales/scheme.eps','epsc')


