%% This script will be used to plot the figures of geostrophic Transport
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
path2015='C:/Users/mitg1n25/Desktop/PhD/PhD_Coding/data/RREX/Ivane_output_RREX15/transport_geo/';
path2017='C:/Users/mitg1n25/Desktop/PhD/PhD_Coding/data/RREX/Ivane_output_RREX17/transport_geo/';

% It is important to have access to:
% 1) Transport between stations
% 2) Bathymetry
% 3) Ekman transport

%% Load the error variables

load([path2015 'RREX_T_tot_errors.mat']);

%% Defines the number for the ridge transect

q=1;

%% First lets define the transect and load the variables
transect={'ride','south','ovide','north'};
section=transect{q}; % Transect being plotted

figtitle={'Reykjanes Ridge Transect','South Cross-Ridge Transect','OVIDE Transect','North West-Ridge Transect'};
figtitle=figtitle{q}; % Title for the figure

imgname={'05Ttot_ridge.png','06.Ttot_south.png','07.Ttot_ovide.png','08.Ttot_north.png'};
imgname=imgname{q}; % Name of the image being stored

xlims=[48 64; -38.1 -31.3;-37.3 -27.3 ;-34 -21];
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

% 2015
cruise='RREX2015 ';
load('RREX_T_tot_ridge.mat'); % Loads the cumulated transports


points=[40,55,1,1]; % This is for highlighting points used for sumating transport along ridge
aux1=X_sum2015(points); aux2=T_sum2015(points);
start2015=find(T_sum2015==0); start2015=X_sum2015(start2015);

figure()
set(gcf, 'Position', [185, 0, 1000, 800]);
ax1=subplot(2,1,1);
hold on
p1=plot(X_sum2015,T_sum2015,'-b','LineWidth',1.5,'DisplayName',cruise);


% 2017
cruise='RREX2017 '; % From which cruise

points=[49, 62];
aux1(3:4)=X_sum2017(points); aux2(3:4)=T_sum2017(points);

plot(X_sum2017,T_sum2017,'-r','LineWidth',1.5,'DisplayName',cruise);
ylabel('Transport (Sv)');
xlim(xlims); ylim([-45 40])
title([figtitle ' Total Transport'],'FontName','LMRoman10','FontSize',15,'FontWeight','bold')
L=legend('show');
L.AutoUpdate = 'off';

xline(X_sum2017(1),'--'); xline(58.9,'--') ; xline(56.7,'--')
plot(aux1,aux2,'+','Color','k','MarkerSize',10,'Linewidth',1)
plot(start2015,0,'ob','MarkerFaceColor','k','MarkerSize',4)
xticklabels({}); grid on
hold off

subplot(2,1,2)

fill([65 64 X_bathy2017],[0 0 bathy_ship2017],[0.5 0.5 0.5]);
xline(X_sum2017(1),'--'); xline(58.9,'--') ; xline(56.7,'--')
xlab='Latitude (°N)';
ylim([0 4.5])
set(gca,'ydir','reverse')
ylabel('Depth (km)')
xlim(xlims); xlabel(xlab);
grid on

% This is for shifting the plots down
shiftdown=0.1;
pos = get(ax1, 'Position');
pos(2) = pos(2) - shiftdown; 
set(ax1, 'Position', pos);
L.Location = 'southeast';

% We add the transport calculated by sections
annotation('textbox',[.71 .62 .15 .2], 'String',[num2str(T_ride2015(4)) ' ± ' num2str(error_ride2015(4)) ' Sv'],'EdgeColor','none','Color','b','FontSize',10,'FontWeight','bold')
annotation('textbox',[.71 .595 .15 .2], 'String',[num2str(T_ride2017(4)) ' ± ' num2str(error_ride2017(4)) ' Sv'],'EdgeColor','none','Color','r','FontSize',10,'FontWeight','bold')

annotation('textbox',[.555 .62 .15 .2], 'String',[num2str(T_ride2015(3)) ' ± ' num2str(error_ride2015(3)) ' Sv'],'EdgeColor','none','Color','b','FontSize',10,'FontWeight','bold')
annotation('textbox',[.555 .595 .15 .2], 'String',[num2str(T_ride2017(3)) ' ± ' num2str(error_ride2017(3)) ' Sv'],'EdgeColor','none','Color','r','FontSize',10,'FontWeight','bold')

annotation('textbox',[.42 .62 .15 .2], 'String',[num2str(T_ride2015(2)) ' ± ' num2str(error_ride2015(2)) ' Sv'],'EdgeColor','none','Color','b','FontSize',10,'FontWeight','bold')
annotation('textbox',[.42 .595 .15 .2], 'String',[num2str(T_ride2017(2)) ' ± ' num2str(error_ride2017(2)) ' Sv'],'EdgeColor','none','Color','r','FontSize',10,'FontWeight','bold')

annotation('textbox',[.29 .62 .15 .2], 'String',[num2str(T_ride2015(1)) ' ± ' num2str(error_ride2015(1)) ' Sv'],'EdgeColor','none','Color','b','FontSize',10,'FontWeight','bold')
annotation('textbox',[.29 .595 .15 .2], 'String',[num2str(T_ride2017(1)) ' ± ' num2str(error_ride2017(1)) ' Sv'],'EdgeColor','none','Color','r','FontSize',10,'FontWeight','bold')

% Save the figure
set(gca, 'LooseInset', get(gca, 'TightInset'));
print(gcf,figname, '-dpng', '-r0', '-loose')
