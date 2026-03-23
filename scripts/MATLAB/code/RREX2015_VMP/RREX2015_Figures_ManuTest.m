% We load paths and colorbars
addpath(genpath('C:/Users/mitg1n25/Desktop/PhD/Year 1 - 2026'))
%addpath(genpath('D:/Respaldo PC/iop/materia/Magister/Semestre 2/PRODIGY/m_map/'))
set(0, 'DefaultAxesFontSize', 12);
set(0, 'DefaultAxesTitleFontSizeMultiplier', 1.15)

map = load('colormap_RREX.mat'); % colormap(map.cmap);
load REXXBathymetry.mat


% This is the script I'll use to plot the results of the RREX2015 VMP data
% Variables 38 - 78 are along the ridge

%% First, we load the variables calculated previously
load("RREX2015_processed_VMP6000_ManuTest.mat")

% And take a look at the folder that has the .nc processed
% data so we can extract the lat and lon

folder='C:/Users/mitg1n25/Desktop/PhD/Year 1 - 2026/Microstructure Data/RREX/113063';
filenames = dir(fullfile(folder,'*.nc'));

n=length(filenames);
lat=NaN(1,n); lon=NaN(1,n);
for i=1:length(filenames)
    lat(1,i)=ncread(filenames(i).name,'Latitude_VMP',1,1);
    lon(1,i)=ncread(filenames(i).name,'Longitude_VMP',1,1);
end
%% Transect plots

% First we separate the different transects
ridge=[38:47 49:56]; trans1=27:37; trans2=17:26;

% trans 1 corresponds to the transect north-west of the ridge
% trans 2 corresponds to the transect north-east of the ridge

%% 1) Ridge
lim=[10^-10 10^-7];

% Epsilon
figure()
subplot(2,2,1)
pcolor(lat(ridge),pres,(epsSH1(:,ridge)));
shading flat; set(gca,'ColorScale','log');
colorbar; caxis(lim); colormap(slanCM('plasma'));
ylim([100 4000])
set(gca,'YDir','reverse')
ylabel('Pressure [dbar]');
title('\epsilon shear 1');

subplot(2,2,2)
pcolor(lat(ridge),pres,(epsSH2(:,ridge)));
shading flat; set(gca,'ColorScale','log');
colorbar; caxis(lim); colormap(slanCM('plasma'));
set(gca,'YDir','reverse'); ylim([100 4000])
title('\epsilon Shear 2');

subplot(2,2,3)
pcolor(lat(ridge),pres,(epsT1(:,ridge)));
shading flat; set(gca,'ColorScale','log');
colorbar; caxis(lim); colormap(slanCM('plasma'));
set(gca,'YDir','reverse'); ylim([100 4000])
ylabel('Pressure [dbar]'); xlabel('Latitude °N')
title('\epsilon Temperature 1');

subplot(2,2,4)
pcolor(lat(ridge),pres,(epsT2(:,ridge)));
shading flat; set(gca,'ColorScale','log');
colorbar; caxis(lim); colormap(slanCM('plasma'));
set(gca,'YDir','reverse'); ylim([100 4000])
xlabel('Latitude °N')
title('\epsilon Temperature 2');

sgtitle('RREX2015 VMP Data Along the Ridge')

% saveas(gcf,'RREX2015_ridge_epsilon.png')

% Xi

figure()
subplot(1,2,1)
pcolor(lat(ridge),pres,(Xif1(:,ridge)));
shading flat; set(gca,'ColorScale','log');
colorbar; caxis(lim); colormap(slanCM('plasma'));
set(gca,'YDir','reverse'); ylim([100 4000])
ylabel('Pressure [dbar]'); xlabel('Latitude °N')
title('\chi Temperature 1');

subplot(1,2,2)
pcolor(lat(ridge),pres,(Xif2(:,ridge)));
shading flat; set(gca,'ColorScale','log');
colorbar; caxis(lim); colormap(slanCM('plasma'));
set(gca,'YDir','reverse'); ylim([100 4000])
xlabel('Latitude °N')
title('\chi Temperature 2');

sgtitle('RREX2015 VMP Data Along the Ridge')

% saveas(gcf,'RREX2015_ridge_chi.png')

% Hydrographic variables

figure()
ax1=subplot(2,2,1)
pcolor(lat(ridge),pres,(theta(:,ridge)));
shading flat;
c=colorbar; caxis([2 10]); colormap(ax1,slanCM('turbo'));
set(gca,'YDir','reverse'); ylim([100 4000])
ylabel('Pressure [dbar]');
c.Label.String = '[°C]';
title('\Theta');

ax2=subplot(2,2,2)
pcolor(lat(ridge),pres,(S(:,ridge)));
shading flat; 
c=colorbar; caxis([34.6 35.2]); colormap(ax2,slanCM('haline'));
set(gca,'YDir','reverse'); ylim([100 4000])
c.Label.String = '[PSU]';
title('Salinity');

ax3=subplot(2,2,3.5)
pcolor(lat(ridge),pres,real(sigma0(:,ridge)));
shading flat; set(gca,'ColorScale','log');
c=colorbar; caxis([1027 1028]); colormap(ax3,slanCM('gnuplot2'));
set(gca,'YDir','reverse'); ylim([100 4000])
c.Label.String = '[kg/m^3]'; xlabel('Latitude °N')
ylabel('Pressure [dbar]'); title('\sigma_0');

sgtitle('RREX2015 VMP Data Along the Ridge - Hydrography')

% saveas(gcf,'RREX2015_ridge_hydrography.png')

%% 2) Transect 1 (the one in the north west of the ridge)

% Epsilon
figure()
subplot(2,2,1)
pcolor(lon(trans1),pres,(epsSH1(:,trans1)));
shading flat; set(gca,'ColorScale','log');
colorbar; caxis(lim); colormap(slanCM('plasma'));
ylim([100 4000]);
set(gca,'YDir','reverse')
ylabel('Pressure [dbar]');
title('\epsilon shear 1');

subplot(2,2,2)
pcolor(lon(trans1),pres,(epsSH2(:,trans1)));
shading flat; set(gca,'ColorScale','log');
colorbar; caxis(lim); colormap(slanCM('plasma'));
set(gca,'YDir','reverse'); ylim([100 4000])
title('\epsilon Shear 2');

subplot(2,2,3)
pcolor(lon(trans1),pres,(epsT1(:,trans1)));
shading flat; set(gca,'ColorScale','log');
colorbar; caxis(lim); colormap(slanCM('plasma'));
set(gca,'YDir','reverse'); ylim([100 4000])
ylabel('Pressure [dbar]'); xlabel('Longitude °W')
title('\epsilon Temperature 1');

subplot(2,2,4)
pcolor(lon(trans1),pres,(epsT2(:,trans1)));
shading flat; set(gca,'ColorScale','log');
colorbar; caxis(lim); colormap(slanCM('plasma'));
set(gca,'YDir','reverse'); ylim([100 4000])
xlabel('Longitude °W')
title('\epsilon Temperature 2');

sgtitle('RREX2015 VMP Data Along 63°N West of Ridge')

% saveas(gcf,'RREX2015_westridge_epsilon.png')

% Xi

figure()
subplot(1,2,1)
pcolor(lon(trans1),pres,(Xif1(:,trans1)));
shading flat; set(gca,'ColorScale','log');
colorbar; caxis(lim); colormap(slanCM('plasma'));
set(gca,'YDir','reverse'); ylim([100 4000])
ylabel('Pressure [dbar]'); xlabel('Longitude °W')
title('\chi Temperature 1');

subplot(1,2,2)
pcolor(lon(trans1),pres,(Xif2(:,trans1)));
shading flat; set(gca,'ColorScale','log');
colorbar; caxis(lim); colormap(slanCM('plasma'));
set(gca,'YDir','reverse'); ylim([100 4000])
xlabel('Longitude °W')
title('\chi Temperature 2');

sgtitle('RREX 2015 VMP Data Along 63°N West of Ridge')

% saveas(gcf,'RREX2015_westridge_chi.png')

% Hydrographic variables

figure()
ax1=subplot(2,2,1)
pcolor(lon(trans1),pres,(theta(:,trans1)));
shading flat;
c=colorbar; caxis([2 10]); colormap(ax1,slanCM('turbo'));
set(gca,'YDir','reverse'); ylim([100 4000])
ylabel('Pressure [dbar]');
c.Label.String = '[°C]';
title('\Theta');

ax2=subplot(2,2,2)
pcolor(lon(trans1),pres,(S(:,trans1)));
shading flat; 
c=colorbar; caxis([34.6 35.2]); colormap(ax2,slanCM('haline'));
set(gca,'YDir','reverse'); ylim([100 4000])
c.Label.String = '[PSU]';
title('Salinity');

ax3=subplot(2,2,3.5)
pcolor(lon(trans1),pres,real(sigma0(:,trans1)));
shading flat; set(gca,'ColorScale','log');
c=colorbar; caxis([1027 1028]); colormap(ax3,slanCM('gnuplot2'));
set(gca,'YDir','reverse'); ylim([100 4000])
c.Label.String = '[kg/m^3]'; xlabel('Longitude °W')
ylabel('Pressure [dbar]'); title('\sigma_0');

sgtitle('RREX2015 VMP Data Along 63°N West of Ridge - Hydrography')

% saveas(gcf,'RREX2015_westridge_hydrography.png')

%% 3) Transect 2 (the one in the north west of the ridge)

% Epsilon
figure()
subplot(2,2,1)
pcolor(lon(trans2),pres,(epsSH1(:,trans2)));
shading flat; set(gca,'ColorScale','log');
colorbar; caxis(lim); colormap(slanCM('plasma'));
ylim([100 4000]);
set(gca,'YDir','reverse')
ylabel('Pressure [dbar]');
title('\epsilon shear 1');

subplot(2,2,2)
pcolor(lon(trans2),pres,(epsSH2(:,trans2)));
shading flat; set(gca,'ColorScale','log');
colorbar; caxis(lim); colormap(slanCM('plasma'));
set(gca,'YDir','reverse'); ylim([100 4000])
title('\epsilon Shear 2');

subplot(2,2,3)
pcolor(lon(trans2),pres,(epsT1(:,trans2)));
shading flat; set(gca,'ColorScale','log');
colorbar; caxis(lim); colormap(slanCM('plasma'));
set(gca,'YDir','reverse'); ylim([100 4000])
ylabel('Pressure [dbar]'); xlabel('Longitude °W')
title('\epsilon Temperature 1');

subplot(2,2,4)
pcolor(lon(trans2),pres,(epsT2(:,trans2)));
shading flat; set(gca,'ColorScale','log');
colorbar; caxis(lim); colormap(slanCM('plasma'));
set(gca,'YDir','reverse'); ylim([100 4000])
xlabel('Longitude °W')
title('\epsilon Temperature 2');

sgtitle('RREX2015 VMP Data East of Ridge')

% saveas(gcf,'RREX2015_eastridge_epsilon.png')

% Xi

figure()
subplot(1,2,1)
pcolor(lon(trans2),pres,(Xif1(:,trans2)));
shading flat; set(gca,'ColorScale','log');
colorbar; caxis(lim); colormap(slanCM('plasma'));
set(gca,'YDir','reverse'); ylim([100 4000])
ylabel('Pressure [dbar]'); xlabel('Longitude °W')
title('\chi Temperature 1');

subplot(1,2,2)
pcolor(lon(trans2),pres,(Xif2(:,trans2)));
shading flat; set(gca,'ColorScale','log');
colorbar; caxis(lim); colormap(slanCM('plasma'));
set(gca,'YDir','reverse'); ylim([100 4000])
xlabel('Longitude °W')
title('\chi Temperature 2');

sgtitle('RREX 2015 VMP Data East of Ridge')

% saveas(gcf,'RREX2015_eastridge_chi.png')

% Hydrographic variables

figure()
ax1=subplot(2,2,1)
pcolor(lon(trans2),pres,(theta(:,trans2)));
shading flat;
c=colorbar; caxis([2 10]); colormap(ax1,slanCM('turbo'));
set(gca,'YDir','reverse'); ylim([100 4000])
ylabel('Pressure [dbar]');
c.Label.String = '[°C]';
title('\Theta');

ax2=subplot(2,2,2)
pcolor(lon(trans2),pres,(S(:,trans2)));
shading flat; 
c=colorbar; caxis([34.6 35.2]); colormap(ax2,slanCM('haline'));
set(gca,'YDir','reverse'); ylim([100 4000])
c.Label.String = '[PSU]';
title('Salinity');

ax3=subplot(2,2,3.5)
pcolor(lon(trans2),pres,real(sigma0(:,trans2)));
shading flat; set(gca,'ColorScale','log');
c=colorbar; caxis([1027 1028]); colormap(ax3,slanCM('gnuplot2'));
set(gca,'YDir','reverse'); ylim([100 4000])
c.Label.String = '[kg/m^3]'; xlabel('Longitude °W')
ylabel('Pressure [dbar]'); title('\sigma_0');

sgtitle('RREX2015 VMP Data East of Ridge - Hydrography')

% saveas(gcf,'RREX2015_eastridge_hydrography.png')

%% Integrated/Mean values of turbulent dissipation

% We consider values below 100m (position 25)
% Calculate mean values for turbulent dissipation
meanEpsilonSH1 = mean(epsSH1(26:end,:), 1,'omitmissing');
meanEpsilonSH2 = mean(epsSH2(26:end,:), 1,'omitmissing');
meanEpsilonT1 = mean(epsT1(26:end,:), 1,'omitmissing');

% Calculate mean values for Xi
meanXi1 = mean(Xif1(26:end,:), 1,'omitmissing');
meanXi2 = mean(Xif2(26:end,:), 1,'omitmissing');

% % Calculate mean values for hydrographic variables
% meanTheta = mean(theta(26:end,:), 1,'omitmissing');
% meanSalinity = mean(S(26:end,:), 1,'omitmissing');
% meanSigma0 = mean(real(sigma0(26:end,:)), 1,'omitmissing');

%% Plot for average Shear values in the region

% First plot the region with the colorbar using in the picture

figure(); set(gcf, 'Position',  [100, 100, 925, 575])
ax1 = axes('Position',[0.07 0.12 0.86 0.78]); % adjust margins
pcolor(lonsub,latsub,zsub); shading flat
colormap(ax1,map.cmap);%cb1= colorbar(ax1,'eastoutside'); caxis(ax1,[-4500 500]);
%title(cb1,{'Depth [m]',''}); % Move up by inserting a blank line
%cb1 = gca; cb1.FontSize = 13; 

% Now lets add the scatter plot
% 
% % Top axes: transparent for scatter (same position)
% ax2 = axes('Position', ax1.Position);
% ax2.Color = 'none';                      % transparent
% ax2.XLim = ax1.XLim; ax2.YLim = ax1.YLim;
% ax2.FontSize = 13;
% hold(ax2,'on')
% 
% % Plot scatter on ax2
% s = scatter(ax2, lon, lat, 75, meanEpsilonSH2, 'filled', 'MarkerEdgeColor','k');
% set(ax2,'ColorScale','log');
% colormap(ax2, slanCM('plasma'));   
% %colormap(ax2, slanCM('plasma'));                       % different colormap for scatter
% %cb2 = colorbar(ax2,'eastoutside');        % colorbar for scatter
% caxis(ax2,[10^-10 10^-9]);
% %title(cb2, 'Scatter metric')
% ax2.XTick = []; ax2.YTick = [];           % hide duplicate ticks if desired
% xlabel(ax1,'Longitude'); ylabel(ax1,'Latitude');
% linkaxes([ax1 ax2]) 

% saveas(gcf,'MeanShearRREX2015.png')

%% Plot for average Xi values in the region

% First plot the region with the colorbar using in the picture

figure(); set(gcf, 'Position',  [100, 100, 925, 575])
ax1 = axes('Position',[0.07 0.12 0.86 0.78]); % adjust margins
pcolor(lonsub,latsub,zsub); shading flat
colormap(ax1,map.cmap);%cb1= colorbar(ax1,'eastoutside'); caxis(ax1,[-4500 500]);
%title(cb1,{'Depth [m]',''}); % Move up by inserting a blank line
%cb1 = gca; cb1.FontSize = 13; 

% Now lets add the scatter plot

% Top axes: transparent for scatter (same position)
ax2 = axes('Position', ax1.Position);
ax2.Color = 'none';                      % transparent
ax2.XLim = ax1.XLim; ax2.YLim = ax1.YLim;
ax2.FontSize = 13;
hold(ax2,'on')

% Plot scatter on ax2
s = scatter(ax2, lon([1:19 22:end]), lat([1:19 22:end]), 75, meanXi1([1:19 22:end]), 'filled', 'MarkerEdgeColor','k');
set(ax2,'ColorScale','log');
colormap(ax2, slanCM('plasma'));   
%colormap(ax2, slanCM('plasma'));                       % different colormap for scatter
%cb2 = colorbar(ax2,'eastoutside');        % colorbar for scatter
caxis(ax2,[10^-10 10^-8]);
%title(cb2, 'Scatter metric')
ax2.XTick = []; ax2.YTick = [];           % hide duplicate ticks if desired
xlabel(ax1,'Longitude'); ylabel(ax1,'Latitude');
linkaxes([ax1 ax2]) 

% saveas(gcf,'MeanXiRREX2015.png')

%% Plot the colorbars so i can save them for later

% Assume you know the colormaps and limits you used:
cmap1 = map.cmap;          % bathymetry colormap
lim1  = [-4500 500];      % bathymetry caxis
cmap2 = slanCM('plasma'); % scatter colormap
lim2  = [1e-10 1e-9];     % scatter caxis

% New figure sized for two colorbars side-by-side
fh = figure('Position',[100, 100, 1125, 675])

% Left colorbar (for scatter)
axL = axes(fh,'Position',[0.05 0.15 0.25 0.7],'Visible','off'); % invisible axes
set(axL,'ColorScale','log'); colormap(axL,cmap2);
caxis(axL,lim2);
cbL = colorbar(axL,'westoutside');    % place on left
cbL.Label.String = 'Mean \epsilon [W/kg]';
cbL.Label.FontSize = 12;
cbL.TicksMode = 'auto';

% Right colorbar (for bathymetry)
axR = axes(fh,'Position',[0.55 0.15 0.25 0.7],'Visible','off');
colormap(axR,cmap1);
caxis(axR,lim1);
cbR = colorbar(axR,'eastoutside');    % place on right
cbR.Label.String = 'Depth [m]';
cbR.Label.FontSize = 12;

% Optional: tidy figure before saving
set(fh,'Color','w');

saveas(gcf,'colorbars_epsilon.png')

% The same for Xi
lim2  = [1e-10 1e-8];     % scatter caxis

% New figure sized for two colorbars side-by-side
fh = figure('Position',[100, 100, 1125, 675])

% Left colorbar (for scatter)
axL = axes(fh,'Position',[0.05 0.15 0.25 0.7],'Visible','off'); % invisible axes
set(axL,'ColorScale','log'); colormap(axL,cmap2);
caxis(axL,lim2);
cbL = colorbar(axL,'westoutside');    % place on left
cbL.Label.String = 'Mean \chi [K^2/s]';
cbL.Label.FontSize = 12;
cbL.TicksMode = 'auto';

% Right colorbar (for bathymetry)
axR = axes(fh,'Position',[0.55 0.15 0.25 0.7],'Visible','off');
colormap(axR,cmap1);
caxis(axR,lim1);
cbR = colorbar(axR,'eastoutside');    % place on right
cbR.Label.String = 'Depth [m]';
cbR.Label.FontSize = 12;

% Optional: tidy figure before saving
set(fh,'Color','w');

saveas(gcf,'colorbars_xi.png')

%% Now we calculate the averaged values of a distinct region

% Calculate ridge values for turbulent dissipation
ridgeSH1 = mean(epsSH1(:,ridge), 2,'omitmissing');
ridgeSH2 = mean(epsSH2(:,ridge), 2,'omitmissing');
ridgeEpsilonT1 = mean(epsT1(:,ridge), 2,'omitmissing');
% Calculate ridge values for Xi
ridgeXi1 = mean(Xif1(:,ridge), 2,'omitmissing');
ridgeXi2 = mean(Xif2(:,ridge), 2,'omitmissing');

% Calculate ridge values for hydrographic variables
ridgeTheta = mean(theta(:,ridge), 2,'omitmissing');
ridgeSalinity = mean(S(:,ridge), 2,'omitmissing');
ridgeSigma0 = mean(real(sigma0(:,ridge)), 2,'omitmissing');

% We do the same thing for trans1 and trans2
trans1SH1 = mean(epsSH1(:,trans1), 2,'omitmissing');
trans1SH2 = mean(epsSH2(:,trans1), 2,'omitmissing');
trans1EpsilonT1 = mean(epsT1(:,trans1([1:11 14:end])), 2,'omitmissing');
trans1Xi1 = mean(Xif1(:,trans1([1:11 14:end])), 2,'omitmissing'); %Values at position 12 (e-5) and 13 (e-6) overestimate the average
trans1Theta = mean(theta(:,trans1), 2,'omitmissing');
trans1Salinity = mean(S(:,trans1), 2,'omitmissing');
trans1Sigma0 = mean(real(sigma0(:,trans1)), 2,'omitmissing');

trans2SH1 = mean(epsSH1(:,trans2), 2,'omitmissing');
trans2SH2 = mean(epsSH2(:,trans2), 2,'omitmissing');
trans2EpsilonT1 = mean(epsT1(:,trans2), 2,'omitmissing');
trans2Xi1 = mean(Xif1(:,trans2), 2,'omitmissing');
trans2Theta = mean(theta(:,trans2), 2,'omitmissing');
trans2Salinity = mean(S(:,trans2), 2,'omitmissing');
trans2Sigma0 = mean(real(sigma0(:,trans2)), 2,'omitmissing');

%% Plot the values Epsilon & Xi

figure('Position',[20, 20, 800, 700])

lim=[1e-11 1e-7];
n = 5; % number of ticks
subplot(1,2,1)
hold on
plot(ridgeSH2,pres,'-b','LineWidth',1.5)
plot(trans1SH2,pres,'-r','LineWidth',1.5)
plot(trans2SH2,pres,'-k','LineWidth',1.5)
hold off
ax=gca; ax.XScale='log';
set(gca,'YDir','reverse'); ylim([100 4000])
xlim(lim); xticks(ax, logspace(log10(lim(1)), log10(lim(2)), n));
ylabel('Pressure [dbar]')
title('Region Averaged \epsilon [W/kg]'); grid on

subplot(1,2,2)
lim=[1e-12 1e-6];
n = 7; % number of ticks

hold on
plot(ridgeXi2,pres,'-b','LineWidth',1.5)
plot(trans1Xi1,pres,'-r','LineWidth',1.5)
plot(trans2Xi1,pres,'-k','LineWidth',1.5)
hold off
ax=gca; ax.XScale='log';
set(gca,'YDir','reverse'); ylim([100 4000])
xlim(lim); xticks(ax, logspace(log10(lim(1)), log10(lim(2)), n));
title('Region Averaged \chi [K^2/s]'); grid on
legend('Ridge','West of Ridge','East of Ridge');

sgtitle('RREX 2015 VMP Data')

% saveas(gcf,'RegionXiREXX2015.png')

%% Pretty plots of transects


%% 1) Ridge
lim=[10^-10 10^-7];

% Epsilon
figure()
subplot(1,2,1)
pcolor(lat(ridge),pres,(epsSH2(:,ridge)));
shading flat; set(gca,'ColorScale','log');
colorbar; caxis(lim); colormap(slanCM('plasma'));
ylim([100 4000])
set(gca,'YDir','reverse')
ylabel('Pressure [dbar]');
xlabel('Latitude °N')
title('\epsilon [W/m]');

lim=[10^-10 10^-7];
subplot(1,2,2)
pcolor(lat(ridge),pres,(Xif2(:,ridge)));
shading flat; set(gca,'ColorScale','log');
colorbar; caxis(lim); colormap(slanCM('plasma'));
set(gca,'YDir','reverse'); ylim([100 4000])
xlabel('Latitude °N')
title('\chi [K^2/s]');

sgtitle('RREX2015 VMP Data Along the Ridge')

saveas(gcf,'RREX2015_ridge_turbulence.png')

%% 2) West-Ridge

% Epsilon
figure()
subplot(1,2,1)
pcolor(lon(trans1),pres,(epsSH2(:,trans1)));
shading flat; set(gca,'ColorScale','log');
colorbar; caxis(lim); colormap(slanCM('plasma'));
ylim([100 4000]);
set(gca,'YDir','reverse')
ylabel('Pressure [dbar]'); xlabel('Longitude °W')
title('\epsilon [W/m]');

% Xi

subplot(1,2,2)
pcolor(lon(trans1),pres,(Xif1(:,trans1)));
shading flat; set(gca,'ColorScale','log');
colorbar; caxis(lim); colormap(slanCM('plasma'));
set(gca,'YDir','reverse'); ylim([100 4000])
xlabel('Longitude °W')
title('\chi [K^2/s]');

sgtitle('RREX2015 VMP Data Along 63 North West of the Ridge')

saveas(gcf,'RREX2015_westridge_turbulence.png')

%% 3) East of Ridge

% Epsilon
figure()
subplot(1,2,1)
pcolor(lon(trans2),pres,(epsSH2(:,trans2)));
shading flat; set(gca,'ColorScale','log');
colorbar; caxis(lim); colormap(slanCM('plasma'));
ylim([100 4000]);
set(gca,'YDir','reverse')
ylabel('Pressure [dbar]'); xlabel('Longitude °W')
title('\epsilon [W/m]');

% Xi

subplot(1,2,2)
pcolor(lon(trans2),pres,(Xif1(:,trans2)));
shading flat; set(gca,'ColorScale','log');
colorbar; caxis(lim); colormap(slanCM('plasma'));
set(gca,'YDir','reverse'); ylim([100 4000])
xlabel('Longitude °W')
title('\chi [K^2/s]');

sgtitle('RREX2015 VMP Data East of Ridge')

saveas(gcf,'RREX2015_eastridge_turbulence.png')

