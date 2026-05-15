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

% It is important to have access to:
% 1) Transport between stations
% 2) Ekman Transport
% 3) Original CTD data (for determining density layers)

%% First lets define the transect and the layers

transect={'ride','south','ovide','north'};

layers={'layer1', 'layer2', 'layer3', 'layer4'};

q=4; % north

%% Defines the stations for each transect

ride_2015=[68:84 89:102 110:133];
north_2015=46:67;
ovide_2015=26:45;
south_2015=[3:10 15 16 21:25];

ride_2017=[56:69 76:125];
south_2017=[1:8 11:17];
ovide_2017=[18:20 22:24 27:28 43:-1:41 38:-1:31];
north_2017=[44:55 57];

transects2015={ride_2015, south_2015, ovide_2015, north_2015};
transects2017={ride_2017, south_2017, ovide_2017, north_2017};


%% Loads and Defines density ranges

folder='C:/Users/mitg1n25/Desktop/PhD/PhD_Coding/data/RREX/Hydrography';
filenames = dir(fullfile(folder,'*CTDO.nc')); % Check the variable position

dens2015=ncread(filenames(1).name,'SIG0'); % Density anomaly referred to p=0
dens2017=ncread(filenames(2).name,'SIG0'); dens2017=dens2017(:,2:end);

pres2015=ncread(filenames(1).name,'PRES'); % Pressure
pres2017=ncread(filenames(2).name,'PRES'); pres2017=pres2017(:,2:end);

lat2015=ncread(filenames(1).name,'LATITUDE');
lon2015=ncread(filenames(1).name,'LONGITUDE');

lat2017=ncread(filenames(2).name,'LATITUDE'); lat2017=lat2017(2:end);
lon2017=ncread(filenames(2).name,'LONGITUDE'); lon2017=lon2017(2:end);

%% Loads and aranged the Bathymetry for both cruises

section=transect{q};

% 2017
[bathy_ship,X_bathy,Y_bathy]=bathy_bateau_17(section);
bathy_ship = bathy_ship.*1e-3;

if strcmp(section,'south')||strcmp(section,'ride')||strcmp(section,'ovide')
    if strcmp(section,'south')||strcmp(section,'ovide')
        ind_bad=find(bathy_ship(2:end-1)<1);
    elseif strcmp(section,'ride')
        ind_bad=find(bathy_ship(2:end-1)<0.1);
    end  
 
    for i=1:length(ind_bad)
        j=length(ind_bad)+1-i;
        bathy_ship(ind_bad(j)+1)=[];
        X_bathy(ind_bad(j)+1)=[];
        Y_bathy(ind_bad(j)+1)=[];
    end    

    if strcmp(section,'south')||strcmp(section,'ovide')
        ind_bad=find(3.2<bathy_ship(2:end-3));
    elseif strcmp(section,'ride')
        ind_bad=find(4.5<bathy_ship(2:end-3));
    end   

    for i=1:length(ind_bad)
        j=length(ind_bad)+1-i;
        bathy_ship(ind_bad(j)+1)=[];
        X_bathy(ind_bad(j)+1)=[];
        Y_bathy(ind_bad(j)+1)=[];
    end
end

bathy_ship2017=bathy_ship;
X_bathy2017=X_bathy;
Y_bathy2017=Y_bathy;
clear Y_bathy X_bathy bathy_ship ind_bad 

% 2015
[bathy_ship,X_bathy,Y_bathy]=bathy_bateau(section);
bathy_ship = bathy_ship.*1e-3;

if strcmp(section,'south')||strcmp(section,'ride')||strcmp(section,'ovide')
    if strcmp(section,'south')||strcmp(section,'ovide')
        ind_bad=find(bathy_ship(2:end-1)<1);
    elseif strcmp(section,'ride')
        ind_bad=find(bathy_ship(2:end-1)<0.1);
    end  
 
    for i=1:length(ind_bad)
        j=length(ind_bad)+1-i;
        bathy_ship(ind_bad(j)+1)=[];
        X_bathy(ind_bad(j)+1)=[];
        Y_bathy(ind_bad(j)+1)=[];
    end    

    if strcmp(section,'south')||strcmp(section,'ovide')
        ind_bad=find(3.2<bathy_ship(2:end-3));
    elseif strcmp(section,'ride')
        ind_bad=find(4.5<bathy_ship(2:end-3));
    end   

    for i=1:length(ind_bad)
        j=length(ind_bad)+1-i;
        bathy_ship(ind_bad(j)+1)=[];
        X_bathy(ind_bad(j)+1)=[];
        Y_bathy(ind_bad(j)+1)=[];
    end
end

bathy_ship2015=bathy_ship;
X_bathy2015=X_bathy;
Y_bathy2015=Y_bathy;
clear Y_bathy X_bathy bathy_ship ind_bad 

%% Calculate the transports by layers

T_mag2015=NaN(4,2); T_mag2017=NaN(4,1);
for qq=1:4 % Counter for layers
        [~, T_sum2017, ~, ~, T_mag2015(qq,:), T_mag2017(qq,:)] = RREX_ComputesTransport(transect{q},layers{qq});
end

sum(T_mag2017,1)

%% Plots the density with bathymetry (both cruises)

xlims=[48 64; -39 -30.5;-38 -27 ;-35 -20.5];
xlimm=xlims(q,:); xlab='Longitude (°W)';
surfaces=[27.52, 27.71, 27.8];

sta2015=transects2015{q}; sta2017=transects2017{q};

figure()
set(gcf, 'Position', [185, 0, 1000, 900]); % original x width 1200
% 2015
    depth=gsw_z_from_p(pres2015,lat2015);
    p=-depth(:,sta2015)/1000;
    dens=dens2015(:,sta2015);
    X=repmat(lon2015(sta2015)',4449,1);
hold on
contour(X,p,dens,surfaces,'b')
% 2017
    depth=gsw_z_from_p(pres2017,lat2017);
    p=-depth(:,sta2017)/1000;
    dens=dens2017(:,sta2017);
    X=repmat(lon2017(sta2017)',4340,1);
contour(X,p,dens,surfaces,'r')

qw{1} = plot(nan, '-b');
qw{2} = plot(nan, '-r');

L=legend([qw{:}],{'RREX2015','RREX2017'},'Location','southwest');
L.AutoUpdate = 'off';


fill(X_bathy2015,bathy_ship2015,[0.5 0.5 0.5]);
xlab='Longitude (°E)';
ylim([0 3])
set(gca,'ydir','reverse')
xline(-24.9,'--');
ylabel('Depth (km)')
xlim(xlimm); xlabel(xlab);
title('RREX - Transport by Layers in North Transect','FontName','LMRoman10','FontSize',15,'FontWeight','bold')
grid on

% Adds a label for each isopycnal
annotation('textbox',[.13 .88 .08 .03], 'String','\sigma_0 = 27.52 kg/m^3','EdgeColor','none','Color','k','FontSize',9.5,'FontWeight','bold')
annotation('textbox',[.145 .795 .08 .03], 'String','\sigma_0 = 27.71 kg/m^3','EdgeColor','none','Color','k','FontSize',9.5,'FontWeight','bold')
annotation('textbox',[.135 .44 .07 .04], 'String','\sigma_0 = 27.8 kg/m^3','EdgeColor','none','Color','k','FontSize',9.5,'FontWeight','bold')


% We add the transport calculated by sections
% Layer 1 2015
annotation('textbox',[.62 .725 .15 .2], 'String',[num2str(T_mag2015(1,1)) ' Sv'],'EdgeColor','none','Color','b','FontSize',11,'FontWeight','bold')
annotation('textbox',[.80 .66 .15 .2], 'String',[num2str(T_mag2015(1,2)) ' Sv'],'EdgeColor','none','Color','b','FontSize',11,'FontWeight','bold')
% Layer 1 2017
annotation('textbox',[.48 .66 .15 .2], 'String',[num2str(T_mag2017(1)) ' Sv'],'EdgeColor','none','Color','r','FontSize',11,'FontWeight','bold')

% Layer 2 2015
annotation('textbox',[.425 .60 .15 .2], 'String',[num2str(T_mag2015(2,1)) ' Sv'],'EdgeColor','none','Color','b','FontSize',11,'FontWeight','bold')
annotation('textbox',[.80 .49 .15 .2], 'String',[num2str(T_mag2015(2,2)) ' Sv'],'EdgeColor','none','Color','b','FontSize',11,'FontWeight','bold')
% Layer 2 2017
annotation('textbox',[.51 .505 .15 .2], 'String',[num2str(T_mag2017(2)) ' Sv'],'EdgeColor','none','Color','r','FontSize',11,'FontWeight','bold')

% Layer 3 2015
annotation('textbox',[.31 .28 .15 .2], 'String',[num2str(T_mag2015(3,1)) ' Sv'],'EdgeColor','none','Color','b','FontSize',11,'FontWeight','bold')
annotation('textbox',[.75 .40 .15 .2], 'String',[num2str(T_mag2015(3,2)) ' Sv'],'EdgeColor','none','Color','b','FontSize',11,'FontWeight','bold')
% Layer 3 2017
annotation('textbox',[.445 .295 .15 .2], 'String',[num2str(T_mag2017(3)) ' Sv'],'EdgeColor','none','Color','r','FontSize',11,'FontWeight','bold')

% Layer 4 2015
annotation('textbox',[.28 .245 .06 .03], 'String',[num2str(T_mag2015(4,1)) ' Sv'],'EdgeColor','none','Color','b','FontSize',11,'FontWeight','bold')
annotation('textbox',[.77 .44 .06 .03], 'String',[num2str(T_mag2015(4,2)) ' Sv'],'EdgeColor','none','Color','b','FontSize',11,'FontWeight','bold')
% Layer 4 2017
annotation('textbox',[.345 .36 .06 .03], 'String',[num2str(T_mag2017(4)) ' Sv'],'EdgeColor','none','Color','r','FontSize',11,'FontWeight','bold')


hold off
box on

figpath='C:\Users\mitg1n25\Desktop\PhD\PhD_Coding\docs\figures\Velocity_RREX';
imgname={'13a.T_layer_north2015.png','13b.T_layer_north2017.png','13c.T_layer_north.png'};
figname=fullfile(figpath, imgname{3});

% set(gca, 'LooseInset', get(gca, 'TightInset'));
print(gcf,figname, '-dpng', '-r0', '-loose')