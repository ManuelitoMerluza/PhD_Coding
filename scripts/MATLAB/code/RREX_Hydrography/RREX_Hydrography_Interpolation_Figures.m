% This script is for Plotting the Multiple Interpolated Profiles

% We load paths and colorbars
addpath(genpath('C:/Users/mitg1n25/Desktop/PhD/Year 1 - 2026'))
%addpath(genpath('D:/Respaldo PC/iop/materia/Magister/Semestre 2/PRODIGY/m_map/'))
set(0, 'DefaultAxesFontSize', 12);
set(0, 'DefaultAxesTitleFontSizeMultiplier', 1.15)
set(0, 'DefaultAxesFontName', 'LMRoman17');
set(0, 'DefaultAxesFontWeight', 'bold');
map = load('colormap_RREX.mat'); % colormap(map.cmap);
load REXXBathymetry.mat


%% First, we load the variables 

load('RREX_Transects_Interpolated.mat')

%% Define variables for plotting

meridional={'ridge','southridge'};
zonal={'trans1','trans2','westridge'};
all={'ridge','southridge','trans1','trans2','westridge'};
column_labels = {'\theta [°C]', 'Salinity [PSU]', '\sigma_0 [kg/m^3]', 'DO [\mumol/kg]'};


%% Meridional Transects

k=[1,5];

figure('Position', [74, -43, 1812, 600]);
axhandles = {};

for i=1:length(meridional)

    dx=dynamicvariable('dX_',meridional{i});
    dz=dynamicvariable('dZ_',meridional{i});
    bottom=dynamicvariable('Bottom_',meridional{i});
    dT=dynamicvariable('T2017in_',meridional{i})-dynamicvariable('T2015in_',meridional{i});
    dS=dynamicvariable('S2017in_',meridional{i})-dynamicvariable('S2015in_',meridional{i});
    dSigma=dynamicvariable('Sigma2017in_',meridional{i})-dynamicvariable('Sigma2015in_',meridional{i});
    dO=dynamicvariable('O2017in_',meridional{i})-dynamicvariable('O2015in_',meridional{i});

    ax1=subplot(2,4,k(i));
    pcolor(dx, dz, dT); shading flat; set(gca, 'YDir', 'reverse');
    clim(ax1,[-1.5 1.5]); colormap(ax1,slanCM('vik'));
    hold on; area(dx,bottom,5000,'facecolor',[0.6 0.6 0.6],'edgecolor','k'); hold off 
    axhandles{end+1}=ax1;
    
    ax2=subplot(2,4,k(i)+1);
    pcolor(dx, dz, dS); shading flat; set(gca, 'YDir', 'reverse');
    clim(ax2,[-0.2 0.2]); colormap(ax2,slanCM('delta'));
    hold on; area(dx,bottom,5000,'facecolor',[0.6 0.6 0.6],'edgecolor','k'); hold off 
    axhandles{end+1}=ax2;
    
    ax3=subplot(2,4,k(i)+2);
    pcolor(dx, dz, dSigma); shading flat; set(gca, 'YDir', 'reverse');
    clim(ax3,[-0.15 0.15]); colormap(ax3,slanCM('PuOr'));
    hold on; area(dx,bottom,5000,'facecolor',[0.6 0.6 0.6],'edgecolor','k'); hold off 
    axhandles{end+1}=ax3;
    
    ax4=subplot(2,4,k(i)+3);
    pcolor(dx, dz, dO); shading flat; set(gca, 'YDir', 'reverse');
    clim(ax4,[-25 25]); colormap(ax4,slanCM('coolwarm'));
    hold on; area(dx,bottom,5000,'facecolor',[0.6 0.6 0.6],'edgecolor','k'); hold off 
    axhandles{end+1}=ax4;

    % yticks(ax2,{}); yticks(ax3,{}); yticks(ax4,{});
    set(ax2, 'YTick', []); set(ax3, 'YTick', []); set(ax4, 'YTick', []);

    if i == 1
        ylabel(ax1,'Pressure [dbar]');
        cb1 = colorbar(ax1,'Position', [0.13, 0.89, 0.155, 0.02]);
        cb1.Label.String = column_labels{1};
        cb1.Label.FontSize = 12;
        cb1.Label.Rotation = 0; % Set to 0 for horizontal text
        cb1.Label.Position = [0, 2.7, 0]; % Move label above colorbar
        cb1.TickLength = 0.02;
        cb1.Orientation = 'horizontal';
        %cb1.Box = 'on';

        cb2 = colorbar(ax2,'Position', [0.308, 0.89, 0.155, 0.02]);
        cb2.Label.String = column_labels{2};
        cb2.Label.FontSize = 12;
        cb2.Label.Position = [0, 2.7, 0]; % Move label above colorbar
        cb2.Label.Rotation = 0; % Set to 0 for horizontal text
        cb2.TickLength = 0.02;
        cb2.Orientation = 'horizontal';

        cb3 = colorbar(ax3,'Position', [0.483, 0.89, 0.155, 0.02]);
        cb3.Label.String = column_labels{3};
        cb3.Label.FontSize = 12;
        cb3.Label.Position = [0, 2.7, 0]; % Move label above colorbar
        cb3.Label.Rotation = 0; % Set to 0 for horizontal text
        cb3.TickLength = 0.02;
        cb3.Orientation = 'horizontal';

        cb4 = colorbar(ax4,'Position', [0.66, 0.89, 0.155, 0.02]);
        cb4.Label.String = column_labels{4};
        cb4.Label.FontSize = 12;
        cb4.Label.Position = [0, 2.7, 0]; % Move label above colorbar
        cb4.Label.Rotation = 0; % Set to 0 for horizontal text
        cb4.TickLength = 0.02;
        cb4.Orientation = 'horizontal';

    elseif i==2
        ylabel(ax1,'Pressure [dbar]');
        xlabel(ax1,'Latitude °N'); xlabel(ax2,'Latitude °N');
        xlabel(ax3,'Latitude °N'); xlabel(ax4,'Latitude °N');

    end


end


% This is for shifting the plots down
shift_down1=0.075; shift_down2=0.045; % Amount to shift down (adjust as needed)
j=1;
for h = axhandles
    pos = get(h{1}, 'Position');
    if j<5
        pos(2) = pos(2) - shift_down1; % Move down
    else
        pos(2) = pos(2) - shift_down2; % Move down
    end
    set(h{1}, 'Position', pos);
    j=j+1;
end

% This is for shifting the plots lefts
shift_left=[0,0.03,0.06,0.09,0,0.03,0.06,0.09]; % This vestor is the displacement for each subplot
j=1;
for h = axhandles
    pos = get(h{1}, 'Position');
    pos(1) = pos(1) - shift_left(j); % Move left
    set(h{1}, 'Position', pos);
    j=j+1;
end

set(gca, 'LooseInset', get(gca, 'TightInset'));
% exportgraphics(gcf,'15.MeridionalTransectDifference.png')

%% Zonal Transects

k=[1,5,9];

figure('Position', [74, -43, 1812, 900]);
axhandles = {};

for i=1:length(zonal)

    dx=dynamicvariable('dX_',zonal{i});
    dz=dynamicvariable('dZ_',zonal{i});
    bottom=dynamicvariable('Bottom_',zonal{i});
    dT=dynamicvariable('T2017in_',zonal{i})-dynamicvariable('T2015in_',zonal{i});
    dS=dynamicvariable('S2017in_',zonal{i})-dynamicvariable('S2015in_',zonal{i});
    dSigma=dynamicvariable('Sigma2017in_',zonal{i})-dynamicvariable('Sigma2015in_',zonal{i});
    dO=dynamicvariable('O2017in_',zonal{i})-dynamicvariable('O2015in_',zonal{i});

    ax1=subplot(3,4,k(i));
    pcolor(dx, dz, dT); shading flat; set(gca, 'YDir', 'reverse');
    clim(ax1,[-1.5 1.5]); colormap(ax1,slanCM('vik'));
    hold on; area(dx,bottom,5000,'facecolor',[0.6 0.6 0.6],'edgecolor','k'); hold off 
    axhandles{end+1}=ax1;
    
    ax2=subplot(3,4,k(i)+1);
    pcolor(dx, dz, dS); shading flat; set(gca, 'YDir', 'reverse');
    clim(ax2,[-0.2 0.2]); colormap(ax2,slanCM('delta'));
    hold on; area(dx,bottom,5000,'facecolor',[0.6 0.6 0.6],'edgecolor','k'); hold off 
    axhandles{end+1}=ax2;
    
    ax3=subplot(3,4,k(i)+2);
    pcolor(dx, dz, dSigma); shading flat; set(gca, 'YDir', 'reverse');
    clim(ax3,[-0.15 0.15]); colormap(ax3,slanCM('PuOr'));
    hold on; area(dx,bottom,5000,'facecolor',[0.6 0.6 0.6],'edgecolor','k'); hold off 
    axhandles{end+1}=ax3;
    
    ax4=subplot(3,4,k(i)+3);
    pcolor(dx, dz, dO); shading flat; set(gca, 'YDir', 'reverse');
    clim(ax4,[-25 25]); colormap(ax4,slanCM('coolwarm'));
    hold on; area(dx,bottom,5000,'facecolor',[0.6 0.6 0.6],'edgecolor','k'); hold off 
    axhandles{end+1}=ax4;

    % yticks(ax2,{}); yticks(ax3,{}); yticks(ax4,{});
    set(ax2, 'YTick', []); set(ax3, 'YTick', []); set(ax4, 'YTick', []);

    if i == 1
        ylabel(ax1,'Pressure [dbar]');
        cb1 = colorbar(ax1,'Position', [0.13, 0.875, 0.155, 0.02]);
        cb1.Label.String = column_labels{1};
        cb1.Label.FontSize = 12;
        cb1.Label.Rotation = 0; % Set to 0 for horizontal text
        cb1.Label.Position = [0, 2.7, 0]; % Move label above colorbar
        cb1.TickLength = 0.02;
        cb1.Orientation = 'horizontal';
        %cb1.Box = 'on';

        cb2 = colorbar(ax2,'Position', [0.308, 0.875, 0.155, 0.02]);
        cb2.Label.String = column_labels{2};
        cb2.Label.FontSize = 12;
        cb2.Label.Position = [0, 2.7, 0]; % Move label above colorbar
        cb2.Label.Rotation = 0; % Set to 0 for horizontal text
        cb2.TickLength = 0.02;
        cb2.Orientation = 'horizontal';

        cb3 = colorbar(ax3,'Position', [0.483, 0.875, 0.155, 0.02]);
        cb3.Label.String = column_labels{3};
        cb3.Label.FontSize = 12;
        cb3.Label.Position = [0, 2.7, 0]; % Move label above colorbar
        cb3.Label.Rotation = 0; % Set to 0 for horizontal text
        cb3.TickLength = 0.02;
        cb3.Orientation = 'horizontal';

        cb4 = colorbar(ax4,'Position', [0.66, 0.875, 0.155, 0.02]);
        cb4.Label.String = column_labels{4};
        cb4.Label.FontSize = 12;
        cb4.Label.Position = [0, 2.7, 0]; % Move label above colorbar
        cb4.Label.Rotation = 0; % Set to 0 for horizontal text
        cb4.TickLength = 0.02;
        cb4.Orientation = 'horizontal';

    elseif i==2
        ylabel(ax1,'Pressure [dbar]');

    elseif i==3
        ylabel(ax1,'Pressure [dbar]');
        xlabel(ax1,'Longitude °W'); xlabel(ax2,'Longitude °W');
        xlabel(ax3,'Longitude °W'); xlabel(ax4,'Longitude °W');

    end


end


% This is for shifting the plots down
shift_down1=0.075; shift_down2=0.04; shift_down3=0.0; % Amount to shift down (adjust as needed)
j=1;
for h = axhandles
    pos = get(h{1}, 'Position');
    if j<5
        pos(2) = pos(2) - shift_down1; % Move down
    elseif j>4 && j<9
        pos(2) = pos(2) - shift_down2; % Move down
    else
        pos(2) = pos(2) - shift_down3;
    end
    set(h{1}, 'Position', pos);
    j=j+1;
end

% This is for shifting the plots lefts
shift_left=[0,0.03,0.06,0.09,0,0.03,0.06,0.09,0,0.03,0.06,0.09]; % This vestor is the displacement for each subplot
j=1;
for h = axhandles
    pos = get(h{1}, 'Position');
    pos(1) = pos(1) - shift_left(j); % Move left
    set(h{1}, 'Position', pos);
    j=j+1;
end

set(gca, 'LooseInset', get(gca, 'TightInset'));
% exportgraphics(gcf,'16.ZonalTransectDifference.png')

%% Difference in T-S space

figure('Position', [74, -43, 800, 700]);
for i=1:length(all)

    dT=dynamicvariable('T2017in_',all{i})-dynamicvariable('T2015in_',all{i});
    dS=dynamicvariable('S2017in_',all{i})-dynamicvariable('S2015in_',all{i});
    dO=dynamicvariable('O2017in_',all{i})-dynamicvariable('O2015in_',all{i});
    dT=dT(:); dS=dS(:); dO=dO(:);

    hold on
    scatter(dS,dT,5,dO,'filled');
    cb=colorbar; colormap(slanCM('coolwarm')); caxis([-25 25]);
    grid on
    hold off

end
xlim([-1.1 1.1]); ylim([-4 6]);
xlabel('Salinity [PSU]','FontSize',14)
ylabel('Potential Temperature [°C]','FontSize',14)
cb.Label.String = 'Oxygen Concentration (μmol/kg)'; cb.FontSize = 13;
title('RREX2017 - RREX2015 in T-S Space','FontSize',15, 'FontWeight', 'bold','FontName','LMRoman10')
xline(0,'--','Alpha',0.25);yline(0,'--','Alpha',0.25);

set(gca, 'LooseInset', get(gca, 'TightInset'));
exportgraphics(gcf,'17a.TSDifference.png')

%% The same but using density as a colorbar

figure('Position', [74, -43, 800, 700]);
for i=1:length(all)

    dT=dynamicvariable('T2017in_',all{i})-dynamicvariable('T2015in_',all{i});
    dS=dynamicvariable('S2017in_',all{i})-dynamicvariable('S2015in_',all{i});
    dSigma=dynamicvariable('Sigma2017in_',all{i})-dynamicvariable('Sigma2015in_',all{i});
    dT=dT(:); dS=dS(:); dSigma=dSigma(:);

    hold on
    scatter(dS,dT,5,dSigma,'filled');
    cb=colorbar; colormap(slanCM('PuOr')); caxis([-0.3 0.3]);
    grid on
    hold off

end
xlim([-1.1 1.1]); ylim([-4 6]);
xlabel('Salinity [PSU]','FontSize',14)
ylabel('Potential Temperature [°C]','FontSize',14)
cb.Label.String = '\sigma [kg/m^3]'; cb.FontSize = 13;
title('RREX2017 - RREX2015 in T-S Space','FontSize',15, 'FontWeight', 'bold','FontName','LMRoman10')
xline(0,'--','Alpha',0.25);yline(0,'--','Alpha',0.25);

set(gca, 'LooseInset', get(gca, 'TightInset'));
exportgraphics(gcf,'17b.TSDifference.png')