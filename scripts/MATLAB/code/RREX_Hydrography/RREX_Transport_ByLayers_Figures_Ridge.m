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

q=1; % ridge

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

T_mag2015=NaN(4,4); T_mag2017=NaN(4,4);
for qq=1:4 % Counter for layers
        [~, ~, ~, ~, T_mag2015(qq,:), T_mag2017(qq,:)] = RREX_ComputesTransport(transect{q},layers{qq});
end

sum(T_mag2015,1)

%% Plots the density with bathymetry

xlims=[48 64; -38.1 -31.3;-37.3 -27.3 ;-34.5 -20];
xlimm=xlims(q,:); xlab='Latitude (°N)';
surfaces=[27.52, 27.71, 27.8];

sta2015=transects2015{q}; sta2017=transects2017{q};

figure()
set(gcf, 'Position', [185, 0, 1200, 950]);

% 2015
depth=gsw_z_from_p(pres2015,lat2015);
p=-depth(:,sta2015)/1000;
dens=dens2015(:,sta2015);
X=repmat(lat2015(sta2015)',4449,1);

hold on
contour(X,p,dens,surfaces,'k')

fill([65 64 X_bathy2017],[0 0 bathy_ship2017],[0.5 0.5 0.5]);
xline(63.417,'--'); xline(58.9,'--') ; xline(56.7,'--') ; xline(53.35,'--') ; xline(50.15,'--');
ylim([0 4.5])
set(gca,'ydir','reverse')
ylabel('Depth (km)')
xlim(xlimm); xlabel(xlab);
title('RREX 2015 - Transport by Layers in Ridge Section','FontName','LMRoman10','FontSize',15,'FontWeight','bold')
grid on

% Adds a label for each isopycnal
annotation('textbox',[.15 .79 .08 .03], 'String','\sigma_0 = 27.52 kg/m^3','EdgeColor','none','Color','k','FontSize',10,'FontWeight','bold')
annotation('textbox',[.15 .70 .08 .03], 'String','\sigma_0 = 27.71 kg/m^3','EdgeColor','none','Color','k','FontSize',10,'FontWeight','bold')
annotation('textbox',[.15 .50 .08 .03], 'String','\sigma_0 = 27.8 kg/m^3','EdgeColor','none','Color','k','FontSize',10,'FontWeight','bold')


% We add the transport calculated by sections
% Layer 1
annotation('textbox',[.25 .71 .15 .2], 'String',[num2str(T_mag2015(1,1)) ' Sv'],'EdgeColor','none','Color','r','FontSize',11,'FontWeight','bold')
annotation('textbox',[.44 .73 .15 .2], 'String',[num2str(T_mag2015(1,2)) ' Sv'],'EdgeColor','none','Color','r','FontSize',11,'FontWeight','bold')
annotation('textbox',[.56 .73 .15 .2], 'String',[num2str(T_mag2015(1,3)) ' Sv'],'EdgeColor','none','Color','k','FontSize',11,'FontWeight','bold')
annotation('textbox',[.73 .73 .15 .2], 'String',[num2str(T_mag2015(1,4)) ' Sv'],'EdgeColor','none','Color','b','FontSize',11,'FontWeight','bold')

% Layer 2
annotation('textbox',[.28 .635 .15 .2], 'String',[num2str(T_mag2015(2,1)) ' Sv'],'EdgeColor','none','Color','r','FontSize',11,'FontWeight','bold')
annotation('textbox',[.44 .67 .15 .2], 'String',[num2str(T_mag2015(2,2)) ' Sv'],'EdgeColor','none','Color','b','FontSize',11,'FontWeight','bold')
annotation('textbox',[.57 .67 .15 .2], 'String',[num2str(T_mag2015(2,3)) ' Sv'],'EdgeColor','none','Color','b','FontSize',11,'FontWeight','bold')
annotation('textbox',[.73 .66 .15 .2], 'String',[num2str(T_mag2015(2,4)) ' Sv'],'EdgeColor','none','Color','b','FontSize',11,'FontWeight','bold')

% Layer 3
annotation('textbox',[.30 .51 .15 .2], 'String',[num2str(T_mag2015(3,1)) ' Sv'],'EdgeColor','none','Color','r','FontSize',11,'FontWeight','bold')
annotation('textbox',[.48 .54 .15 .2], 'String',[num2str(T_mag2015(3,2)) ' Sv'],'EdgeColor','none','Color','b','FontSize',11,'FontWeight','bold')
annotation('textbox',[.61 .55 .15 .2], 'String',[num2str(T_mag2015(3,3)) ' Sv'],'EdgeColor','none','Color','b','FontSize',11,'FontWeight','bold')
annotation('textbox',[.655 .58 .15 .2], 'String',[num2str(T_mag2015(3,4)) ' Sv'],'EdgeColor','none','Color','b','FontSize',11,'FontWeight','bold')

% Layer 4
annotation('textbox',[.29 .30 .15 .2], 'String',[num2str(T_mag2015(4,1)) ' Sv'],'EdgeColor','none','Color','r','FontSize',11,'FontWeight','bold')
annotation('textbox',[.44 .56 .06 .03], 'String',[num2str(T_mag2015(4,2)) ' Sv'],'EdgeColor','b','Color','b','FontSize',11,'FontWeight','bold','BackgroundColor','w','HorizontalAlignment','center','VerticalAlignment','middle')
annotation('textbox',[.56 .58 .06 .03], 'String',[num2str(T_mag2015(4,3)) ' Sv'],'EdgeColor','b','Color','b','FontSize',11,'FontWeight','bold','BackgroundColor','w','HorizontalAlignment','center','VerticalAlignment','middle')

hold off

figpath='C:\Users\mitg1n25\Desktop\PhD\PhD_Coding\docs\figures\Velocity_RREX';
imgname={'10a.T_layer_ridge2015.png','10b.T_layer_ridge2017.png','10c.T_layer_ridge.png'};
figname=fullfile(figpath, imgname{1});

%set(gca, 'LooseInset', get(gca, 'TightInset'));
%print(gcf,figname, '-dpng', '-r0', '-loose')

%% 2017

depth=gsw_z_from_p(pres2017,lat2017);
p=-depth(:,sta2017)/1000;
dens=dens2017(:,sta2017);
X=repmat(lat2017(sta2017)',4340,1);

figure()
set(gcf, 'Position', [185, 0, 1200, 950]);
hold on
contour(X,p,dens,surfaces,'k')

fill([65 64 X_bathy2017],[0 0 bathy_ship2017],[0.5 0.5 0.5]);
xline(63.417,'--'); xline(58.9,'--') ; xline(56.7,'--'); xline(52.7,'--') ; xline(49.15,'--');
ylim([0 4.5])
set(gca,'ydir','reverse')
ylabel('Depth (km)')
xlim(xlimm); xlabel(xlab);
title('RREX 2017 - Transport by Layers in Ridge Section','FontName','LMRoman10','FontSize',15,'FontWeight','bold')
grid on

% Adds a label for each isopycnal
annotation('textbox',[.124 .784 .08 .03], 'String','\sigma_0 = 27.52 kg/m^3','EdgeColor','none','Color','k','FontSize',9.5,'FontWeight','bold')
annotation('textbox',[.125 .705 .08 .03], 'String','\sigma_0 = 27.71 kg/m^3','EdgeColor','none','Color','k','FontSize',9.5,'FontWeight','bold')
annotation('textbox',[.132 .47 .07 .04], 'String','\sigma_0 = 27.8 kg/m^3','EdgeColor','none','Color','k','FontSize',9.5,'FontWeight','bold','BackgroundColor','w','HorizontalAlignment','left','VerticalAlignment','middle')

% We add the transport calculated by sections
% Layer 1
annotation('textbox',[.25 .70 .15 .2], 'String',[num2str(T_mag2017(1,1)) ' Sv'],'EdgeColor','none','Color','r','FontSize',11,'FontWeight','bold')
annotation('textbox',[.44 .72 .15 .2], 'String',[num2str(T_mag2017(1,2)) ' Sv'],'EdgeColor','none','Color','b','FontSize',11,'FontWeight','bold')
annotation('textbox',[.58 .71 .15 .2], 'String',[num2str(T_mag2017(1,3)) ' Sv'],'EdgeColor','none','Color','b','FontSize',11,'FontWeight','bold')
annotation('textbox',[.735 .695 .15 .2], 'String',[num2str(T_mag2017(1,4)) ' Sv'],'EdgeColor','none','Color','b','FontSize',11,'FontWeight','bold')

% Layer 2
annotation('textbox',[.25 .62 .15 .2], 'String',[num2str(T_mag2017(2,1)) ' Sv'],'EdgeColor','none','Color','r','FontSize',11,'FontWeight','bold')
annotation('textbox',[.43 .66 .15 .2], 'String',[num2str(T_mag2017(2,2)) ' Sv'],'EdgeColor','none','Color','b','FontSize',11,'FontWeight','bold')
annotation('textbox',[.58 .62 .15 .2], 'String',[num2str(T_mag2017(2,3)) ' Sv'],'EdgeColor','none','Color','b','FontSize',11,'FontWeight','bold')
annotation('textbox',[.66 .61 .15 .2], 'String',[num2str(T_mag2017(2,4)) ' Sv'],'EdgeColor','none','Color','b','FontSize',11,'FontWeight','bold')

% Layer 3
annotation('textbox',[.25 .50 .15 .2], 'String',[num2str(T_mag2017(3,1)) ' Sv'],'EdgeColor','none','Color','r','FontSize',11,'FontWeight','bold')
annotation('textbox',[.40 .57 .15 .2], 'String',[num2str(T_mag2017(3,2)) ' Sv'],'EdgeColor','none','Color','b','FontSize',11,'FontWeight','bold')
annotation('textbox',[.605 .55 .15 .2], 'String',[num2str(T_mag2017(3,3)) ' Sv'],'EdgeColor','none','Color','b','FontSize',11,'FontWeight','bold')
annotation('textbox',[.653 .565 .15 .2], 'String',[num2str(T_mag2017(3,4)) ' Sv'],'EdgeColor','none','Color','b','FontSize',11,'FontWeight','bold')

% Layer 4
annotation('textbox',[.25 .25 .15 .2], 'String',[num2str(T_mag2017(4,1)) ' Sv'],'EdgeColor','none','Color','r','FontSize',11,'FontWeight','bold')
annotation('textbox',[.42 .56 .06 .03], 'String',[num2str(T_mag2017(4,2)) ' Sv'],'EdgeColor','b','Color','b','FontSize',11,'FontWeight','bold','BackgroundColor','w','HorizontalAlignment','center','VerticalAlignment','middle')
annotation('textbox',[.56 .58 .06 .03], 'String',[num2str(T_mag2017(4,3)) ' Sv'],'EdgeColor','b','Color','b','FontSize',11,'FontWeight','bold','BackgroundColor','w','HorizontalAlignment','center','VerticalAlignment','middle')

hold off

figname=fullfile(figpath, imgname{2});

%set(gca, 'LooseInset', get(gca, 'TightInset'));
% print(gcf,figname, '-dpng', '-r0', '-loose')

%% We plot again, but adding both cruises to the same figure

% color=[0.5 0 0.8];
% 
% figure()
% set(gcf, 'Position', [185, 0, 1200, 950]);
% % 2015
%     depth=gsw_z_from_p(pres2015,lat2015);
%     p=-depth(:,sta2015)/1000;
%     dens=dens2015(:,sta2015);
%     X=repmat(lat2015(sta2015)',4449,1);
% hold on
% contour(X,p,dens,surfaces,'b')
% % 2017
%     depth=gsw_z_from_p(pres2017,lat2017);
%     p=-depth(:,sta2017)/1000;
%     dens=dens2017(:,sta2017);
%     X=repmat(lat2017(sta2017)',4340,1);
% contour(X,p,dens,surfaces,'--r')
% 
% 
% fill([65 64 X_bathy2017],[0 0 bathy_ship2017],[0.5 0.5 0.5]);
% xline(63.417,'--'); xline(58.9,'--') ; xline(56.7,'--') ; xline(53.35,'--') ; xline(49.15,'--');
% ylim([0 4.5])
% set(gca,'ydir','reverse')
% ylabel('Depth (km)')
% xlim(xlimm); xlabel(xlab);
% title('RREX - Transport by Layers in Ridge Section','FontName','LMRoman10','FontSize',15,'FontWeight','bold')
% grid on
% 
% 
% % We add the transport calculated by sections
% % Layer 1 2015
% annotation('textbox',[.23 .72 .15 .2], 'String',[num2str(T_mag2015(1,1)) ' Sv'],'EdgeColor','none','Color','b','FontSize',11,'FontWeight','bold')
% annotation('textbox',[.44 .73 .15 .2], 'String',[num2str(T_mag2015(1,2)) ' Sv'],'EdgeColor','none','Color','b','FontSize',11,'FontWeight','bold')
% annotation('textbox',[.56 .73 .15 .2], 'String',[num2str(T_mag2015(1,3)) ' Sv'],'EdgeColor','none','Color','b','FontSize',11,'FontWeight','bold')
% annotation('textbox',[.73 .73 .15 .2], 'String',[num2str(T_mag2015(1,4)) ' Sv'],'EdgeColor','none','Color','b','FontSize',11,'FontWeight','bold')
% % Layer 1 2017
% annotation('textbox',[.21 .69 .15 .2], 'String',[num2str(T_mag2017(1,1)) ' Sv'],'EdgeColor','none','Color','r','FontSize',11,'FontWeight','bold')
% annotation('textbox',[.48 .705 .15 .2], 'String',[num2str(T_mag2017(1,2)) ' Sv'],'EdgeColor','none','Color','r','FontSize',11,'FontWeight','bold')
% annotation('textbox',[.58 .70 .15 .2], 'String',[num2str(T_mag2017(1,3)) ' Sv'],'EdgeColor','none','Color','r','FontSize',11,'FontWeight','bold')
% annotation('textbox',[.735 .695 .15 .2], 'String',[num2str(T_mag2017(1,4)) ' Sv'],'EdgeColor','none','Color','r','FontSize',11,'FontWeight','bold')
% 
% % Layer 2 2015
% annotation('textbox',[.33 .67 .15 .2], 'String',[num2str(T_mag2015(2,1)) ' Sv'],'EdgeColor','none','Color','b','FontSize',11,'FontWeight','bold')
% annotation('textbox',[.45 .66 .15 .2], 'String',[num2str(T_mag2015(2,2)) ' Sv'],'EdgeColor','none','Color','b','FontSize',11,'FontWeight','bold')
% annotation('textbox',[.585 .605 .15 .2], 'String',[num2str(T_mag2015(2,3)) ' Sv'],'EdgeColor','none','Color','b','FontSize',11,'FontWeight','bold')
% annotation('textbox',[.68 .66 .15 .2], 'String',[num2str(T_mag2015(2,4)) ' Sv'],'EdgeColor','none','Color','b','FontSize',11,'FontWeight','bold')
% % Layer 2 2017
% annotation('textbox',[.24 .615 .15 .2], 'String',[num2str(T_mag2017(2,1)) ' Sv'],'EdgeColor','none','Color','r','FontSize',11,'FontWeight','bold')
% annotation('textbox',[.41 .665 .15 .2], 'String',[num2str(T_mag2017(2,2)) ' Sv'],'EdgeColor','none','Color','r','FontSize',11,'FontWeight','bold')
% annotation('textbox',[.55 .63 .15 .2], 'String',[num2str(T_mag2017(2,3)) ' Sv'],'EdgeColor','none','Color','r','FontSize',11,'FontWeight','bold')
% annotation('textbox',[.66 .61 .15 .2], 'String',[num2str(T_mag2017(2,4)) ' Sv'],'EdgeColor','none','Color','r','FontSize',11,'FontWeight','bold')
% 
% % Layer 3 2015
% annotation('textbox',[.31 .54 .15 .2], 'String',[num2str(T_mag2015(3,1)) ' Sv'],'EdgeColor','none','Color','b','FontSize',11,'FontWeight','bold')
% annotation('textbox',[.49 .54 .15 .2], 'String',[num2str(T_mag2015(3,2)) ' Sv'],'EdgeColor','none','Color','b','FontSize',11,'FontWeight','bold')
% annotation('textbox',[.61 .55 .15 .2], 'String',[num2str(T_mag2015(3,3)) ' Sv'],'EdgeColor','none','Color','b','FontSize',11,'FontWeight','bold')
% annotation('textbox',[.655 .565 .15 .2], 'String',[num2str(T_mag2015(3,4)) ' Sv'],'EdgeColor','none','Color','b','FontSize',11,'FontWeight','bold')
% % Layer 3 2017
% annotation('textbox',[.24 .48 .15 .2], 'String',[num2str(T_mag2017(3,1)) ' Sv'],'EdgeColor','none','Color','r','FontSize',11,'FontWeight','bold')
% annotation('textbox',[.395 .57 .15 .2], 'String',[num2str(T_mag2017(3,2)) ' Sv'],'EdgeColor','none','Color','r','FontSize',11,'FontWeight','bold')
% annotation('textbox',[.59 .68 .06 .03], 'String',[num2str(T_mag2017(3,3)) ' Sv'],'EdgeColor','r','Color','r','FontSize',11,'FontWeight','bold','BackgroundColor','w','HorizontalAlignment','center','VerticalAlignment','middle')
% annotation('textbox',[.665 .69 .06 .03], 'String',[num2str(T_mag2017(3,4)) ' Sv'],'EdgeColor','r','Color','r','FontSize',11,'FontWeight','bold','BackgroundColor','w','HorizontalAlignment','center','VerticalAlignment','middle')
% 
% % Layer 4 2015
% annotation('textbox',[.29 .30 .15 .2], 'String',[num2str(T_mag2015(4,1)) ' Sv'],'EdgeColor','none','Color','b','FontSize',11,'FontWeight','bold')
% annotation('textbox',[.44 .56 .06 .03], 'String',[num2str(T_mag2015(4,2)) ' Sv'],'EdgeColor','b','Color','b','FontSize',11,'FontWeight','bold','BackgroundColor','w','HorizontalAlignment','center','VerticalAlignment','middle')
% annotation('textbox',[.56 .58 .06 .03], 'String',[num2str(T_mag2015(4,3)) ' Sv'],'EdgeColor','b','Color','b','FontSize',11,'FontWeight','bold','BackgroundColor','w','HorizontalAlignment','center','VerticalAlignment','middle')
% % Layer 4 2017
% annotation('textbox',[.24 .25 .15 .2], 'String',[num2str(T_mag2017(4,1)) ' Sv'],'EdgeColor','none','Color','r','FontSize',11,'FontWeight','bold')
% annotation('textbox',[.405 .51 .06 .03], 'String',[num2str(T_mag2017(4,2)) ' Sv'],'EdgeColor','r','Color','r','FontSize',11,'FontWeight','bold','BackgroundColor','w','HorizontalAlignment','center','VerticalAlignment','middle')
% annotation('textbox',[.56 .53 .06 .03], 'String',[num2str(T_mag2017(4,3)) ' Sv'],'EdgeColor','r','Color','r','FontSize',11,'FontWeight','bold','BackgroundColor','w','HorizontalAlignment','center','VerticalAlignment','middle')
% 
% hold off
% 
% figname=fullfile(figpath, imgname{3});
% 
% %set(gca, 'LooseInset', get(gca, 'TightInset'));
% % print(gcf,figname, '-dpng', '-r0', '-loose')