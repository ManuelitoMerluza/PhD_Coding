%% This script will be used to plot the figures of geostrophic velocity
%  and transport computed by Ivane's functions (Modified by Manuel Torres :3)

%% Loads paths, colormap and defines text properties and 

addpath(genpath('C:/Users/mitg1n25/Desktop/PhD/PhD_coding'))
set(0, 'DefaultAxesFontSize', 12);
set(0, 'DefaultAxesTitleFontSizeMultiplier', 1.15)
set(0, 'DefaultAxesFontName', 'LMRoman17');
set(0, 'DefaultAxesFontWeight', 'bold');
load vmap % loads colormap
vmap(29,:) = 0.97; % Changes the middle of the cbar so it can be less white

% Paths where Abosolute Velocity Data is stored
path2015='C:/Users/mitg1n25/Desktop/PhD/PhD_Coding/data/RREX/Ivane_output_RREX15/vitesse_abs/';
path2017='C:/Users/mitg1n25/Desktop/PhD/PhD_Coding/data/RREX/Ivane_output_RREX17/vitesse_abs/';


% It is important to have access to:
% 1) Absolute velocity (Vgeo corrected by SADCP data)
% 2) Bathymetry

%% Makes a loop for running this automatically for all transect

for q=1%:4

%% First lets define the transect and load the variables
transect={'ride','south','ovide','north'};
section=transect{q}; % Transect being plotted

cruise='RREX 2017 '; % From which cruise

if strcmp(section,'ride') % Defines x axis depending on the transect
    load([path2017 'OS38_section_' section '_use.mat'])
    xaxis=lat_abs;
    xlab='Latitude (°N)';
else
    load([path2017 'OS38_section_' section '_polyfit.mat'])
    xaxis=lon_abs;
    xlab='Longitude (°E)';
end

figtitle={'Reykjanes Ridge Transect','South Cross-Ridge Transect','OVIDE Transect','North West-Ridge Transect'};
figtitle=figtitle{q}; % Title for the figure

imgname={'01Vgeo_ridge.png','02.Vgeo_south.png','03.Vgeo_ovide.png','04.Vgeo_north.png'};
imgname=imgname{q}; % Name of the image being stored

xlims=[48.4 63.4; -38.1 -31.3;-37.3 -27.3 ;-34 -21];
xlims=xlims(q,:); % x axis limits for plotting each transect

%% Loads and aranged the Bathymetry for both cruises

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

%% Geostrophic velocity transect

% Path for saving the figure
figpath='C:\Users\mitg1n25\Desktop\PhD\PhD_Coding\docs\figures\Velocity_RREX';
figname=fullfile(figpath, imgname);

% 2017
figure()
ax3=subplot(5,1,[4 5]);
set(gcf, 'Position', [185, 0, 1000, 850]);
vcol=-0.2:0.02:0.2;
hold on
pcolor(xaxis,z_abs*1e-3,v_abs); shading interp;
contour(xaxis,z_abs*1e-3,v_abs,[0, 0],'Linecolor',[0.35 0.35 0.35],'LineWidth',1.8);
set(gca,'ydir','reverse')
xlabel(xlab); ylabel('Depth (km)');
colorbar; colormap(vmap);
limcol=[vcol(1) vcol(end)]; clim(limcol); xlim(xlims);
title(cruise)
if strcmp(section,'ride')
    fill(X_bathy2017(:),bathy_ship2017,[0.5 0.5 0.5]);
    ylim([0 4.5])
else
    fill(X_bathy2015(:),bathy_ship2015,[0.5 0.5 0.5]);
    ylim([0 3])
end

% 2015
cruise='RREX 2015 ';

if strcmp(section,'ride')
    load([path2015 'OS38_section_' section '_use.mat'])
    xaxis=lat_abs;
    xlab='Latitude (°N)';
else
    load([path2015 'OS38_section_' section '_polyfit.mat'])
    xaxis=lon_abs;
    xlab='Longitude (°E)';
end

ax2=subplot(5,1,[2 3]);
vcol=-0.2:0.02:0.2;
hold on
pcolor(xaxis,z_abs*1e-3,v_abs); shading interp;
contour(xaxis,z_abs*1e-3,v_abs,[0, 0],'Linecolor',[0.35 0.35 0.35],'LineWidth',1.8);
set(gca,'ydir','reverse')
ylabel('Depth (km)');
colorbar; colormap(vmap);
limcol=[vcol(1) vcol(end)]; clim(limcol); xlim(xlims);
title(cruise)
sgtitle([figtitle ' Geostrophic Velocity'],'FontName','LMRoman10','FontSize',15,'FontWeight','bold')
if strcmp(section,'ride')
    fill(X_bathy2017(:),bathy_ship2017,[0.5 0.5 0.5]);
    ylim([0 4.5])
else
    fill(X_bathy2015(:),bathy_ship2015,[0.5 0.5 0.5]);
    ylim([0 3])
end


%% Geostrophic transport

% Paths where Abosolute Velocity Data is stored
path2015='C:/Users/mitg1n25/Desktop/PhD/PhD_Coding/data/RREX/Ivane_output_RREX15/transport_geo/';
path2017='C:/Users/mitg1n25/Desktop/PhD/PhD_Coding/data/RREX/Ivane_output_RREX17/transport_geo/';

% Path for saving the figure
figpath='C:\Users\mitg1n25\Desktop\PhD\PhD_Coding\docs\figures\Velocity_RREX';
load('RREX_T_tot_ridge.mat'); % Loads the cumulated transports

% 2015
cruise='RREX2015 ';
load([path2015 'transport_RREX15_' section '_use.mat'])
T_sum=zeros(1,length(T_tot)+1); T_sum(2:end)=T_tot;
T_sum=cumsum(T_sum); % This is for centering the start of the transport at zero
X_sum=[X_ctd(1); X];
points=[1,40,55,1,1]; % This is for highlighting points used for sumating transport along ridge
aux1=X_sum(points); aux2=T_sum(points);

ax1=subplot(5,1,1);
hold on
p1=plot(X_sum,T_sum,'-b','LineWidth',1.5,'DisplayName',cruise);

% 2017
cruise='RREX2017 '; % From which cruise
load([path2017 'transport_RREX17_' section '_use.mat'])
T_sum=zeros(1,length(T_tot)+1); T_sum(2:end)=T_tot;
T_sum=cumsum(T_sum); % This is for centering the start of the transport at zero
X_sum=X;  %X_sum=[X_ctd(1); X]; this applies if its 'polyfit' instead of 'use'
points=[49, 62];
aux1(4:5)=X_sum(points); aux2(4:5)=T_sum(points);

p2=plot(X_sum,T_sum,'-r','LineWidth',1.5,'DisplayName',cruise);
ylabel('Transport (Sv)');
xlim(xlims); ylim([-45 35])
title([figtitle ' Total Transport'],'FontName','LMRoman10','FontSize',15,'FontWeight','bold')
L=legend('show');
L.AutoUpdate = 'off';
if strcmp(section,'ride')
    xline(X_ctd(1),'--'); xline(58.9,'--') ; xline(56.4,'--')
end
plot(aux1,aux2,'ok','MarkerFaceColor','k','MarkerSize',4)
xticklabels({}); grid on
hold off

%% This is for shifting the plots down and saving the figures

pos = get(ax3, 'Position');
set(ax3, 'Position', pos);

% For some reason the previous step also stretches the plot to the side
% I just set the position of the lower subplot so the same happens
pos = get(ax2, 'Position');
set(ax2, 'Position', pos);

set(gca, 'LooseInset', get(gca, 'TightInset'));
% print(gcf,figname, '-dpng', '-r0', '-loose')

end