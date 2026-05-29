%% This script is used for plotting the water mass percentage calculated using
% Bieito's code in python

% We load paths and colorbars
addpath(genpath('C:/Users/mitg1n25/Desktop/PhD/PhD_coding'))
set(0, 'DefaultAxesFontSize', 12);
set(0, 'DefaultAxesTitleFontSizeMultiplier', 1.15)
set(0, 'DefaultAxesFontName', 'LMRoman17');
set(0, 'DefaultAxesFontWeight', 'bold');

%% First, we load the CTD variables 

folder='C:/Users/mitg1n25/Desktop/PhD/PhD_Coding/data/RREX/Hydrography';
filenames = dir(fullfile(folder,'*CTDO.nc')); % Check the variable position

% lat2015=ncread(filenames(1).name,'LATITUDE');
% lon2015=ncread(filenames(1).name,'LONGITUDE');
bottom2015=ncread(filenames(1).name,'BOTTOM_DEPTH');
% pres2015=ncread(filenames(1).name,'PRES'); % Pressure
% %temp2015=ncread(filenames(1).name,'TEMP'); % In situ temperature
% temp2015=ncread(filenames(1).name,'TPOT'); % Potential temperature
% sal2015=ncread(filenames(1).name,'PSAL'); % Practical Salinity
oxy2015=ncread(filenames(1).name,'OXYK'); % Oxygen concentration in umol/kg
% dens2015=ncread(filenames(1).name,'SIG0'); % Density anomaly referred to p=0
% n2015=length(lat2015);
% 
% lat2017=ncread(filenames(2).name,'LATITUDE'); 
% lon2017=ncread(filenames(2).name,'LONGITUDE');
bottom2017=ncread(filenames(2).name,'BOTTOM_DEPTH');
% pres2017=ncread(filenames(2).name,'PRES'); % Pressure
% %temp2017=ncread(filenames(2).name,'TEMP'); % In situ temperature
% temp2017=ncread(filenames(2).name,'TPOT'); % Potential temperature
% sal2017=ncread(filenames(2).name,'PSAL'); % Practical Salinity
oxy2017=ncread(filenames(2).name,'OXYK'); % Oxygen concentration in umol/kg
% dens2017=ncread(filenames(2).name,'SIG0'); % Density anomaly referred to p=0
% n2017=length(lat2017);

%% Separation of transects

ride_2015=[68:84 89:102 110:133];
north_2015=46:67;
ovide_2015=26:45;
south_2015=[3:10 15 16 21:25];

ride_2017=[56:69 76:125];
south_2017=[1:8 11:17];
ovide_2017=[18:20 22:24 27:28 43:-1:41 38:-1:31];
north_2017=[44:55 57];

titles = {'Ridge', 'South', 'OVIDE', 'North'};
transects2015={ride_2015, south_2015, ovide_2015, north_2015};
transects2017={ride_2017, south_2017, ovide_2017, north_2017};

%% Loads the water mass fractions and permutes the order

load RREX2015_Water_Mass_fractions_5poly.mat
X2015=permute(X2015,[2 1 3]);
pres2015=permute(pres2015,[2 1]);
M=size(X2015); M=M(3);

load RREX2017_Water_Mass_fractions_5poly.mat
X2017=permute(X2017,[2 1 3]); 
pres2017=permute(pres2017,[2 1]); 
lon2017 = lon2017(2:end);
X2017 = X2017(:,2:end,:);
pres2017 = pres2017(:,2:end);

%% Prepares variables for plotting

q=4; % q=[1, 2, 3, 4]

a=transects2015{q}; b=transects2017{q};
if q==1
    xdim2015=lat2015(a);
    xdim2017=lat2017(b);
    xdimlabel='Latitude';
else
    xdim2015=lon2015(a);
    xdim2017=lon2017(b);
    xdimlabel='Longitude';
end

xlims=[48.5 63.5; -38.1 -31.3;-37.3 -27.3 ;-34.1 -20.9];

figpath='C:\Users\mitg1n25\Desktop\PhD\PhD_Coding\docs\figures\WaterMasses_RREX';
imgname2015={'01.WaterMassPercentage_ridge2015.png','02.WaterMassPercentage_south2015.png','03.WaterMassPercentage_ovide2015.png','04.WaterMassPercentage_north2015.png'};
imgname2017={'01.WaterMassPercentage_ridge2017.png','02.WaterMassPercentage_south2017.png','03.WaterMassPercentage_ovide2017.png','04.WaterMassPercentage_north2017.png'};
imgnameboth={'01.WaterMassPercentage_ridge.png','02.WaterMassPercentage_south.png','03.WaterMassPercentage_ovide.png','04.WaterMassPercentage_north.png'};

%% 2015

% % This vector is for que location of the subplots
% sp=[1 2 3 4 5.5 6.5 7.5];
% ax={};
% fig=figure(); set(gcf, 'Position',  [100, 100, 1600, 800])
% for i=1:M
%     ax{i}=subplot(2,4,sp(i));
%     pcolor(xdim2015,pres2015(:,a),X2015(:,a,i)); shading flat
%     caxis([0 1]); colormap(ax{i},slanCM('viridis'));
%     set(gca,'YDir','reverse'); ylim([100 4500])
%     title(WT2015(i,:)); xlim(xlims(q,:));
%     % hold on; area(xdim2015,bottom2015(a),5000,'facecolor',[0.7 0.7 0.7],'edgecolor','k'); hold off 
%     box on
%     if i==1 || i==5
%         ylabel('Pressure [dbar]');
%     elseif i==4 || i==7
%         set(gca, 'YAxisLocation', 'right')
%         ylabel('Pressure [dbar]','Rotation',-90);
%     else
%         set(gca, 'YTickLabel','');
%     end
%     if i>4
%         xlabel(xdimlabel);
%     end
%     set(gca, 'TickDir', 'out');
% end
% sgtitle(['Water Masses RREX2015 - ' titles{q} ' Transect'])
% 
% shiftdown=0.06;
% shiftleft=[0.0 0.04 0.08 0.12];
% for i=1:4
%     pos = get(ax{i}, 'Position');
%     pos(2) = pos(2) - shiftdown; 
%     pos(1) = pos(1) - shiftleft(i); 
%     set(ax{i}, 'Position', pos);
%     L.Location = 'southeast';
% end
% 
% shiftleft=[0.02 0.06 0.1];
% for i=5:7
%     pos = get(ax{i}, 'Position');
%     pos(1) = pos(1) - shiftleft(i-4); 
%     set(ax{i}, 'Position', pos);
%     L.Location = 'southeast';
% end
% 
% % Adds colorbar
% h = axes(fig,'visible','off'); 
% c = colorbar(h,'Position',[0.75 0.11 0.015 0.34]); 
% colormap(c,slanCM('viridis'));
% 
% figpath='C:\Users\mitg1n25\Desktop\PhD\PhD_Coding\docs\figures\WaterMasses_RREX';
% imgname=imgname2015{q}; % Name of the image being stored
% figname=fullfile(figpath, imgname);
% 
% % Save the figure
% set(gca, 'LooseInset', get(gca, 'TightInset'));
% % print(gcf,figname, '-dpng', '-r0', '-loose')

%% 2017

% ax={};
% fig=figure(); set(gcf, 'Position',  [100, 100, 1600, 800])
% for i=1:M
%     ax{i}=subplot(2,4,sp(i));
%     pcolor(xdim2017,pres2017(:,b),X2017(:,b,i)); shading flat
%     caxis([0 1]); colormap(ax{i},slanCM('viridis'));
%     set(gca,'YDir','reverse'); ylim([100 4500])
%     title(WT2017(i,:)); xlim(xlims(q,:));
%     %hold on; area(xdim2017,bottom2017(b),5000,'facecolor',[0.7 0.7 0.7],'edgecolor','k'); hold off
%     if i==1 || i==5
%         ylabel('Pressure [dbar]');
%     elseif i==4 || i==7
%         set(gca, 'YAxisLocation', 'right')
%         ylabel('Pressure [dbar]','Rotation',-90);
%     else
%         set(gca, 'YTickLabel','');
%     end
%     if i>4
%         xlabel(xdimlabel);
%     end
%     set(gca, 'TickDir', 'out');
% end
% sgtitle(['Water Masses RREX2017 - ' titles{q} ' Transect'])
% 
% shiftdown=0.06;
% shiftleft=[0.0 0.04 0.08 0.12];
% for i=1:4
%     pos = get(ax{i}, 'Position');
%     pos(2) = pos(2) - shiftdown; 
%     pos(1) = pos(1) - shiftleft(i); 
%     set(ax{i}, 'Position', pos);
%     L.Location = 'southeast';
% end
% 
% shiftleft=[0.02 0.06 0.1];
% for i=5:7
%     pos = get(ax{i}, 'Position');
%     pos(1) = pos(1) - shiftleft(i-4); 
%     set(ax{i}, 'Position', pos);
%     L.Location = 'southeast';
% end
% 
% % Adds colorbar
% h = axes(fig,'visible','off'); 
% c = colorbar(h,'Position',[0.75 0.11 0.015 0.34]); 
% colormap(c,slanCM('viridis'));
% 
% 
% imgname=imgname2017{q}; % Name of the image being stored
% figname=fullfile(figpath, imgname);
% 
% % Save the figure
% set(gca, 'LooseInset', get(gca, 'TightInset'));
% % print(gcf,figname, '-dpng', '-r0', '-loose')

%% We do the same plot, but this time I consider NACW + SAIW

X2015_6=X2015; % Defines a new variable equal to the WMP
X2015_6(:,:,1)=X2015_6(:,:,1)+X2015_6(:,:,4); % Makes the 1st matrix be NACW + SAIW
X2015_6(:,:,4)=[]; % Deletes the 2nd matrix

% Repeats for 2017
X2017_6=X2017;
X2017_6(:,:,1)=X2017_6(:,:,1)+X2017_6(:,:,4);
X2017_6(:,:,4)=[];

% Titles for the figure
WT={'NACW+SAIW', 'SPMW', 'IW', 'LSW', 'ISOW', 'LDW'};

%% Figure of 2015-2017 comparison

scale=0.9;
fig=figure(); set(gcf, 'Position',  [100, 100, 1950, 800])
t=tiledlayout(2,6,"TileSpacing","compact","Padding","compact");
ax=cell(12,1);
for i=1:M-1
    ax{i}=nexttile(i);
        pcolor(xdim2015,pres2015(:,a),X2015_6(:,a,i)); shading flat
        caxis([0 1]); colormap(ax{i},slanCM('viridis'));
        set(gca,'YDir','reverse');  set(gca, 'TickDir', 'out');
        xlim(xlims(q,:)); title(WT{i}); 
        if q==1
            hold on; area(xdim2017,bottom2017(b),4480,'facecolor',[0.7 0.7 0.7],'edgecolor','k','EdgeAlpha',0.5); hold off;
            ylim([100 4500]); 
        else
            hold on; area(xdim2015,bottom2015(a),2980,'facecolor',[0.7 0.7 0.7],'edgecolor','k','EdgeAlpha',0.5); hold off;
            ylim([100 3000]);
        end
    ax{i+6}=nexttile(i+6);
        pcolor(xdim2017,pres2017(:,b),X2017_6(:,b,i)); shading flat
        caxis([0 1]); colormap(ax{i+6},slanCM('viridis'));
        set(gca,'YDir','reverse'); ylim([100 4500])
        title(WT{i}); xlim(xlims(q,:));
        set(gca, 'TickDir', 'out');
        if q==1
            hold on; area(xdim2017,bottom2017(b),4480,'facecolor',[0.7 0.7 0.7],'edgecolor','k','EdgeAlpha',0.5); hold off;
            ylim([100 4500]); 
        else
            hold on; area(xdim2015,bottom2015(a),2980,'facecolor',[0.7 0.7 0.7],'edgecolor','k','EdgeAlpha',0.5); hold off;
            ylim([100 3000]);
        end
     % Adds labels and changes ticks
     xlabel(ax{i+6},xdimlabel);
     if i==1
        ylabel(ax{i},'Pressure [dbar]');
        ylabel(ax{i+6},'Pressure [dbar]');
     end
end
h = axes(fig,'visible','off'); 
c = colorbar(h,'Position',[0.97 0.05 0.015 0.91]); 
colormap(c,slanCM('viridis'));


imgname=imgnameboth{q}; % Name of the image being stored
figname=fullfile(figpath, imgname);

% Save the figure
set(gca, 'LooseInset', get(gca, 'TightInset'));
print(gcf,figname, '-dpng', '-r0', '-loose')

%% Compares SPMW with IW for the 2015 period

if q==1

fig=figure(); set(gcf, 'Position',  [100, 0, 600, 1000])
t=tiledlayout('vertical',"TileSpacing","compact","Padding","compact");

hold on
ax1=nexttile;
    pcolor(xdim2015,pres2015(:,a),X2015_6(:,a,1)); shading flat
    caxis([0 1]); colormap(ax1, slanCM('viridis'));
    set(gca,'YDir','reverse');  set(gca, 'TickDir', 'out');
    ylim([100 1200]); xlim([50 63.5]); title(WT{1}); 
    hold on; area(xdim2015,bottom2015(a),4480,'facecolor',[0.7 0.7 0.7],'edgecolor','k','EdgeAlpha',0.5); hold off;
    xline(58.84,'--w'); xline(58.2,'--w'); xline(55.05,'--w'); xline(56.05,'--w');
ax1=nexttile;
    pcolor(xdim2015,pres2015(:,a),X2015_6(:,a,2)); shading flat
    caxis([0 1]); colormap(ax1, slanCM('viridis'));
    set(gca,'YDir','reverse');  set(gca, 'TickDir', 'out');
    ylim([100 1200]); xlim([50 63.5]); title(WT{2}); 
    hold on; area(xdim2015,bottom2015(a),4480,'facecolor',[0.7 0.7 0.7],'edgecolor','k','EdgeAlpha',0.5); hold off;
    xline(58.84,'--w'); xline(58.2,'--w'); xline(55.05,'--w'); xline(56.05,'--w');
ax2=nexttile;
    pcolor(xdim2015,pres2015(:,a),X2015_6(:,a,3)); shading flat
    caxis([0 1]); colormap(ax2, slanCM('viridis'));
    set(gca,'YDir','reverse');  set(gca, 'TickDir', 'out');
    ylim([100 1200]); xlim([50 63.5]); title(WT{3}); 
    hold on; area(xdim2015,bottom2015(a),4480,'facecolor',[0.7 0.7 0.7],'edgecolor','k','EdgeAlpha',0.5); hold off;
    xline(58.84,'--w'); xline(58.2,'--w'); xline(55.05,'--w'); xline(56.05,'--w');
ax3=nexttile;
    pcolor(xdim2015,pres2015(:,a),oxy2015(:,a)); shading flat
    caxis([240 300]); colormap(ax3, slanCM('jet'));
    set(gca,'YDir','reverse');  set(gca, 'TickDir', 'out');
    ylim([100 1200]); xlim([50 63.5]); title('DO \mumol/kg'); 
    hold on; area(xdim2015,bottom2015(a),4480,'facecolor',[0.7 0.7 0.7],'edgecolor','k','EdgeAlpha',0.5); hold off;
    xline(58.84,'--k'); xline(58.2,'--k'); xline(55.05,'--k'); xline(56.05,'--k');
hold off
% Colorbar 2
h1 = axes(fig,'visible','off'); 
c1 = colorbar(h1,'Position',[0.935 0.54 0.015 0.18]); 
clim([0 1]);
colormap(c1,slanCM('viridis'));

% Colorbar 2
h2 = axes(fig,'visible','off'); 
c2 = colorbar(h2,'Position',[0.935 0.1 0.015 0.18]); 
clim([220 300]);
colormap(c2,slanCM('jet'));

imgname='00.SPMW_IW_2015.png'; % Name of the image being stored
figname=fullfile(figpath, imgname);
% Save the figure
set(gca, 'LooseInset', get(gca, 'TightInset'));
% print(gcf,figname, '-dpng', '-r0', '-loose')

end

%% Computes Water Mass Transport

q=1; % ride
a=transects2015{q}; b=transects2017{q};
A=length(a); B=length(b);

transect={'ride','south','ovide','north'};
WaterMasses={'NACW', 'SPMW', 'IW', 'SAIW', 'LSW', 'ISOW', 'LDW'};
N=length(WaterMasses);

T2015=NaN(N,A); T2017=NaN(N,B);
T_ridge2015=NaN(N,4); T_ridge2017=NaN(N,4);
T_south2015=NaN(N,2); T_south2017=NaN(N,2);
T_ovide2015=NaN(N,2); T_ovide2017=NaN(N,2);
T_north2015=NaN(N,2); T_north2017=NaN(N,1);
for qq=1:N % Counter for layers
        [T2015(qq,:), T2017(qq,:), ~, ~, T_ridge2015(qq,:), T_ridge2017(qq,:)] = RREX_ComputesTransport_WaterMasses(transect{1},WaterMasses{qq},'total');
        % [~, ~, ~, ~, T_south2015(qq,:), T_south2017(qq,:)] = RREX_ComputesTransport_WaterMasses(transect{2},WaterMasses{qq},'mean');
        % [~, ~, ~, ~, T_ovide2015(qq,:), T_ovide2017(qq,:)] = RREX_ComputesTransport_WaterMasses(transect{3},WaterMasses{qq},'mean');
        % [~, ~, ~, ~, T_north2015(qq,:), T_north2017(qq,:)] = RREX_ComputesTransport_WaterMasses(transect{4},WaterMasses{qq},'mean');
end

sum(T_ridge2015,1)

%% Debug

% mm2015=NaN(N,4); mm2017=NaN(N,4);
% for qq=1:N % Counter for layers
%     [mm2015(qq,:), mm2017(qq,:)] = RREX_ComputesTransport_WaterMasses_Debug(transect{1},WaterMasses{qq},'meh');
% end

%% Convert magnitude matrix to a table in word format

% % Selects the year to copy
% T_ridgeT=[T_ridge2015; sum(T_ridge2015,1)];
% headers = {'2015', '50.1 - 53.3N', '53.3 - 56.7N', '56.7 - 58.9N', '58.9 - 63.4N'}; % 2015
% %T_ridgeT=[T_ridge2017; sum(T_ridge2017,1)];
% %headers = {'2017', '49.1 - 52.7N', '52.7 - 56.7N', '56.7 - 58.9N', '58.9 - 63.4N'}; % 2017
% 
% data_with_headers = [headers;[[WaterMasses,'Total']', num2cell(T_ridgeT)]];
% 
% % Creates table from matrix
% table = array2table(data_with_headers);
% 
% % Exports to excel
% writetable(table, 'T_ridge2015.xlsx');


