%% This script will be used for calculating heat and salt transport across the 
%  different transect from the RREX cruises.

% It uses the acumulated transports calculated in RREX_Transport_BySections.m
% and the hydrographic variables stored in the .nc files of the cruise

%% Loads paths, colormap and defines text properties and 

addpath(genpath('C:/Users/mitg1n25/Desktop/PhD/PhD_coding'))
set(0, 'DefaultAxesFontSize', 12);
set(0, 'DefaultAxesTitleFontSizeMultiplier', 1.15)
set(0, 'DefaultAxesFontName', 'LMRoman17');
set(0, 'DefaultAxesFontWeight', 'bold');

% Paths where Abosolute Velocity Data is stored

path='C:/Users/mitg1n25/Desktop/PhD/PhD_Coding/data/RREX/Ivane_output_RREX15/transport_geo/';

% It is important to have access to:
% 1) Transport between stations
% 2) Ekman Transport (WHICH I STILL HAVEN'T CONSIDERED)

figtitle={'Reykjanes Ridge Transect','South Cross-Ridge Transect','OVIDE Transect','North West-Ridge Transect'};
figtitle=figtitle{1}; % Title for the figure

xlims=[48 64; -38.1 -31.3;-37.3 -27.3 ;-34 -21];
xlims=xlims(1,:); % x axis limits for plotting each transect

%% First, we load the ctd variables

folder='C:/Users/mitg1n25/Desktop/PhD/PhD_Coding/data/RREX/Hydrography';
filenames = dir(fullfile(folder,'*CTDO.nc')); % Check the variable position

lat2015_CTD=ncread(filenames(1).name,'LATITUDE'); 
lon2015_CTD=ncread(filenames(1).name,'LONGITUDE');
pres2015_CTD=ncread(filenames(1).name,'PRES'); 
temp2015_CTD=ncread(filenames(1).name,'TPOT'); % potential temperature
sal2015_CTD=ncread(filenames(1).name,'PSAL'); % Practical Salinity
dens2015_CTD=ncread(filenames(1).name,'SIG0'); % Density anomaly referred to p=0
oxy2015_CTD=ncread(filenames(1).name,'OXYK'); 

lat2017_CTD=ncread(filenames(2).name,'LATITUDE'); lat2017_CTD=lat2017_CTD(2:end);
lon2017_CTD=ncread(filenames(2).name,'LONGITUDE'); lon2017_CTD=lon2017_CTD(2:end);
pres2017_CTD=ncread(filenames(2).name,'PRES'); pres2017_CTD=pres2017_CTD(:,2:end);
temp2017_CTD=ncread(filenames(2).name,'TPOT'); temp2017_CTD=temp2017_CTD(:,2:end);
sal2017_CTD=ncread(filenames(2).name,'PSAL'); sal2017_CTD=sal2017_CTD(:,2:end);
dens2017_CTD=ncread(filenames(2).name,'SIG0'); dens2017_CTD=dens2017_CTD(:,2:end);
oxy2017_CTD=ncread(filenames(2).name,'OXYK'); oxy2017_CTD=oxy2017_CTD(:,2:end);

ridge_2015=[68:84 89:102 110:133];
north_2015=46:67;
ovide_2015=26:45;
south_2015=[3:10 15 16 21:25];

ridge_2017=[56:69 76:125];
south_2017=[1:8 11:17];
ovide_2017=[18:20 22:24 27:28 43:-1:41 38:-1:31];
north_2017=[44:55 57];

heat2015=4000*temp2015_CTD.*(dens2015_CTD+1000);
heat2017=4000*temp2017_CTD.*(dens2017_CTD+1000);

%% First lets define the transect and load the transport

transect={'ridge','south','ovide','north'};
transects2015={ridge_2015, south_2015, ovide_2015, north_2015};
transects2017={ridge_2017, south_2017, ovide_2017, north_2017};
clear ridge_2015 ridge_2017 south_2015 south_2017 ovide_2015 ovide_2017 north_2015 north_2017

section=transect{1};
section2015=transects2015{1}; section2017=transects2017{1};

load([path 'RREX_T_tot_' section '.mat'])

%% We select the scpecific transect

lat2015=lat2015_CTD(section2015); lon2015=lon2015_CTD(section2015); 
dens2015=dens2015_CTD(:,section2015); sal2015=sal2015_CTD(:,section2015); 
temp2015=temp2015_CTD(:,section2015); oxy2015=oxy2015_CTD(:,section2015); 
pres2015=pres2015_CTD(:,section2015); 


%%


heat2015_m=mean(heat2015(:,section2015),1,'omitmissing')';
sal2015_m=mean(sal2015_CTD(:,section2015),1,'omitmissing')';

lat2017=lat2017_CTD(section2017); lon2017=lon2017_CTD(section2017); 
heat2017_m=mean(heat2017(:,section2017),1,'omitmissing')';
sal2017_m=mean(sal2017_CTD(:,section2017),1,'omitmissing')';

T_heat2015=(10^-9)*T_sum2015.*heat2015_m;
T_sal2015=T_sum2015.*sal2015_m;

T_heat2017=(10^-9)*T_sum2017.*heat2017_m;
T_sal2017=T_sum2017.*sal2017_m;

%% Plots

points=[40,55,1,1]; % This is for highlighting points used for sumating transport along ridge
aux1=X_sum2015(points); aux2=T_heat2015(points);
start2015=find(T_sum2015==0); start2015=X_sum2015(start2015);

% 2015
cruise='RREX2015 ';

figure()
set(gcf, 'Position', [185, 0, 1000, 800]);
ax1=subplot(2,1,1);
hold on
p1=plot(X_sum2015,T_heat2015,'-b','LineWidth',1.5,'DisplayName',cruise);


% 2017
cruise='RREX2017 '; % From which cruise

points=[49, 62];
aux1(3:4)=X_sum2017(points); aux2(3:4)=T_heat2017(points);

plot(X_sum2017,T_heat2017,'-r','LineWidth',1.5,'DisplayName',cruise);
ylabel('Heat Transport (PW)');
xlim(xlims); %ylim([-45 40])
title([figtitle ' Heat & Salt Transport'],'FontName','LMRoman10','FontSize',15,'FontWeight','bold')
L=legend('show');
L.AutoUpdate = 'off';

xline(X_sum2017(1),'--'); xline(58.9,'--') ; xline(56.7,'--')
plot(aux1,aux2,'+','Color','k','MarkerSize',10,'Linewidth',1)
plot(start2015,0,'ob','MarkerFaceColor','k','MarkerSize',4)
xticklabels({}); grid on
hold off

ax2=subplot(2,1,2);
points=[40,55,1,1]; aux2=T_sal2015(points);
points=[49, 62]; aux2(3:4)=T_sal2017(points);

hold on
p1=plot(X_sum2015,T_sal2015,'-b','LineWidth',1.5,'DisplayName',cruise);
plot(X_sum2017,T_sal2017,'-r','LineWidth',1.5,'DisplayName',cruise);

xline(X_sum2017(1),'--'); xline(58.9,'--') ; xline(56.7,'--')
plot(aux1,aux2,'+','Color','k','MarkerSize',10,'Linewidth',1)
plot(start2015,0,'ob','MarkerFaceColor','k','MarkerSize',4)
grid on

ylabel('Salt Transport (PSU*SV)');
xlim(xlims); %ylim([-45 40])


hold off
