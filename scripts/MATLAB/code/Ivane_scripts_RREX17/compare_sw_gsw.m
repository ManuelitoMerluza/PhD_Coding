% author(s): I. Salaün 10/2018 from H. Mercier & T. Petit (RREX2015)
%
% description : 


%% ========================================================================
clear all; 
close all;

addpath(genpath('/home/lpo5/herle/matlab_environnement_de_traitement/devlp/logiciels_lpo/matlab/outils_matlab/seawater/seawater_330_its90_lpo'));
addpath(genpath('/home/lpo5/herle/matlab_environnement_de_traitement/devlp/logiciels_lpo/matlab/outils_matlab/seawater/gsw_matlab_v3_04_TR'));

%http://www.teos-10.org/pubs/gsw/v3_04/pdf/Getting_Started.pdf

% CHOIX DE LA SECTION parmi les sections 'north', 'ovide','south' , 'ride'
section = 'ride';

rept = '/home4/homedir4/perso/isalaun/Matlab/matlab_output_RREX17/hydro_data/';
%% ========================================================================
% Definition des stations hydro pour chaque section
if strcmp(section,'north')
    xref='lo'; % lat/lg en degre N/E
    STA = [44:55 57]; STA=STA(:); nsta=size(STA,1); npair=nsta-1;
    file_save=['dens_sw_vs_gsw_',section,];
    
elseif strcmp(section,'ovide')
    xref='lo';
    STA = [18:20 22:24 27:28 43:-1:41 38:-1:31];STA=STA(:); nsta=size(STA,1); npair=nsta-1;
    file_save=['dens_sw_vs_gsw_',section,];
    
elseif strcmp(section,'south')
    xref='lo';
    STA = [1:8 11:17]; STA=STA(:); nsta=size(STA,1); npair=nsta-1;
    file_save=['dens_sw_vs_gsw_',section,];
    
elseif strcmp(section,'ride')
    xref='lat';
    STA = [56:69 76:125]; STA=STA(:); nsta=size(STA,1); npair=nsta-1;
    file_save=['dens_sw_vs_gsw_',section,];
    
end

%% ========================================================================
%%% Lecture des fichiers hydro
fctd = '/home/lpo5/HYDROCEAN/MLT_NC/LPO/RREX/RREX17/rr17_PRES.nc';
% on sectionne la data et supprime la premiere station 0 (station test)

SP = ncread(fctd,'PSAL'); %pratical salinity (psu)
SP = SP(:,2:end); SP = SP(:,STA);
T = ncread(fctd,'TEMP'); %in situ temperature (degree celsius)
T = T(:,2:end); T = T(:,STA);
Tpot = ncread(fctd,'TPOT'); %potential temperature (degree celsius)
Tpot = Tpot(:,2:end); Tpot = Tpot(:,STA);
P = ncread(fctd,'PRES'); %Sea Pressure (decibar)
P = P(:,2:end); P = P(:,STA);

%H = ncread(fctd,'DYNH'); % hauteur dyn dans fichier hydro calculé par Herlé pendant la campagne avec seawater
%H = H(:,2:end); H = H(:,STA);

lat = ncread(fctd,'LATITUDE'); 
lat = lat(2:end); lat = lat(STA);
lg = ncread(fctd,'LONGITUDE'); 
lg = lg(2:end); lg = lg(STA);

%% ========================================================================

%%% Calcul de la hauteur dynamique et de la densité par SeaWater_90_lpo

rho_sw = sw_dens(SP,T,P); %Density of Sea Water using UNESCO 1983 (EOS 80) polynomial

ga_sw = sw_gpan(SP,T,P);
%sw_gpan => sw_svan (Specific volume anomaly) => sw_dens 


%%% Calcul de la hauteur dynamique et de la densité par GibbsSeaWater

SA = gsw_SA_from_SP(SP,P,lg,lat); %Absolute Salinity from Practical Salinity
CT = gsw_CT_from_t(SA,T,P); %Conservative Temperature of seawater from in-situ temperature

rho_gsw_exact = gsw_rho_CT_exact(SA,CT,P); %in-situ density from Absolute Salinity and Conservative Temperature


%% sauvegarde des données ADCP le long de la section

save([rept file_save],'SA','CT','rho_gsw_exact','rho_sw', 'ga_sw');
%save([rept file_save],'SA','CT','rho_gsw_exact','rho_sw', 'ga_sw', 'ga_gsw');


%% ========================================================================
% [bathy_ship,X_bathy,Y_bathy]=bathy_bateau_17(section);
% bathy_ship = bathy_ship.*1e-3;
% 
% if strcmp(section,'south')||strcmp(section,'ride')||strcmp(section,'ovide');
% 
% if strcmp(section,'south')||strcmp(section,'ovide');
%     ind_bad=find(bathy_ship(2:end-1)<1);
% elseif strcmp(section,'ride'); 
%     ind_bad=find(bathy_ship(2:end-1)<0.1);
% end  
%  
% for i=1:length(ind_bad)
%     j=length(ind_bad)+1-i;
%     bathy_ship(ind_bad(j)+1)=[];
%     X_bathy(ind_bad(j)+1)=[];
%     Y_bathy(ind_bad(j)+1)=[];
% end    
% 
% if strcmp(section,'south')||strcmp(section,'ovide');
%     ind_bad=find(3.2<bathy_ship(2:end-3));
% elseif strcmp(section,'ride'); 
%     ind_bad=find(4.5<bathy_ship(2:end-3));
% end   
% 
% for i=1:length(ind_bad)
%     j=length(ind_bad)+1-i;
%     bathy_ship(ind_bad(j)+1)=[];
%     X_bathy(ind_bad(j)+1)=[];
%     Y_bathy(ind_bad(j)+1)=[];
% end
% 
% end


% figure;
% set(gcf,'PaperType','A4','PaperOrientation','landscape','PaperUnits','centimeters','PaperPosition',[1,1,24,18],'Posi',[185 0 1200 800]);
% 
% %[c,h]=contour(repmat(lat,length(z_abs),1),repmat(z_abs,1,length(lat)),rho_gsw_esxact-1000,[27.52 27.71 27.8],'-k','LineWidth',1);
% %[c,h]=contourf(X1(:),zat(1:4339).*1e-3,v(1:4339,:),vcol);
% [c,h]=contour(X_bathy(:),zat(1:4339).*1e-3,rho_gsw_esxact-1000,[27.52 27.71 27.8],'-k','LineWidth',1);
% 
% set(gca,'ydir','reverse')
% %xlabel(xlab); ylabel('Depth (km)');
%  
% hold on; fill(X_bathy(:),bathy_ship,[0.5 0.5 0.5]);
% 
% if strcmp(section,'ovide');
%     ylim([0 3.2]);
%     xlim([-37 -27]);
% elseif strcmp(section,'south');
%     ylim([0 3.2]);
%     xlim([-38.5 -31]);
% elseif strcmp(section,'north');
%     ylim([0 3]);
%     xlim([-34 -20]);
% elseif strcmp(section,'ride');
%     ylim([0 4.35]); 
%     xlim([48 64]);
% end


















